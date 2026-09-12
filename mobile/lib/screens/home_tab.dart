import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../core/api_client.dart';
import '../core/links.dart';
import '../core/theme.dart';
import '../widgets/user_avatar.dart';
import 'questionnaire_screen.dart';
import 'edit_profile_screen.dart';
import 'tips_screen.dart';
import 'model_screen.dart';
import 'reminders_screen.dart';

class HomeTab extends StatelessWidget {
  const HomeTab({super.key});

  @override
  Widget build(BuildContext context) {
    final p = Palette.of(context);
    final name = _cap(ApiClient.instance.username);
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Hello,',
                      style: TextStyle(color: p.subtle, fontSize: 15)),
                  Text(name,
                      style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                          color: p.ink)),
                ],
              ),
              GestureDetector(
                onTap: () => Navigator.push(context,
                    MaterialPageRoute(builder: (_) => const EditProfileScreen())),
                child: const UserAvatar(radius: 24),
              ),
            ],
          ).animate().fadeIn(duration: 350.ms),
          const SizedBox(height: 22),
          const _HeroCard().animate().fadeIn(delay: 100.ms).moveY(begin: 16, end: 0),
          const SizedBox(height: 18),
          Row(children: [
            Expanded(
              child: _ActionTile(
                icon: Icons.location_on_rounded,
                color: AppTheme.coral,
                title: 'Find Doctors',
                subtitle: 'Clinics near you',
                onTap: openDoctorsNearby,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _ActionTile(
                icon: Icons.menu_book_rounded,
                color: AppTheme.amber,
                title: 'Health Tips',
                subtitle: 'Stay healthy',
                onTap: () => Navigator.push(context,
                    MaterialPageRoute(builder: (_) => const TipsScreen())),
              ),
            ),
          ]),
          const SizedBox(height: 18),
          const _RemindersBanner().animate().fadeIn(delay: 130.ms),
          const SizedBox(height: 12),
          const _ModelBanner().animate().fadeIn(delay: 180.ms),
          const SizedBox(height: 22),
          Text('How it works',
              style: TextStyle(
                  fontSize: 17, fontWeight: FontWeight.w800, color: p.ink)),
          const SizedBox(height: 12),
          const Row(children: [
            Expanded(child: _StepMini(Icons.edit_note_rounded, '1. Answer', 'A few quick questions')),
            SizedBox(width: 12),
            Expanded(child: _StepMini(Icons.psychology_rounded, '2. Analyse', 'AI checks your risk')),
            SizedBox(width: 12),
            Expanded(child: _StepMini(Icons.shield_moon_rounded, '3. Protect', 'See what to change')),
          ]),
          const SizedBox(height: 22),
          _TipCard(p),
        ],
      ),
    );
  }

  String _cap(String s) => s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);
}

class _HeroCard extends StatelessWidget {
  const _HeroCard();
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: AppTheme.heroGradient,
        borderRadius: BorderRadius.circular(26),
        boxShadow: [
          BoxShadow(
              color: AppTheme.green.withValues(alpha: 0.30),
              blurRadius: 24,
              offset: const Offset(0, 10)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Your health check',
              style: TextStyle(
                  color: Colors.white, fontSize: 22, fontWeight: FontWeight.w800)),
          const SizedBox(height: 8),
          Text(
              'Find your future risk of diabetes & kidney disease — no blood test, 2 minutes.',
              style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.92), height: 1.45)),
          const SizedBox(height: 18),
          FilledButton.icon(
            style: FilledButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: AppTheme.greenDark,
              minimumSize: const Size.fromHeight(52),
            ),
            onPressed: () {
              HapticFeedback.mediumImpact();
              Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const QuestionnaireScreen()));
            },
            icon: const Icon(Icons.play_arrow_rounded),
            label: const Text('Start Health Check'),
          ),
        ],
      ),
    );
  }
}

class _RemindersBanner extends StatelessWidget {
  const _RemindersBanner();
  @override
  Widget build(BuildContext context) {
    final p = Palette.of(context);
    return SoftCard(
      onTap: () => Navigator.push(context,
          MaterialPageRoute(builder: (_) => const RemindersScreen())),
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            height: 50,
            width: 50,
            decoration: BoxDecoration(
                gradient: AppTheme.coralGradient,
                borderRadius: BorderRadius.circular(15)),
            child: const Icon(Icons.notifications_active_rounded,
                color: Colors.white),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Health Reminders',
                    style: TextStyle(
                        fontWeight: FontWeight.w800,
                        color: p.ink,
                        fontSize: 15)),
                const SizedBox(height: 2),
                Text('Water, meals, movement, meds — never forget',
                    style: TextStyle(color: p.subtle, fontSize: 12.5)),
              ],
            ),
          ),
          Icon(Icons.chevron_right_rounded, color: p.subtle),
        ],
      ),
    );
  }
}

class _ModelBanner extends StatelessWidget {
  const _ModelBanner();
  @override
  Widget build(BuildContext context) {
    final p = Palette.of(context);
    return SoftCard(
      onTap: () => Navigator.push(context,
          MaterialPageRoute(builder: (_) => const ModelScreen())),
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            height: 50,
            width: 50,
            decoration: BoxDecoration(
                gradient: AppTheme.heroGradient,
                borderRadius: BorderRadius.circular(15)),
            child: const Icon(Icons.hub_rounded, color: Colors.white),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Under the Hood',
                    style: TextStyle(
                        fontWeight: FontWeight.w800,
                        color: p.ink,
                        fontSize: 15)),
                const SizedBox(height: 2),
                Text('See the neural network, dataset & accuracy',
                    style: TextStyle(color: p.subtle, fontSize: 12.5)),
              ],
            ),
          ),
          Icon(Icons.chevron_right_rounded, color: p.subtle),
        ],
      ),
    );
  }
}

class _ActionTile extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  const _ActionTile(
      {required this.icon,
      required this.color,
      required this.title,
      required this.subtitle,
      required this.onTap});
  @override
  Widget build(BuildContext context) {
    final p = Palette.of(context);
    return SoftCard(
      onTap: onTap,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
              radius: 20,
              backgroundColor: color.withValues(alpha: 0.14),
              child: Icon(icon, color: color, size: 22)),
          const SizedBox(height: 12),
          Text(title,
              style: TextStyle(fontWeight: FontWeight.w700, color: p.ink)),
          Text(subtitle,
              style: TextStyle(color: p.subtle, fontSize: 12.5)),
        ],
      ),
    );
  }
}

class _StepMini extends StatelessWidget {
  final IconData icon;
  final String title;
  final String body;
  const _StepMini(this.icon, this.title, this.body);
  @override
  Widget build(BuildContext context) {
    final p = Palette.of(context);
    return SoftCard(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppTheme.green, size: 24),
          const SizedBox(height: 10),
          Text(title,
              style: TextStyle(
                  fontWeight: FontWeight.w700, color: p.ink, fontSize: 13)),
          const SizedBox(height: 2),
          Text(body, style: TextStyle(color: p.subtle, fontSize: 11)),
        ],
      ),
    );
  }
}

class _TipCard extends StatelessWidget {
  final Palette p;
  const _TipCard(this.p);
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
          color: p.tint(AppTheme.coral),
          borderRadius: BorderRadius.circular(20)),
      child: Row(children: [
        const Icon(Icons.lightbulb_rounded, color: AppTheme.coral),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
              'Tip: 30 minutes of walking a day can measurably lower your diabetes risk.',
              style: TextStyle(color: p.ink, fontSize: 13.5, height: 1.4)),
        ),
      ]),
    );
  }
}
