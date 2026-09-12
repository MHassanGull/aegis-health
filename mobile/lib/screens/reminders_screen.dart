import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../core/notifications.dart';
import '../core/theme.dart';
import '../data/reminder.dart';

class RemindersScreen extends StatefulWidget {
  const RemindersScreen({super.key});
  @override
  State<RemindersScreen> createState() => _RemindersScreenState();
}

class _RemindersScreenState extends State<RemindersScreen> {
  List<Reminder> _items = [];
  bool _loading = true;
  bool _granted = true;

  @override
  void initState() {
    super.initState();
    _boot();
  }

  Future<void> _boot() async {
    _granted = await NotificationService.instance.requestPermission();
    _items = await ReminderStore.load();
    if (mounted) setState(() => _loading = false);
  }

  int _nextId() =>
      (_items.isEmpty ? 1 : _items.map((r) => r.id).reduce((a, b) => a > b ? a : b) + 1);

  Future<void> _sync() async {
    await ReminderStore.saveAndSync(_items);
    if (mounted) setState(() {});
  }

  Future<void> _toggle(Reminder r, bool v) async {
    r.enabled = v;
    await _sync();
  }

  Future<void> _delete(Reminder r) async {
    await NotificationService.instance.cancel(r.id);
    _items.removeWhere((x) => x.id == r.id);
    await _sync();
  }

  Future<void> _addFlow() async {
    final preset = await showModalBottomSheet<ReminderPreset>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) => _PresetPicker(),
    );
    if (preset == null) return;

    String title = preset.title;
    String body = preset.body;
    if (preset.type == 'custom') {
      final custom = await _askCustom();
      if (custom == null) return;
      title = custom;
      body = 'Reminder: $custom';
    }
    if (!mounted) return;
    final hours = await showModalBottomSheet<int>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) => _IntervalPicker(preset.defaultHours),
    );
    if (hours == null) return;

    final reminder = Reminder(
      id: _nextId(),
      type: preset.type,
      title: title,
      body: body,
      everyHours: hours,
    );
    _items.add(reminder);
    await _sync();
    // Instant confirmation so you can SEE it's active (the real reminder then
    // repeats on schedule).
    await NotificationService.instance.showNow(
      900000 + reminder.id,
      'Reminder set ✓',
      '$title, I’ll remind you ${reminder.everyLabel.toLowerCase()}.',
    );
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Reminder set, ${reminder.everyLabel.toLowerCase()}')));
    }
  }

  Future<String?> _askCustom() {
    final c = TextEditingController();
    return showDialog<String>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Custom reminder'),
        content: TextField(
          controller: c,
          autofocus: true,
          decoration: const InputDecoration(hintText: 'e.g. Check blood pressure'),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          FilledButton(
              onPressed: () => Navigator.pop(context, c.text.trim()),
              child: const Text('Next')),
        ],
      ),
    ).then((v) => (v == null || v.isEmpty) ? null : v);
  }

  @override
  Widget build(BuildContext context) {
    final p = Palette.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Reminders')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addFlow,
        backgroundColor: AppTheme.green,
        icon: const Icon(Icons.add_rounded, color: Colors.white),
        label: const Text('Add', style: TextStyle(color: Colors.white)),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 90),
              children: [
                if (!_granted) _permissionBanner(p),
                Text('Stay healthy on schedule',
                    style: TextStyle(
                        fontSize: 22, fontWeight: FontWeight.w700, color: p.ink)),
                const SizedBox(height: 4),
                Text('Gentle repeating nudges. They work without a connection.',
                    style: TextStyle(color: p.subtle, fontSize: 13)),
                const SizedBox(height: 22),
                if (_items.isEmpty)
                  _emptyState(p)
                else
                  ...List.generate(_items.length, (i) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _ReminderCard(
                        _items[i],
                        p,
                        onToggle: (v) => _toggle(_items[i], v),
                        onDelete: () => _delete(_items[i]),
                        onTest: () => NotificationService.instance.showNow(
                            999000 + i, _items[i].title, _items[i].body),
                      ).animate().fadeIn(delay: (i * 60).ms).moveY(begin: 10, end: 0),
                    );
                  }),
              ],
            ),
    );
  }

  Widget _permissionBanner(Palette p) => Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
            color: p.tint(AppTheme.amber),
            borderRadius: BorderRadius.circular(AppTheme.radius)),
        child: Row(children: [
          const Icon(Icons.notifications_off_rounded, color: AppTheme.amber),
          const SizedBox(width: 12),
          Expanded(
            child: Text('Turn on notifications so reminders can reach you.',
                style: TextStyle(color: p.ink, fontSize: 13)),
          ),
          TextButton(
            onPressed: () async {
              _granted = await NotificationService.instance.requestPermission();
              if (mounted) setState(() {});
            },
            child: const Text('Enable'),
          ),
        ]),
      );

  Widget _emptyState(Palette p) => Padding(
        padding: const EdgeInsets.only(top: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Nothing scheduled yet', style: AppType.label.copyWith(color: p.subtle)),
            const SizedBox(height: 12),
            Text(
                'Reminders run on the phone itself, so they still fire with '
                'no signal. Add one to get started.',
                style: AppType.body.copyWith(color: p.subtle)),
          ],
        ),
      );
}

