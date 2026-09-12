import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/material.dart';

import '../core/theme.dart';
import 'shield_logo.dart';

/// A premium animated backdrop for the auth screens: a slowly shifting gradient
/// with soft floating colour orbs behind a frosted-glass content area.
class AuthScaffold extends StatefulWidget {
  final Widget child;
  final Widget? leading; // optional top-left control (e.g. a back button)
  const AuthScaffold({super.key, required this.child, this.leading});
  @override
  State<AuthScaffold> createState() => _AuthScaffoldState();
}

class _AuthScaffoldState extends State<AuthScaffold>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c =
      AnimationController(vsync: this, duration: const Duration(seconds: 16))
        ..repeat();

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final p = Palette.of(context);
    final base = p.isDark
        ? [const Color(0xFF0E1714), const Color(0xFF12251D)]
        : [const Color(0xFFF3FBF7), const Color(0xFFE6F5EE)];
    return Scaffold(
      body: AnimatedBuilder(
        animation: _c,
        builder: (context, _) {
          final t = _c.value * 2 * math.pi;
          return Stack(
            children: [
              // shifting base gradient
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment(math.cos(t) * 0.6, -1),
                      end: Alignment(-math.cos(t) * 0.6, 1),
                      colors: base,
                    ),
                  ),
                ),
              ),
              // floating colour orbs
              _orb(context, AppTheme.green, 260,
                  0.15 + 0.10 * math.sin(t), 0.10 + 0.06 * math.cos(t * 0.8)),
              _orb(context, AppTheme.coral, 220,
                  0.70 + 0.10 * math.cos(t * 0.9), 0.16 + 0.05 * math.sin(t)),
              _orb(context, AppTheme.amber, 200,
                  0.55 + 0.08 * math.sin(t * 1.1), 0.68 + 0.06 * math.cos(t)),
              _orb(context, AppTheme.green, 180,
                  0.20 + 0.07 * math.cos(t), 0.80 + 0.05 * math.sin(t * 1.2)),
              // content — vertically centred so it fills the screen with no
              // awkward gap at the bottom (scrolls when the keyboard is up).
              SafeArea(
                child: LayoutBuilder(
                  builder: (context, constraints) => SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(22, 12, 22, 20),
                    child: ConstrainedBox(
                      constraints:
                          BoxConstraints(minHeight: constraints.maxHeight - 32),
                      child: widget.child,
                    ),
                  ),
                ),
              ),
              if (widget.leading != null)
                SafeArea(
                  child: Align(
                    alignment: Alignment.topLeft,
                    child: Padding(
                      padding: const EdgeInsets.only(left: 6, top: 4),
                      child: widget.leading,
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  Widget _orb(BuildContext context, Color color, double size, double fx,
      double fy) {
    final s = MediaQuery.of(context).size;
    return Positioned(
      left: s.width * fx - size / 2,
      top: s.height * fy - size / 2,
      child: IgnorePointer(
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(colors: [
              color.withValues(alpha: 0.30),
              color.withValues(alpha: 0.0),
            ]),
          ),
        ),
      ),
    );
  }
}

/// Frosted-glass surface that lets the animated backdrop glow through.
class GlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets padding;
  const GlassCard(
      {super.key, required this.child, this.padding = const EdgeInsets.all(22)});
  @override
  Widget build(BuildContext context) {
    final p = Palette.of(context);
    return ClipRRect(
      borderRadius: BorderRadius.circular(26),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            color: p.card.withValues(alpha: p.isDark ? 0.55 : 0.65),
            borderRadius: BorderRadius.circular(26),
            border: Border.all(
                color: Colors.white.withValues(alpha: p.isDark ? 0.10 : 0.55),
                width: 1.2),
            boxShadow: [
              BoxShadow(
                  color: Colors.black.withValues(alpha: p.isDark ? 0.30 : 0.08),
                  blurRadius: 30,
                  offset: const Offset(0, 14)),
            ],
          ),
          child: child,
        ),
      ),
    );
  }
}

/// The shield logo with a gentle continuous 3-D wobble + vertical float.
class FloatingLogo extends StatefulWidget {
  final double size;
  const FloatingLogo({super.key, this.size = 84});
  @override
  State<FloatingLogo> createState() => _FloatingLogoState();
}

class _FloatingLogoState extends State<FloatingLogo>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c =
      AnimationController(vsync: this, duration: const Duration(seconds: 5))
        ..repeat();

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _c,
      builder: (context, child) {
        final t = _c.value * 2 * math.pi;
        return Transform.translate(
          offset: Offset(0, math.sin(t) * 6.0), // gentle vertical float
          child: Transform(
            alignment: Alignment.center,
            transform: Matrix4.identity()
              ..setEntry(3, 2, 0.0012) // perspective
              ..rotateY(math.sin(t) * 0.28)
              ..rotateX(math.cos(t) * 0.10),
            child: child,
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: AppTheme.heroGradient,
          boxShadow: [
            BoxShadow(
                color: AppTheme.green.withValues(alpha: 0.45),
                blurRadius: 28,
                offset: const Offset(0, 12)),
          ],
        ),
        child: AnimatedShieldLogo(size: widget.size, onDark: true),
      ),
    );
  }
}
