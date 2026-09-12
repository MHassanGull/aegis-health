import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../core/api_client.dart';
import '../core/links.dart';
import '../core/motion.dart';
import '../core/theme.dart';
import '../widgets/shield_logo.dart';
import '../widgets/user_avatar.dart';
import 'questionnaire_screen.dart';
import 'edit_profile_screen.dart';
import 'tips_screen.dart';
import 'model_screen.dart';
import 'reminders_screen.dart';
import 'result_screen.dart';

class HomeTab extends StatefulWidget {
  const HomeTab({super.key});
  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {
  late Future<List<dynamic>> _history;

  @override
  void initState() {
    super.initState();
    _history = ApiClient.instance.history().catchError((_) => <dynamic>[]);
  }

  @override
  Widget build(BuildContext context) {
    final p = Palette.of(context);
    final name = _cap(ApiClient.instance.username);

    // Sections manage their own gutters so colour fields can run edge to edge.
    return SafeArea(
      bottom: false,
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          _Masthead(),
          const SizedBox(height: 30),

          // ---- Name, set at poster scale ----------------------------------
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppTheme.gutter),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wipe(
                  delay: Duration.zero,
                  child: Text(name,
                      style: AppType.poster.copyWith(color: p.ink)),
                ),
                const SizedBox(height: 14),
                Row(children: [
                  Wipe(
                    delay: const Duration(milliseconds: 160),
                    duration: Motion.base,
                    child:
                        Container(width: 28, height: 3, color: AppTheme.coral),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Rise(
                      delay: const Duration(milliseconds: 180),
                      distance: 8,
                      child: Text(
                          'Risk is not fixed. Measure it, then move it.',
                          style: AppType.small.copyWith(color: p.subtle)),
                    ),
                  ),
                ]),
              ],
            ),
          ),
          const SizedBox(height: 28),

          // ---- Full-bleed green field: the one action -----------------------
          const Rise(
              delay: Duration(milliseconds: 90),
              distance: 26,
              child: _CheckField()),

          // ---- Dark data band: last reading --------------------------------
          FutureBuilder<List<dynamic>>(
            future: _history,
            builder: (context, snap) {
              final items = (snap.data ?? []).cast<Map<String, dynamic>>();
              if (items.isEmpty) return const SizedBox(height: 30);
              return _LastReadingBand(items.first);
            },
          ),

          // ---- Tools --------------------------------------------------------
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppTheme.gutter),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const _HeavyLabel('Tools'),
                _ToolRow(
                  index: 1,
                  icon: Icons.notifications_none_rounded,
                  title: 'Health reminders',
                  meta: 'Water, meals, movement, medicine',
                  accent: AppTheme.coral,
                  onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const RemindersScreen())),
                ),
                _ToolRow(
                  index: 2,
                  icon: Icons.account_tree_outlined,
                  title: 'Under the hood',
                  meta: 'The network, the data, the scores',
                  accent: AppTheme.green,
                  onTap: () => Navigator.push(context,
                      MaterialPageRoute(builder: (_) => const ModelScreen())),
                ),
                _ToolRow(
                  index: 3,
                  icon: Icons.menu_book_outlined,
                  title: 'Health guidance',
                  meta: 'Reading on both conditions',
                  accent: AppTheme.amber,
                  onTap: () => Navigator.push(context,
                      MaterialPageRoute(builder: (_) => const TipsScreen())),
                ),
                _ToolRow(
                  index: 4,
                  icon: Icons.place_outlined,
                  title: 'Clinics nearby',
                  meta: 'Opens in Maps',
                  accent: AppTheme.high,
                  onTap: openDoctorsNearby,
                  last: true,
                ),
              ],
            ),
          ),
          const SizedBox(height: 36),

          // ---- Colophon: inverted footer, edge to edge ----------------------
          Container(
            width: double.infinity,
            color: p.isDark ? AppTheme.panelDark : AppTheme.panel,
            padding: const EdgeInsets.fromLTRB(
                AppTheme.gutter, 28, AppTheme.gutter, 36),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Trained on',
                    style: AppType.label.copyWith(
                        color: Colors.white.withValues(alpha: 0.45))),
                const SizedBox(height: 10),
                Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      TweenAnimationBuilder<double>(
                        tween: Tween(begin: 0, end: 253155),
                        duration: const Duration(milliseconds: 700),
                        curve: Motion.ease,
                        builder: (_, v, __) => Text(_grouped(v.round()),
                            style: AppType.figure
                                .copyWith(color: Colors.white, fontSize: 40)),
                      ),
                      const SizedBox(width: 10),
                      Text('people',
                          style: AppType.label.copyWith(
                              color: AppTheme.green, letterSpacing: 1.4)),
                    ]),
                const SizedBox(height: 18),
                Text(
                    'CDC Behavioral Risk Factor Surveillance System, 2015. '
                    'Aegis is an educational screening aid. It does not '
                    'diagnose, and it does not replace a clinician.',
                    style: AppType.small.copyWith(
                        color: Colors.white.withValues(alpha: 0.55),
                        fontSize: 12,
                        height: 1.6)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _cap(String s) =>
      s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);

  static String _grouped(int n) {
    final d = n.toString();
    final b = StringBuffer();
    for (var i = 0; i < d.length; i++) {
      if (i > 0 && (d.length - i) % 3 == 0) b.write(',');
      b.write(d[i]);
    }
    return b.toString();
  }
}