class _ReminderCard extends StatelessWidget {
  final Reminder r;
  final Palette p;
  final ValueChanged<bool> onToggle;
  final VoidCallback onDelete;
  final VoidCallback onTest;
  const _ReminderCard(this.r, this.p,
      {required this.onToggle, required this.onDelete, required this.onTest});

  @override
  Widget build(BuildContext context) {
    final color = reminderColor(r.type);
    return SoftCard(
      child: Row(
        children: [
          Container(
            height: 48,
            width: 48,
            decoration: BoxDecoration(
                color: color.withValues(alpha: p.isDark ? 0.28 : 0.14),
                borderRadius: BorderRadius.circular(AppTheme.radius)),
            child: Icon(reminderIcon(r.type), color: color),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(r.title,
                    style:
                        TextStyle(fontWeight: FontWeight.w700, color: p.ink)),
                const SizedBox(height: 2),
                Text(r.everyLabel,
                    style: TextStyle(color: p.subtle, fontSize: 12.5)),
              ],
            ),
          ),
          Column(
            children: [
              Switch(
                value: r.enabled,
                activeThumbColor: AppTheme.green,
                onChanged: onToggle,
              ),
              Row(mainAxisSize: MainAxisSize.min, children: [
                InkWell(
                  onTap: onTest,
                  child: Padding(
                    padding: const EdgeInsets.all(4),
                    child: Text('Test',
                        style: TextStyle(
                            color: AppTheme.green,
                            fontSize: 12,
                            fontWeight: FontWeight.w700)),
                  ),
                ),
                const SizedBox(width: 4),
                InkWell(
                  onTap: onDelete,
                  child: Icon(Icons.delete_outline_rounded,
                      size: 18, color: p.subtle),
                ),
              ]),
            ],
          ),
        ],
      ),
    );
  }
}

class _PresetPicker extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final p = Palette.of(context);
    final presets = [
      ...kReminderPresets,
      const ReminderPreset('custom', 'Custom reminder', '',
          Icons.edit_rounded, AppTheme.amber, 4),
    ];
    return SafeArea(
      child: ConstrainedBox(
        constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.72),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 6, bottom: 8),
                child: Text('What should we remind you about?',
                    style: TextStyle(
                        fontWeight: FontWeight.w700, color: p.ink, fontSize: 16)),
              ),
              Flexible(
                child: ListView(
                  shrinkWrap: true,
                  children: [
                    ...presets.map((preset) => ListTile(
                  leading: CircleAvatar(
                    backgroundColor: preset.color.withValues(alpha: 0.15),
                    child: Icon(preset.icon, color: preset.color),
                  ),
                  title: Text(preset.title,
                      style: TextStyle(
                          fontWeight: FontWeight.w700, color: p.ink)),
                  subtitle: preset.type == 'custom'
                      ? Text('Your own reminder',
                          style: TextStyle(color: p.subtle))
                      : Text(preset.body,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(color: p.subtle)),
                  onTap: () => Navigator.pop(context, preset),
                    )),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _IntervalPicker extends StatelessWidget {
  final int defaultHours;
  const _IntervalPicker(this.defaultHours);
  @override
  Widget build(BuildContext context) {
    final p = Palette.of(context);
    const options = [
      (1, 'Every hour'),
      (2, 'Every 2 hours'),
      (3, 'Every 3 hours'),
      (4, 'Every 4 hours'),
      (6, 'Every 6 hours'),
      (8, 'Every 8 hours'),
      (12, 'Every 12 hours'),
      (24, 'Every day'),
      (168, 'Every week'),
    ];
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 6, bottom: 10),
              child: Text('How often?',
                  style: TextStyle(
                      fontWeight: FontWeight.w700, color: p.ink, fontSize: 16)),
            ),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                for (final (h, label) in options)
                  GestureDetector(
                    onTap: () => Navigator.pop(context, h),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 10),
                      decoration: BoxDecoration(
                        color: h == defaultHours
                            ? AppTheme.green
                            : p.tint(AppTheme.green),
                        borderRadius: BorderRadius.circular(AppTheme.radius),
                      ),
                      child: Text(label,
                          style: TextStyle(
                              color: h == defaultHours
                                  ? Colors.white
                                  : AppTheme.greenDark,
                              fontWeight: FontWeight.w700)),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
