import 'package:flutter/material.dart';
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
      '7 to 8 hours of sleep helps regulate blood sugar and blood pressure.'),
  _Tip(Icons.monitor_heart_rounded, AppTheme.green, 'Know your numbers',
      'Check blood pressure regularly, high BP quietly harms both heart and kidneys.'),
];

class TipsScreen extends StatelessWidget {
  const TipsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final p = Palette.of(context);
    // Set as an numbered reference list, not a stack of illustrated cards.
    return Scaffold(
      appBar: AppBar(title: const Text('Guidance')),
      body: ListView.builder(
        padding: const EdgeInsets.fromLTRB(
            AppTheme.gutter, 4, AppTheme.gutter, 32),
        itemCount: _tips.length,
        itemBuilder: (context, i) {
          final t = _tips[i];
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 18),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: 30,
                      child: Text((i + 1).toString().padLeft(2, '0'),
                          style: AppType.mono.copyWith(color: t.color)),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(t.title, style: AppType.h2.copyWith(color: p.ink)),
                          const SizedBox(height: 6),
                          Text(t.body,
                              style: AppType.small
                                  .copyWith(color: p.subtle, height: 1.55)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              if (i < _tips.length - 1) Rule(),
            ],
          );
        },
      ),
    );
  }
}