class _Masthead extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final p = Palette.of(context);
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(AppTheme.gutter, 10, AppTheme.gutter, 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(children: [
                const ShieldLogo(size: 18),
                const SizedBox(width: 8),
                Text('Aegis',
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(letterSpacing: -0.2)),
              ]),
              GestureDetector(
                onTap: () => Navigator.push(context,
                    MaterialPageRoute(builder: (_) => const EditProfileScreen())),
                child: const UserAvatar(radius: 16),
              ),
            ],
          ),
        ),
        Rule(),
      ],
    );
  }
}

/// The primary action as a full-bleed colour field. Running to the screen
/// edges is what makes it read as a poster panel rather than a card.
class _CheckField extends StatelessWidget {
  const _CheckField();

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(
            child: ColoredBox(
                color: AppTheme.green, child: const Halftone())),
        Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(
          AppTheme.gutter, 26, AppTheme.gutter, 26),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Text('Health check',
                style: AppType.label.copyWith(
                    color: Colors.white.withValues(alpha: 0.75),
                    letterSpacing: 2)),
            const SizedBox(width: 12),
            Expanded(
                child: Container(
                    height: AppTheme.hair,
                    color: Colors.white.withValues(alpha: 0.35))),
          ]),
          const SizedBox(height: 20),
          const Text('Know your risk\nbefore it starts.',
              style: TextStyle(
                  fontFamily: AppTheme.display,
                  color: Colors.white,
                  fontSize: 34,
                  height: 1.06,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -1.2)),
          const SizedBox(height: 22),
          Row(children: [
            _spec('19', 'questions'),
            const SizedBox(width: 26),
            _spec('2', 'minutes'),
            const SizedBox(width: 26),
            _spec('0', 'blood tests'),
          ]),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: AppTheme.greenDark,
                minimumSize: const Size.fromHeight(52),
              ),
              onPressed: () {
                HapticFeedback.selectionClick();
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const QuestionnaireScreen()));
              },
              child: const Text('Start my check'),
            ),
          ),
        ],
      ),
        ),
      ],
    );
  }

  Widget _spec(String value, String label) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(value,
              style: const TextStyle(
                  fontFamily: AppTheme.mono,
                  color: Colors.white,
                  fontSize: 26,
                  height: 1,
                  fontWeight: FontWeight.w500)),
          const SizedBox(height: 4),
          Text(label,
              style: AppType.label.copyWith(
                  color: Colors.white.withValues(alpha: 0.7), fontSize: 9)),
        ],
      );
}

