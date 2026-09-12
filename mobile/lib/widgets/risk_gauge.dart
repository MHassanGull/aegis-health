import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../core/theme.dart';

/// An animated circular risk gauge that fills up on display.
class RiskGauge extends StatelessWidget {
  final String title;
  final double percent; // 0-100
  final String tier;
  final IconData icon;
  final double size;

  const RiskGauge({
    super.key,
    required this.title,
    required this.percent,
    required this.tier,
    required this.icon,
    this.size = 132,
  });

  @override
  Widget build(BuildContext context) {
    final color = AppTheme.tierColor(tier);
    final p = Palette.of(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          height: size,
          width: size,
          child: TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: percent / 100),
            duration: const Duration(milliseconds: 1300),
            curve: Curves.easeOutCubic,
            builder: (context, value, _) {
              return CustomPaint(
                painter: _GaugePainter(value, color, p.line),
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(icon, color: color, size: 24),
                      const SizedBox(height: 2),
                      Text('${(value * 100).round()}%',
                          style: TextStyle(
                              fontSize: size * 0.21,
                              fontWeight: FontWeight.w800,
                              color: p.ink)),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 12),
        Text(title,
            style: TextStyle(
                fontWeight: FontWeight.w700, color: p.ink, fontSize: 15)),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
          decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(20)),
          child: Text('$tier risk',
              style: TextStyle(
                  color: color, fontWeight: FontWeight.w800, fontSize: 12.5)),
        ),
      ],
    );
  }
}

class _GaugePainter extends CustomPainter {
  final double fraction;
  final Color color;
  final Color trackColor;
  _GaugePainter(this.fraction, this.color, this.trackColor);

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = size.width / 2 - 9;
    const start = -math.pi / 2;
    final track = Paint()
      ..color = trackColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 14
      ..strokeCap = StrokeCap.round;
    canvas.drawCircle(center, radius, track);

    final rect = Rect.fromCircle(center: center, radius: radius);
    final arc = Paint()
      ..shader = SweepGradient(
        startAngle: 0,
        endAngle: 2 * math.pi,
        colors: [color.withValues(alpha: 0.65), color],
        transform: const GradientRotation(-math.pi / 2),
      ).createShader(rect)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 14
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(rect, start, 2 * math.pi * fraction.clamp(0.0, 1.0), false, arc);
  }

  @override
  bool shouldRepaint(covariant _GaugePainter old) =>
      old.fraction != fraction ||
      old.color != color ||
      old.trackColor != trackColor;
}
