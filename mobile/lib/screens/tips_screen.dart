import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../core/theme.dart';

class _Tip {
  final IconData icon;
  final Color color;
  final String title;
  final String body;
  const _Tip(this.icon, this.color, this.title, this.body);
}

const _tips = [
  _Tip(Icons.directions_walk_rounded, AppTheme.green, 'Move every day',
      '30 minutes of brisk walking on most days improves insulin sensitivity and lowers diabetes risk.'),
  _Tip(Icons.local_drink_rounded, Color(0xFF3DA5D9), 'Stay hydrated',
      'Drinking enough water supports kidney function. Aim for pale-yellow urine as a simple guide.'),
  _Tip(Icons.restaurant_rounded, AppTheme.coral, 'Eat the rainbow',
      'Fill half your plate with vegetables and fruit. Fibre slows sugar spikes and protects your heart.'),
  _Tip(Icons.no_food_rounded, AppTheme.amber, 'Cut sugary drinks',
      'Sodas and sweet juices are the biggest hidden sugar source. Swap for water or unsweetened tea.'),
  _Tip(Icons.smoke_free_rounded, AppTheme.high, 'Avoid smoking',
      'Smoking damages blood vessels in the kidneys and worsens diabetes complications.'),
  _Tip(Icons.bedtime_rounded, Color(0xFF7E57A6), 'Sleep well',
      '7–8 hours of sleep helps regulate blood sugar and blood pressure.'),
  _Tip(Icons.monitor_heart_rounded, AppTheme.green, 'Know your numbers',
      'Check blood pressure regularly — high BP quietly harms both heart and kidneys.'),
];

class TipsScreen extends StatelessWidget {
  const TipsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final p = Palette.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Health Tips')),
      body: ListView.builder(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
        itemCount: _tips.length,
        itemBuilder: (context, i) {
          final t = _tips[i];
          return Padding(
            padding: const EdgeInsets.only(bottom: 14),
            child: SoftCard(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 48, width: 48,
                    decoration: BoxDecoration(
                        color: t.color.withValues(alpha: 0.14),
                        borderRadius: BorderRadius.circular(14)),
                    child: Icon(t.icon, color: t.color),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(t.title,
                            style: TextStyle(
                                fontWeight: FontWeight.w800,
                                color: p.ink,
                                fontSize: 15.5)),
                        const SizedBox(height: 4),
                        Text(t.body,
                            style: TextStyle(
                                color: p.subtle, height: 1.4, fontSize: 13.5)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ).animate().fadeIn(delay: (i * 80).ms).moveY(begin: 12, end: 0);
        },
      ),
    );
  }
}