/// The most recent reading on a near-black band: the app's hardest contrast,
/// reserved for the numbers that matter most.
class _LastReadingBand extends StatelessWidget {
  final Map<String, dynamic> a;
  const _LastReadingBand(this.a);

  @override
  Widget build(BuildContext context) {
    final p = Palette.of(context);
    final dia = ((a['diabetes_risk'] as num) * 100).toDouble();
    final kid = ((a['kidney_risk'] as num) * 100).toDouble();

    return Container(
      width: double.infinity,
      color: p.isDark ? AppTheme.panelDark : AppTheme.panel,
      padding: const EdgeInsets.fromLTRB(
          AppTheme.gutter, 22, AppTheme.gutter, 22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Text('Your last check',
                style: AppType.label.copyWith(
                    color: Colors.white.withValues(alpha: 0.45),
                    letterSpacing: 2)),
            const Spacer(),
            GestureDetector(
              onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => ResultScreen(
                          result: a['result'] as Map<String, dynamic>))),
              child: Row(children: [
                Text('Open',
                    style: AppType.label.copyWith(color: AppTheme.green)),
                const SizedBox(width: 6),
                const Icon(Icons.arrow_forward,
                    size: 13, color: AppTheme.green),
              ]),
            ),
          ]),
          const SizedBox(height: 18),
          Row(children: [
            _reading('Diabetes', dia, AppTheme.green),
            const SizedBox(width: 34),
            _reading('Kidney', kid, AppTheme.coral),
          ]),
        ],
      ),
    );
  }

  Widget _reading(String label, double v, Color color) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                CountUp(v,
                    style: AppType.figure
                        .copyWith(color: Colors.white, fontSize: 38)),
                Text('%',
                    style: AppType.mono.copyWith(
                        color: Colors.white.withValues(alpha: 0.5),
                        fontSize: 14)),
              ]),
          const SizedBox(height: 6),
          Row(children: [
            Container(width: 8, height: 8, color: color),
            const SizedBox(width: 6),
            Text(label,
                style: AppType.label.copyWith(
                    color: Colors.white.withValues(alpha: 0.6), fontSize: 9)),
          ]),
        ],
      );
}

/// Section label carried on a heavy rule rather than a hairline.
class _HeavyLabel extends StatelessWidget {
  final String text;
  const _HeavyLabel(this.text);

  @override
  Widget build(BuildContext context) {
    final p = Palette.of(context);
    return Padding(
      padding: const EdgeInsets.only(top: 30, bottom: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(text, style: Theme.of(context).textTheme.headlineSmall),
        ],
      ),
    );
  }
}

/// A tool entry: index numeral, title block, accent tick. The numeral is the
/// graphic element that gives the list rhythm.
class _ToolRow extends StatelessWidget {
  final int index;
  final IconData icon;
  final String title;
  final String meta;
  final Color accent;
  final VoidCallback onTap;
  final bool last;
  const _ToolRow({
    required this.index,
    required this.icon,
    required this.title,
    required this.meta,
    required this.accent,
    required this.onTap,
    this.last = false,
  });

  @override
  Widget build(BuildContext context) {
    final p = Palette.of(context);
    return Rise(
      delay: Duration(milliseconds: 140 + index * 35),
      distance: 14,
      child: Column(
      children: [
        Press(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                IconChip(icon, color: accent, size: 42),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title,
                          style: AppType.h2
                              .copyWith(color: p.ink, fontSize: 17)),
                      const SizedBox(height: 3),
                      Text(meta,
                          style: AppType.small
                              .copyWith(color: p.subtle, fontSize: 12.5)),
                    ],
                  ),
                ),
                Icon(Icons.chevron_right_rounded, size: 20, color: p.subtle),
              ],
            ),
          ),
        ),
        if (!last) Rule(),
      ],
      ),
    );
  }
}
