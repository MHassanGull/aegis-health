import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/notifications.dart';
import '../core/theme.dart';
import 'home_shell.dart';

/// Asks, in one place and with a plain explanation, for everything the app
/// needs to work reliably in the background: notifications, exact-time
/// alarms, and an exemption from battery optimisation.
///
/// Android will not hand any of this over silently — every one of these is a
/// real dialog the person has to answer, on every manufacturer's build of
/// Android, Samsung included. What this screen adds over letting each screen
/// ask piecemeal is asking for all of it up front, with a reason attached, so
/// a reminder or an assistant reply doesn't quietly fail somewhere later with
/// no explanation.
///
/// Shown once after the first sign-in on a fresh install. Reachable again any
/// time from Settings, since a person can decline here and change their mind,
/// or a phone can reset the battery exemption on its own after an update.
class PermissionsScreen extends StatefulWidget {
  /// True for the first-run flow: finishing replaces the whole stack with
  /// [HomeShell]. False when opened from Settings: finishing just pops back.
  final bool onboarding;
  const PermissionsScreen({super.key, this.onboarding = true});

  static const _seenKey = 'seen_permissions_v1';

  /// Whether this screen has already been shown once on this install.
  static Future<bool> alreadySeen() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_seenKey) ?? false;
  }

  /// Send the user to [HomeShell], by way of this screen the first time only.
  /// The one call site every successful sign-in (login, register, and an
  /// already-remembered session on launch) routes through.
  static Future<void> routeAfterAuth(BuildContext context) async {
    final seen = await alreadySeen();
    if (!context.mounted) return;
    final next =
        seen ? const HomeShell() : const PermissionsScreen(onboarding: true);
    Navigator.pushAndRemoveUntil(
        context, MaterialPageRoute(builder: (_) => next), (r) => false);
  }

  @override
  State<PermissionsScreen> createState() => _PermissionsScreenState();
}

class _PermissionsScreenState extends State<PermissionsScreen>
    with WidgetsBindingObserver {
  bool _notifGranted = false;
  bool _batteryExempt = false;
  bool _checking = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _refresh();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // The battery-exemption and notification dialogs are system screens the
    // user answers outside the app; re-check when we come back to the
    // foreground so the row updates without needing a manual refresh.
    if (state == AppLifecycleState.resumed) _refresh();
  }

  Future<void> _refresh() async {
    final notif = await Permission.notification.status;
    final battery = await Permission.ignoreBatteryOptimizations.status;
    if (!mounted) return;
    setState(() {
      _notifGranted = notif.isGranted;
      _batteryExempt = battery.isGranted;
      _checking = false;
    });
  }

  Future<void> _requestNotifications() async {
    await NotificationService.instance.requestPermission();
    await _refresh();
  }

  Future<void> _requestBattery() async {
    // This is the one Android setting that fixes "reminders stop after a
    // while" on almost every phone, Samsung included: it is the same standard
    // dialog on every manufacturer's build, unlike a vendor's own separate
    // autostart manager, which has no safe universal shortcut.
    await Permission.ignoreBatteryOptimizations.request();
    await _refresh();
  }

  Future<void> _finish() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(PermissionsScreen._seenKey, true);
    if (!mounted) return;
    if (widget.onboarding) {
      Navigator.pushAndRemoveUntil(context,
          MaterialPageRoute(builder: (_) => const HomeShell()), (r) => false);
    } else {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final p = Palette.of(context);
    final t = Theme.of(context).textTheme;

    return Scaffold(
      appBar: widget.onboarding
          ? null
          : AppBar(title: const Text('Notifications & battery')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(
              AppTheme.gutter, 24, AppTheme.gutter, 28),
          children: [
            Text('Set up reminders', style: t.displaySmall),
            const SizedBox(height: 10),
            Text(
                'Aegis reminds you to drink water, take medicine and re-check '
                'your risk, entirely on this device. Two phone settings make '
                'that reliable — Android will not turn them on by itself.',
                style: t.bodyMedium),
            const SizedBox(height: 30),
            _PermissionRow(
              title: 'Notifications',
              body: 'So a reminder actually appears when it is due.',
              granted: _notifGranted,
              busy: _checking,
              onTap: _requestNotifications,
            ),
            const SizedBox(height: 14),
            _PermissionRow(
              title: 'Unrestricted battery use',
              body: 'Stops the phone silently pausing reminders in the '
                  'background — the single most common reason they stop.',
              granted: _batteryExempt,
              busy: _checking,
              onTap: _requestBattery,
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: p.sunk,
                borderRadius: BorderRadius.circular(AppTheme.rControl),
              ),
              child: Text(
                  'On some phones (Xiaomi, Oppo, Vivo, Honor) there is also a '
                  'separate "Autostart" or "App launch" list in the phone\'s '
                  'own Settings or Security app. If reminders still stop '
                  'after a few days, add Aegis Health there too.',
                  style: t.bodySmall?.copyWith(height: 1.6)),
            ),
            const SizedBox(height: 32),
            FilledButton(
              onPressed: _finish,
              child: Text(widget.onboarding ? 'Continue' : 'Done'),
            ),
            if (widget.onboarding) ...[
              const SizedBox(height: 12),
              Center(
                child: TextButton(
                  onPressed: _finish,
                  child: Text('Skip for now',
                      style: t.bodySmall?.copyWith(color: p.subtle)),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _PermissionRow extends StatelessWidget {
  final String title;
  final String body;
  final bool granted;
  final bool busy;
  final VoidCallback onTap;
  const _PermissionRow({
    required this.title,
    required this.body,
    required this.granted,
    required this.busy,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final p = Palette.of(context);
    final t = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: p.card,
        borderRadius: BorderRadius.circular(AppTheme.rControl),
        border: Border.all(color: p.line),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            granted ? Icons.check_circle_rounded : Icons.circle_outlined,
            color: granted ? p.on(AppTheme.green) : p.subtle,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: t.titleSmall),
                const SizedBox(height: 3),
                Text(body, style: t.bodySmall),
              ],
            ),
          ),
          const SizedBox(width: 10),
          if (!busy)
            granted
                ? Text('On',
                    style: t.labelMedium?.copyWith(color: p.on(AppTheme.green)))
                : OutlinedButton(
                    style: OutlinedButton.styleFrom(
                        minimumSize: const Size(0, 36),
                        padding:
                            const EdgeInsets.symmetric(horizontal: 14)),
                    onPressed: onTap,
                    child: const Text('Allow'),
                  ),
        ],
      ),
    );
  }
}
