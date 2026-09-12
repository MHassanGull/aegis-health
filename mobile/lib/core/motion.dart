import 'dart:math' as math;
import 'package:flutter/material.dart';

/// The app's motion system.
///
/// One family of durations and one curve, so everything moves as though the
/// same hand made it. The vocabulary is print-derived: things are *laid down*
/// (a wipe), *set* (a rise into place), or *struck* (a press). Nothing floats,
/// pulses, bounces or loops for decoration.
class Motion {
  Motion._();

  static const Duration quick = Duration(milliseconds: 180);
  static const Duration base = Duration(milliseconds: 420);
  static const Duration slow = Duration(milliseconds: 700);

  /// Fast out, long settle — reads as weight rather than springiness.
  static const Curve ease = Cubic(0.16, 1, 0.3, 1);
  static const Curve enter = Cubic(0.22, 1, 0.36, 1);

  /// Delay for the nth item in a staggered sequence, capped so long lists
  /// never leave the reader waiting.
  static Duration stagger(int index, {int step = 70, int cap = 560}) =>
      Duration(milliseconds: math.min(index * step, cap));
}

/// Rises into place and fades in. The workhorse entrance.
class Rise extends StatefulWidget {
  final Widget child;
  final int index;
  final double distance;
  final Duration? delay;
  const Rise({
    super.key,
    required this.child,
    this.index = 0,
    this.distance = 18,
    this.delay,
  });

  @override
  State<Rise> createState() => _RiseState();
}

class _RiseState extends State<Rise> with SingleTickerProviderStateMixin {
  late final AnimationController _c =
      AnimationController(vsync: this, duration: Motion.base);

  @override
  void initState() {
    super.initState();
    final d = widget.delay ?? Motion.stagger(widget.index);
    Future.delayed(d, () {
      if (mounted) _c.forward();
    });
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = CurvedAnimation(parent: _c, curve: Motion.enter);
    return AnimatedBuilder(
      animation: t,
      builder: (context, child) => Opacity(
        opacity: t.value,
        child: Transform.translate(
          offset: Offset(0, widget.distance * (1 - t.value)),
          child: child,
        ),
      ),
      child: widget.child,
    );
  }
}

/// Laid down left-to-right behind a moving edge, the way ink meets paper.
/// Used for headline type and rules — the app's signature entrance.
class Wipe extends StatefulWidget {
  final Widget child;
  final Duration? delay;
  final Duration duration;
  final Axis axis;
  const Wipe({
    super.key,
    required this.child,
    this.delay,
    this.duration = Motion.slow,
    this.axis = Axis.horizontal,
  });

  @override
  State<Wipe> createState() => _WipeState();
}

class _WipeState extends State<Wipe> with SingleTickerProviderStateMixin {
  late final AnimationController _c =
      AnimationController(vsync: this, duration: widget.duration);

  @override
  void initState() {
    super.initState();
    Future.delayed(widget.delay ?? Duration.zero, () {
      if (mounted) _c.forward();
    });
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = CurvedAnimation(parent: _c, curve: Motion.ease);
    return AnimatedBuilder(
      animation: t,
      builder: (context, child) => ClipRect(
        child: Align(
          alignment: widget.axis == Axis.horizontal
              ? Alignment.centerLeft
              : Alignment.topCenter,
          widthFactor: widget.axis == Axis.horizontal
              ? t.value.clamp(0.001, 1.0)
              : null,
          heightFactor: widget.axis == Axis.vertical
              ? t.value.clamp(0.001, 1.0)
              : null,
          child: child,
        ),
      ),
      child: widget.child,
    );
  }
}

/// Counts a figure up to its value. Real instruments settle on a reading
/// rather than blinking it into existence.
class CountUp extends StatelessWidget {
  final double value;
  final int decimals;
  final TextStyle style;
  final Duration duration;
  const CountUp(
    this.value, {
    super.key,
    required this.style,
    this.decimals = 1,
    this.duration = Motion.slow,
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: value),
      duration: duration,
      curve: Motion.ease,
      builder: (_, v, __) => Text(v.toStringAsFixed(decimals), style: style),
    );
  }
}

/// Presses inward under the finger. Subtle — 2% — but it makes every tap feel
/// like it struck something physical.
class Press extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  const Press({super.key, required this.child, this.onTap});

  @override
  State<Press> createState() => _PressState();
}

class _PressState extends State<Press> {
  bool _down = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _down = true),
      onTapUp: (_) => setState(() => _down = false),
      onTapCancel: () => setState(() => _down = false),
      onTap: widget.onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedScale(
        scale: _down ? 0.98 : 1.0,
        duration: Motion.quick,
        curve: Motion.ease,
        child: widget.child,
      ),
    );
  }
}

/// A fine mechanical dot screen, drawn over a flat colour field.
///
/// This is a halftone — how flat ink is actually printed — so the field gains
/// texture without becoming a gradient. Very low contrast by design: it should
/// read as paper, not as a pattern.
class Halftone extends StatelessWidget {
  final double opacity;
  final double spacing;
  final double dotRadius;
  const Halftone({
    super.key,
    this.opacity = 0.06,
    this.spacing = 9,
    this.dotRadius = 1.0,
  });

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: CustomPaint(
        size: Size.infinite,
        painter: _HalftonePainter(opacity, spacing, dotRadius),
      ),
    );
  }
}

class _HalftonePainter extends CustomPainter {
  final double opacity;
  final double spacing;
  final double dotRadius;
  _HalftonePainter(this.opacity, this.spacing, this.dotRadius);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.white.withValues(alpha: opacity);
    // Offset every other row so the screen reads as a 45° rosette, the way a
    // real halftone is angled to avoid moiré.
    for (var y = 0.0, row = 0; y < size.height; y += spacing, row++) {
      final xOffset = row.isEven ? 0.0 : spacing / 2;
      for (var x = xOffset; x < size.width; x += spacing) {
        canvas.drawCircle(Offset(x, y), dotRadius, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _HalftonePainter old) =>
      old.opacity != opacity ||
      old.spacing != spacing ||
      old.dotRadius != dotRadius;
}

/// Page transition: the incoming page slides a short way and fades, the
/// outgoing one recedes slightly. Directional, so the stack stays legible.
class EditorialPageTransition extends PageTransitionsBuilder {
  const EditorialPageTransition();

  @override
  Widget buildTransitions<T>(
    PageRoute<T> route,
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    final inCurve = CurvedAnimation(parent: animation, curve: Motion.enter);
    final outCurve =
        CurvedAnimation(parent: secondaryAnimation, curve: Motion.enter);

    return FadeTransition(
      opacity: inCurve,
      child: SlideTransition(
        position: Tween(begin: const Offset(0.06, 0), end: Offset.zero)
            .animate(inCurve),
        child: SlideTransition(
          position: Tween(begin: Offset.zero, end: const Offset(-0.03, 0))
              .animate(outCurve),
          child: child,
        ),
      ),
    );
  }
}
