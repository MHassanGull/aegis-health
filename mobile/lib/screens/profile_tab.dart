import 'package:flutter/material.dart';

import '../core/api_client.dart';
import '../core/theme.dart';
import '../widgets/user_avatar.dart';
import 'edit_profile_screen.dart';
import 'settings_screen.dart';

class ProfileTab extends StatelessWidget {
  const ProfileTab({super.key});

  @override
  Widget build(BuildContext context) {
    final p = Palette.of(context);
    final name = ApiClient.instance.username;
    final display =
        name.isEmpty ? '?' : name[0].toUpperCase() + name.substring(1);

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(
            AppTheme.gutter, 18, AppTheme.gutter, 32),
        children: [
          Text('Profile', style: AppType.display.copyWith(color: p.ink)),
          const SizedBox(height: 14),
          Rule(),
          const SizedBox(height: 26),

          // ---- Identity ----------------------------------------------------
          Row(children: [
            const UserAvatar(radius: 26),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(display, style: AppType.h1.copyWith(color: p.ink)),
                  const SizedBox(height: 3),
                  Text('Signed in',
                      style: AppType.label.copyWith(color: p.subtle)),
                ],
              ),
            ),
          ]),
          const SizedBox(height: 32),

          // ---- Navigation --------------------------------------------------
          const SectionLabel('Account'),
          _NavRow(
            title: 'Personal details',
            meta: 'Name, photo, height and weight',
            onTap: () => Navigator.push(context,
                MaterialPageRoute(builder: (_) => const EditProfileScreen())),
          ),
          _NavRow(
            title: 'Settings',
            meta: 'Appearance, server, sign out',
            onTap: () => Navigator.push(context,
                MaterialPageRoute(builder: (_) => const SettingsScreen())),
            last: true,
          ),
          const SizedBox(height: 34),

          // ---- Colophon ----------------------------------------------------
          const SectionLabel('About'),
          Text(
              'Aegis estimates the future risk of type 2 diabetes and chronic '
              'kidney disease from everyday habits, using a multi-task neural '
              'network trained on the CDC BRFSS 2015 survey.',
              style: AppType.small.copyWith(color: p.subtle, height: 1.6)),
          const SizedBox(height: 20),
          _Spec('Version', '2.0.0', p),
          _Spec('Model', 'Multi-task MLP · 19 inputs', p),
          _Spec('Data', 'CDC BRFSS 2015 · 253,155 records', p),
          _Spec('Metrics', 'ROC-AUC 0.82 / 0.79 · recall 0.84 / 0.87', p),
        ],
      ),
    );
  }
}

/// A key/value line. Label left, value right in the monospace face, so the
/// column reads like a specification sheet.
class _Spec extends StatelessWidget {
  final String label;
  final String value;
  final Palette p;
  const _Spec(this.label, this.value, this.p);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 11),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 80,
                child: Text(label,
                    style: AppType.label.copyWith(color: p.subtle)),
              ),
              Expanded(
                child: Text(value,
                    style: AppType.mono.copyWith(color: p.ink, fontSize: 12)),
              ),
            ],
          ),
        ),
        Rule(),
      ],
    );
  }
}

class _NavRow extends StatelessWidget {
  final String title;
  final String meta;
  final VoidCallback onTap;
  final bool last;
  const _NavRow({
    required this.title,
    required this.meta,
    required this.onTap,
    this.last = false,
  });

  @override
  Widget build(BuildContext context) {
    final p = Palette.of(context);
    return Column(
      children: [
        InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 15),
            child: Row(children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: AppType.h2.copyWith(color: p.ink)),
                    const SizedBox(height: 2),
                    Text(meta,
                        style: AppType.small
                            .copyWith(color: p.subtle, fontSize: 12.5)),
                  ],
                ),
              ),
              Icon(Icons.arrow_forward, size: 16, color: p.subtle),
            ]),
          ),
        ),
        if (!last) Rule(),
      ],
    );
  }
}
