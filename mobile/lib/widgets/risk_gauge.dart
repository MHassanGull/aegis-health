import 'package:flutter/material.dart';

import '../core/motion.dart';
import '../core/theme.dart';

/// The forecast band. This is the app's signature element.
///
/// The model returns a probability, so the band is built like a forecast
/// rather than a diagnosis: a filled reading, the screening cut-off marked on
/// the same scale, and (where known) a ghosted marker for where this person
/// could land if they acted. Three facts, one scale, no dial.
///
/// The same component appears on Home, Result and What-if, which is what ties
/// those screens together visually.
class RiskGauge extends StatelessWidget {
  final String title;

  /// Current reading, 0-100.
  final double percent;
  final String tier;

  /// The model's screening threshold as a percentage, marked on the scale.
  final double? threshold;

  /// Where this person could get to by changing habits, 0-100. Drawn as a
  /// hollow marker ahead of, or behind, the current reading.
  final double? achievable;

  /// Renders for a dark ground.
  final bool onDark;

  /// Accepted for call-site compatibility; the design uses no icon.
  final IconData? icon;

  /// Risks here are small numbers, so a full 0-100 axis would render every
  /// reading as a sliver. 50% is a readable and honest ceiling.
  final double scaleMax;

  const RiskGauge({
    super.key,
    required this.title,
    required this.percent,
    required this.tier,
    this.threshold,
    this.achievable,
    this.onDark = false,
    this.icon,
    this.scaleMax = 50,
  });

  @override
  Widget build(BuildContext context) {
    final p = Palette.of(context);
    final t = Theme.of(context).textTheme;
    final color = AppTheme.tierColor(tier);
    final ink = onDark ? Colors.white : p.ink;
    final muted = onDark ? Colors.white.withValues(alpha: 0.62) : p.subtle;
    final track = onDark ? Colors.white.withValues(alpha: 0.14) : p.sunk;
    final pillColor = onDark ? color : p.on(color);

    return Semantics(
      // One spoken sentence instead of five disconnected fragments.
      label: '$title risk ${percent.toStringAsFixed(1)} per cent, '
          '$tier risk'
          '${threshold != null ? ', screening cut-off '
              '${threshold!.toStringAsFixed(1)} per cent' : ''}',
      excludeSemantics: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Text(title,
                    style: t.titleMedium?.copyWith(color: ink)),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: onDark ? 0.24 : 0.13),
                  borderRadius: BorderRadius.circular(AppTheme.rPill),
                ),
                child: Text(tier.toLowerCase(),
                    style: t.labelMedium?.copyWith(color: pillColor)),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              CountUp(percent,
                  style: TextStyle(
                    fontFamily: AppTheme.mono,
                    fontSize: onDark ? 46 : 40,
                    height: 1,
                    fontWeight: FontWeight.w500,
                    letterSpacing: -2,
                    color: ink,
                  )),
              const SizedBox(width: 3),
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text('%',
                    style: TextStyle(
                        fontFamily: AppTheme.mono,
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                        color: muted)),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _Band(
            value: percent / scaleMax,
            threshold: threshold == null ? null : threshold! / scaleMax,
            achievable: achievable == null ? null : achievable! / scaleMax,
            fill: color,
            track: track,
            marker: ink,
          ),
          if (threshold != null) ...[
            const SizedBox(height: 10),
            Row(children: [
              Container(
                width: 2,
                height: 11,
                decoration: BoxDecoration(
                    color: muted,
                    borderRadius: BorderRadius.circular(AppTheme.rPill)),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                    'Flagged above ${threshold!.toStringAsFixed(1)}%',
                    style: t.bodySmall?.copyWith(color: muted)),
              ),
            ]),
          ],
        ],
      ),
    );
  }
}

/// The band itself: a rounded track, a rounded fill, a cut-off marker and an
/// optional hollow "achievable" marker.
class _Band extends StatelessWidget {
  final double value;
  final double? threshold;
  final double? achievable;
  final Color fill;
  final Color track;
  final Color marker;

  const _Band({
    required this.value,
    required this.threshold,
    required this.achievable,
    required this.fill,
    required this.track,
    required this.marker,
  });

  @override
  Widget build(BuildContext context) {
    const h = 14.0;
    return LayoutBuilder(
      builder: (context, c) {
        final w = c.maxWidth;
        final v = value.clamp(0.0, 1.0);
        return SizedBox(
          height: h,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                decoration: BoxDecoration(
                  color: track,
                  borderRadius: BorderRadius.circular(AppTheme.rPill),
                ),
              ),
              TweenAnimationBuilder<double>(
                tween: Tween(begin: 0, end: v),
                duration: Motion.reduced(context)
                    ? Duration.zero
                    : Motion.base,
                curve: Motion.ease,
                builder: (_, t, __) => Container(
                  width: (w * t).clamp(h, w),
                  decoration: BoxDecoration(
                    color: fill,
                    borderRadius: BorderRadius.circular(AppTheme.rPill),
                  ),
                ),
              ),
              if (achievable != null)
                Positioned(
                  left: (w * achievable!.clamp(0.0, 1.0)) - 7,
                  top: -1,
                  child: Container(
                    height: h + 2,
                    width: 14,
                    decoration: BoxDecoration(
                      color: Colors.transparent,
                      border: Border.all(color: marker, width: 2),
                      borderRadius: BorderRadius.circular(AppTheme.rPill),
                    ),
                  ),
                ),
              if (threshold != null)
                Positioned(
                  left: (w * threshold!.clamp(0.0, 1.0)) - 1.5,
                  top: -3,
                  child: Container(
                    height: h + 6,
                    width: 3,
                    decoration: BoxDecoration(
                      color: marker,
                      borderRadius: BorderRadius.circular(AppTheme.rPill),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}
