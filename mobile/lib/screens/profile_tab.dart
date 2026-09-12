import 'package:flutter/material.dart';

import '../core/api_client.dart';
import '../core/theme.dart';
import '../widgets/shield_logo.dart';
import '../widgets/user_avatar.dart';
import 'edit_profile_screen.dart';
import 'settings_screen.dart';

class ProfileTab extends StatelessWidget {
  const ProfileTab({super.key});

  @override
  Widget build(BuildContext context) {
    final p = Palette.of(context);
    final name = ApiClient.instance.username;
    final display = name.isEmpty ? '?' : name[0].toUpperCase() + name.substring(1);
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 18, 20, 28),
        children: [
          Text('Profile',
              style: TextStyle(
                  fontSize: 26, fontWeight: FontWeight.w800, color: p.ink)),
          const SizedBox(height: 20),
          SoftCard(
            child: Row(children: [
              const UserAvatar(radius: 32),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(display,
                        style: TextStyle(
                            fontSize: 19,
                            fontWeight: FontWeight.w800,
                            color: p.ink)),
                    Text('Aegis Health member',
                        style: TextStyle(color: p.subtle)),
                  ],
                ),
              ),
            ]),
          ),
          const SizedBox(height: 16),
          _NavCard(
            icon: Icons.edit_rounded,
            title: 'Edit Profile',
            subtitle: 'Name, email & health basics',
            onTap: () => Navigator.push(context,
                MaterialPageRoute(builder: (_) => const EditProfileScreen())),
          ),
          const SizedBox(height: 12),
          _NavCard(
            icon: Icons.settings_rounded,
            title: 'Settings',
            subtitle: 'Dark mode, about, log out',
            onTap: () => Navigator.push(context,
                MaterialPageRoute(builder: (_) => const SettingsScreen())),
          ),
          const SizedBox(height: 16),
          SoftCard(
            child: Row(children: [
              const ShieldLogo(size: 44),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('About Aegis Health',
                        style: TextStyle(
                            fontWeight: FontWeight.w800, color: p.ink)),
                    const SizedBox(height: 4),
                    Text(
                        'AI-powered preventive screening for diabetes & kidney disease — no blood test.',
                        style: TextStyle(
                            color: p.subtle, fontSize: 13, height: 1.4)),
                  ],
                ),
              ),
            ]),
          ),
        ],
      ),
    );
  }
}

class _NavCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  const _NavCard(
      {required this.icon,
      required this.title,
      required this.subtitle,
      required this.onTap});
  @override
  Widget build(BuildContext context) {
    final p = Palette.of(context);
    return SoftCard(
      onTap: onTap,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(children: [
        Container(
          height: 44, width: 44,
          decoration: BoxDecoration(
              color: p.tint(AppTheme.green),
              borderRadius: BorderRadius.circular(12)),
          child: Icon(icon, color: AppTheme.green),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title,
                  style: TextStyle(fontWeight: FontWeight.w700, color: p.ink)),
              Text(subtitle, style: TextStyle(color: p.subtle, fontSize: 12.5)),
            ],
          ),
        ),
        Icon(Icons.chevron_right_rounded, color: p.subtle),
      ]),
    );
  }
}
