import 'dart:math' as math;
import 'package:flutter/material.dart';

import '../core/motion.dart';
import '../core/theme.dart';

/// A cardiac monitor trace: the line is written left to right by a sweeping
/// head, and erased just ahead of it, exactly the way a bedside monitor
/// behaves. The head carries a small glow so the eye follows it.
///
/// This is not decoration borrowed from somewhere else. Reading a waveform is
/// what a health monitor does, and the app is about watching a number move, so
/// the same gesture opens the product.
class EcgLine extends StatefulWidget {
  final Color color;

  /// Height of the R spike as a fraction of the widget height.
  final double amplitude;

  /// Seconds for the head to cross the full width once.
  final double sweepSeconds;

  /// How many complete beats fit across the width.
  final double beatsAcross;

  final double strokeWidth;

  const EcgLine({
    super.key,
    this.color = AppTheme.coral,
    this.amplitude = 0.34,
    this.sweepSeconds = 2.4,
    this.beatsAcross = 2.2,
    this.strokeWidth = 2.4,
  });

  @override
  State<EcgLine> createState() => _EcgLineState();
}

class _EcgLineState extends State<EcgLine>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: Duration(milliseconds: (widget.sweepSeconds * 1000).round()),
  )..repeat();

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // A looping trace is exactly the kind of motion that makes some people
    // unwell, so when the system asks for reduced motion the waveform is drawn
    // complete and still.
    if (Motion.reduced(context)) {
      return RepaintBoundary(
        child: CustomPaint(
          size: Size.infinite,
          painter: _EcgPainter(
            sweep: 1,
            color: widget.color,
            amplitude: widget.amplitude,
            beats: widget.beatsAcross,
            strokeWidth: widget.strokeWidth,
            still: true,
          ),
        ),
      );
    }

    return RepaintBoundary(
      child: AnimatedBuilder(
        animation: _c,
        builder: (context, _) => CustomPaint(
          size: Size.infinite,
          painter: _EcgPainter(
            sweep: _c.value,
            color: widget.color,
            amplitude: widget.amplitude,
            beats: widget.beatsAcross,
            strokeWidth: widget.strokeWidth,
            still: false,
          ),
        ),
      ),
    );
  }
}

class _EcgPainter extends CustomPainter {
  final double sweep; // 0..1, position of the writing head
  final Color color;
  final double amplitude;
  final double beats;
  final double strokeWidth;
  final bool still;

  _EcgPainter({
    required this.sweep,
    required this.color,
    required this.amplitude,
    required this.beats,
    required this.strokeWidth,
    required this.still,
  });

  /// One cardiac cycle, as (position through the beat, height in amplitude
  /// units, negative is up). Shaped like a real lead II trace: a small P wave,
  /// the sharp QRS complex, then the broader T wave.
  static const List<List<double>> _beat = [
    [0.00, 0.0],
    [0.12, 0.0],
    [0.17, -0.18], // P wave
    [0.22, 0.0],
    [0.34, 0.0],
    [0.37, 0.12], // Q
    [0.41, -1.00], // R, the spike
    [0.45, 0.42], // S
    [0.49, 0.0],
    [0.62, -0.30], // T wave
    [0.72, 0.0],
    [1.00, 0.0],
  ];

  Path _wave(Size size) {
    final mid = size.height / 2;
    final amp = size.height * amplitude;
    final period = size.width / beats;
    final path = Path()..moveTo(0, mid);
    for (var n = 0; n < beats.ceil() + 1; n++) {
      final x0 = n * period;
      for (final pt in _beat) {
        path.lineTo(x0 + pt[0] * period, mid + pt[1] * amp);
      }
    }
    return path;
  }

  @override
  void paint(Canvas canvas, Size size) {
    if (size.width <= 0 || size.height <= 0) return;

    final baseline = Paint()
      ..color = color.withValues(alpha: 0.16)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    canvas.drawLine(
        Offset(0, size.height / 2), Offset(size.width, size.height / 2), baseline);

    final wave = _wave(size);

    final stroke = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    if (still) {
      canvas.drawPath(wave, stroke);
      return;
    }

    final headX = sweep * size.width;

    // Everything behind the head is visible; a short window ahead of it is
    // cleared, which is what produces the monitor's rolling gap.
    canvas.save();
    canvas.clipRect(Rect.fromLTWH(0, 0, headX, size.height));

    // The trail fades out behind the head rather than ending abruptly.
    final fade = ui_gradientShader(size, headX, color);
    canvas.drawPath(
        wave,
        Paint()
          ..shader = fade
          ..style = PaintingStyle.stroke
          ..strokeWidth = strokeWidth
          ..strokeCap = StrokeCap.round
          ..strokeJoin = StrokeJoin.round);
    canvas.restore();

    // The writing head: a soft glow and a solid dot, sitting on the waveform.
    final y = _yAt(size, sweep);
    canvas.drawCircle(
        Offset(headX, y),
        strokeWidth * 3.2,
        Paint()
          ..color = color.withValues(alpha: 0.28)
          ..maskFilter = MaskFilter.blur(BlurStyle.normal, strokeWidth * 2));
    canvas.drawCircle(
        Offset(headX, y), strokeWidth * 1.15, Paint()..color = color);
  }

  /// Height of the waveform at a given fraction across the width.
  double _yAt(Size size, double t) {
    final mid = size.height / 2;
    final amp = size.height * amplitude;
    final within = (t * beats) % 1.0;
    for (var i = 0; i < _beat.length - 1; i++) {
      final a = _beat[i], b = _beat[i + 1];
      if (within >= a[0] && within <= b[0]) {
        final span = (b[0] - a[0]);
        final k = span == 0 ? 0.0 : (within - a[0]) / span;
        return mid + (a[1] + (b[1] - a[1]) * k) * amp;
      }
    }
    return mid;
  }

  static Shader ui_gradientShader(Size size, double headX, Color color) {
    final start = math.max(0.0, headX - size.width * 0.55);
    return LinearGradient(
      colors: [color.withValues(alpha: 0.0), color],
      stops: const [0.0, 1.0],
    ).createShader(Rect.fromLTWH(start, 0, math.max(1.0, headX - start), size.height));
  }

  @override
  bool shouldRepaint(covariant _EcgPainter old) =>
      old.sweep != sweep || old.color != color || old.still != still;
}
