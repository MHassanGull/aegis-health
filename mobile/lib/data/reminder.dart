import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/notifications.dart';

/// A single repeating health reminder, stored on-device (works offline).
class Reminder {
  final int id;
  final String type; // water | food | activity | meds | recheck | custom
  final String title;
  final String body;
  final int everyHours;
  bool enabled;

  Reminder({
    required this.id,
    required this.type,
    required this.title,
    required this.body,
    required this.everyHours,
    this.enabled = true,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'type': type,
        'title': title,
        'body': body,
        'everyHours': everyHours,
        'enabled': enabled,
      };

  factory Reminder.fromJson(Map<String, dynamic> j) => Reminder(
        id: j['id'] as int,
        type: j['type'] as String,
        title: j['title'] as String,
        body: j['body'] as String,
        everyHours: (j['everyHours'] as num).toInt(),
        enabled: j['enabled'] as bool? ?? true,
      );

  String get everyLabel {
    if (everyHours == 1) return 'Every hour';
    if (everyHours < 24) return 'Every $everyHours hours';
    if (everyHours == 24) return 'Every day';
    if (everyHours == 168) return 'Every week';
    return 'Every ${everyHours ~/ 24} days';
  }
}

/// Preset reminder templates the user can add with one tap.
class ReminderPreset {
  final String type;
  final String title;
  final String body;
  final IconData icon;
  final Color color;
  final int defaultHours;
  const ReminderPreset(this.type, this.title, this.body, this.icon, this.color,
      this.defaultHours);
}

const kReminderPresets = <ReminderPreset>[
  ReminderPreset('water', 'Drink water', 'Time for a glass of water',
      Icons.local_drink_rounded, Color(0xFF3D8BF2), 2),
  ReminderPreset('food', 'Eat healthy', 'Time for a balanced meal or a healthy snack 🍎',
      Icons.restaurant_rounded, Color(0xFFFF7A63), 4),
  ReminderPreset('activity', 'Move your body', 'Stand up and move for a few minutes 🚶',
      Icons.directions_run_rounded, Color(0xFF20A57A), 2),
  ReminderPreset('meds', 'Take medication', 'Time to take your medication ⏰',
      Icons.medication_rounded, Color(0xFF8A6DF0), 12),
  ReminderPreset('recheck', 'Re-check your risk', 'Run your Aegis health check and track your trend 🩺',
      Icons.favorite_rounded, Color(0xFFEB5B8A), 168),
];

IconData reminderIcon(String type) => kReminderPresets
    .firstWhere((p) => p.type == type,
        orElse: () => kReminderPresets.first)
    .icon;

Color reminderColor(String type) => kReminderPresets
    .firstWhere((p) => p.type == type,
        orElse: () => const ReminderPreset(
            '', '', '', Icons.notifications_rounded, Color(0xFFF2A03D), 1))
    .color;

/// Persists reminders locally and keeps the scheduled notifications in sync.
class ReminderStore {
  static const _key = 'reminders_v1';

  static Future<List<Reminder>> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw == null || raw.isEmpty) return [];
    final list = (jsonDecode(raw) as List).cast<Map<String, dynamic>>();
    return list.map(Reminder.fromJson).toList();
  }

  static Future<void> _persist(List<Reminder> items) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
        _key, jsonEncode(items.map((r) => r.toJson()).toList()));
  }

  /// Save the list and reconcile every scheduled notification.
  static Future<void> saveAndSync(List<Reminder> items) async {
    await _persist(items);
    for (final r in items) {
      if (r.enabled) {
        await NotificationService.instance.scheduleInterval(
          id: r.id,
          title: r.title,
          body: r.body,
          every: Duration(hours: r.everyHours),
        );
      } else {
        await NotificationService.instance.cancel(r.id);
      }
    }
  }

  /// Re-schedule all enabled reminders (call once on app start).
  static Future<void> rescheduleAll() async {
    final items = await load();
    for (final r in items.where((r) => r.enabled)) {
      await NotificationService.instance.scheduleInterval(
        id: r.id,
        title: r.title,
        body: r.body,
        every: Duration(hours: r.everyHours),
      );
    }
  }
}
