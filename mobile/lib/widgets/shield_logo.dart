import 'package:flutter/material.dart';
import '../core/theme.dart';

/// The Aegis Health shield + pulse mark, drawn with CustomPaint so it stays
/// crisp at any size and matches the app icon.
class ShieldLogo extends StatelessWidget {
  final double size;
  final bool onDark;
  const ShieldLogo({super.key, this.size = 80, this.onDark = false});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: size,
      width: size,
      child: CustomPaint(painter: _ShieldPainter(onDark)),
    );
  }
}

/// Same shield, but the coral ECG line **continuously sweeps** like a live
/// heart monitor. Drop-in replacement for [ShieldLogo] wherever the logo is a
/// focal point (splash, auth, analysing).
class AnimatedShieldLogo extends StatefulWidget {
  final double size;
  final bool onDark;
  const AnimatedShieldLogo({super.key, this.size = 80, this.onDark = false});
  @override
  State<AnimatedShieldLogo> createState() => _AnimatedShieldLogoState();
}

class _AnimatedShieldLogoState extends State<AnimatedShieldLogo>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c =
      AnimationController(vsync: this, duration: const Duration(milliseconds: 1600))
        ..repeat();

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: widget.size,
      width: widget.size,
      child: AnimatedBuilder(
        animation: _c,
        builder: (_, __) =>
            CustomPaint(painter: _ShieldPainter(widget.onDark, _c.value)),
      ),
    );
  }
}

Path _shieldPath(double w, double h) {
  final cx = w / 2;
  return Path()
    ..moveTo(cx, h * 0.06)
    ..lineTo(w * 0.86, h * 0.24)
    ..lineTo(w * 0.86, h * 0.56)
    ..quadraticBezierTo(w * 0.86, h * 0.84, cx, h * 0.96)
    ..quadraticBezierTo(w * 0.14, h * 0.84, w * 0.14, h * 0.56)
    ..lineTo(w * 0.14, h * 0.24)
    ..close();
}

class _ShieldPainter extends CustomPainter {
  final bool onDark;
  final double? phase; // null = static pulse; 0..1 = animated ECG sweep
  _ShieldPainter(this.onDark, [this.phase]);

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width, h = size.height;
    final shield = _shieldPath(w, h);

    final fill = Paint()
      ..color = onDark
          ? Colors.white
          : AppTheme.green.withValues(alpha: 0.10);
    canvas.drawPath(shield, fill);

    if (!onDark) {
      final border = Paint()
        ..color = AppTheme.green
        ..style = PaintingStyle.stroke
        ..strokeWidth = w * 0.035
        ..strokeJoin = StrokeJoin.round;
      canvas.drawPath(shield, border);
    }

    if (phase == null) {
      _staticPulse(canvas, w, h);
    } else {
      _scrollingEcg(canvas, w, h, shield, phase!);
    }
  }

  void _staticPulse(Canvas canvas, double w, double h) {
    final midy = h * 0.50;
    final amp = h * 0.12;
    final pulse = Path()
      ..moveTo(w * 0.26, midy)
      ..lineTo(w * 0.40, midy)
      ..lineTo(w * 0.47, midy - amp)
      ..lineTo(w * 0.55, midy + amp * 1.25)
      ..lineTo(w * 0.62, midy - amp * 1.5)
      ..lineTo(w * 0.68, midy)
      ..lineTo(w * 0.74, midy);
    canvas.drawPath(pulse, _pulsePaint(w));
  }

  /// A repeating heartbeat that scrolls left continuously (live-monitor look),
  /// clipped to the shield so it stays inside.
  void _scrollingEcg(Canvas canvas, double w, double h, Path shield, double t) {
    // one beat: (x fraction of a beat, y in amplitude units; negative = up)
    const beat = <List<double>>[
      [0.00, 0], [0.16, 0], [0.20, -0.18], [0.24, 0], [0.38, 0],
      [0.42, 0.18], [0.46, -1.0], [0.50, 0.60], [0.54, 0], [0.64, -0.32],
      [0.72, 0], [1.00, 0],
    ];
    final midy = h * 0.50;
    final amp = h * 0.13;
    final period = w * 0.52;   // width of one beat
    final shift = t * period;  // continuous left scroll
    final path = Path();
    bool started = false;
    for (int n = -1; n <= 3; n++) {
      final x0 = n * period - shift;
      for (final p in beat) {
        final x = x0 + p[0] * period;
        final y = midy + p[1] * amp;
        if (!started) {
          path.moveTo(x, y);
          started = true;
        } else {
          path.lineTo(x, y);
        }
      }
    }
    canvas.save();
    canvas.clipPath(shield);
    // soft glow
    canvas.drawPath(
        path,
        Paint()
          ..color = AppTheme.coral.withValues(alpha: 0.35)
          ..style = PaintingStyle.stroke
          ..strokeWidth = w * 0.11
          ..strokeCap = StrokeCap.round
          ..strokeJoin = StrokeJoin.round
          ..maskFilter = MaskFilter.blur(BlurStyle.normal, w * 0.03));
    canvas.drawPath(path, _pulsePaint(w));
    canvas.restore();
  }

  Paint _pulsePaint(double w) => Paint()
    ..color = AppTheme.coral
    ..style = PaintingStyle.stroke
    ..strokeWidth = w * 0.05
    ..strokeCap = StrokeCap.round
    ..strokeJoin = StrokeJoin.round;

  @override
  bool shouldRepaint(covariant _ShieldPainter old) =>
      old.onDark != onDark || old.phase != phase;
}
