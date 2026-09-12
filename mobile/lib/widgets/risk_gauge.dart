import 'package:flutter/material.dart';
import '../core/theme.dart';

/// A risk readout drawn as a linear measure rather than a dial.
///
/// A donut with a glowing sweep looks decorative; a measure with a marked
/// threshold reads like an instrument and shows the one thing that actually
/// matters clinically — where this person sits relative to the model's
/// screening cut-off.
class RiskGauge extends StatelessWidget {
  final String title;
  final double percent; // 0-100
  final String tier;

  /// The model's screening threshold, as a percentage, marked on the scale.
  final double? threshold;

  /// Accepted for call-site compatibility; this design does not use an icon.
  final IconData? icon;

  /// Set when the gauge sits on the near-black band, so labels and the
  /// threshold tick invert instead of disappearing into the field.
  final bool onDark;

  /// Full scale of the measure. Risks are small numbers, so a 0-100 axis would
  /// render every bar as a sliver; 50% is a readable, honest ceiling.
  final double scaleMax;

  const RiskGauge({
    super.key,
    required this.title,
    required this.percent,
    required this.tier,
    this.threshold,
    this.icon,
    this.onDark = false,
    this.scaleMax = 50,
  });

  @override
  Widget build(BuildContext context) {
    final p = Palette.of(context);
    final color = AppTheme.tierColor(tier);
    final ink = onDark ? Colors.white : p.ink;
    final muted =
        onDark ? Colors.white.withValues(alpha: 0.55) : p.subtle;
    final track = onDark ? Colors.white.withValues(alpha: 0.16) : p.line;
    final frac = (percent / scaleMax).clamp(0.0, 1.0);
    final thrFrac =
        threshold == null ? null : (threshold! / scaleMax).clamp(0.0, 1.0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(title.toUpperCase(),
                style: AppType.label.copyWith(color: muted, letterSpacing: 1.6)),
            Text('${tier.toUpperCase()} RISK',
                style: AppType.label.copyWith(color: color)),
          ],
        ),
        const SizedBox(height: 10),
        // The figure. Monospace, so the decimal point holds its column.
        TweenAnimationBuilder<double>(
          tween: Tween(begin: 0, end: percent),
          duration: const Duration(milliseconds: 700),
          curve: Curves.easeOutCubic,
          builder: (context, v, _) => Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(v.toStringAsFixed(1),
                  style: AppType.metric
                      .copyWith(color: ink, fontSize: onDark ? 46 : 34)),
              const SizedBox(width: 2),
              Padding(
                padding: const EdgeInsets.only(bottom: 3),
                child: Text('%',
                    style: AppType.metric.copyWith(
                        color: muted, fontSize: 18, letterSpacing: 0)),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        // The measure: flat fill, square ends, with the threshold marked.
        LayoutBuilder(
          builder: (context, c) {
            final w = c.maxWidth;
            return SizedBox(
              height: 18,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Positioned(
                    left: 0,
                    right: 0,
                    top: 0,
                    child: Container(height: 8, color: track),
                  ),
                  Positioned(
                    left: 0,
                    top: 0,
                    child: TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0, end: frac.toDouble()),
                      duration: const Duration(milliseconds: 700),
                      curve: Curves.easeOutCubic,
                      builder: (_, v, __) =>
                          Container(height: 8, width: w * v, color: color),
                    ),
                  ),
                  if (thrFrac != null)
                    Positioned(
                      left: (w * thrFrac) - 0.5,
                      top: -3,
                      child: Container(height: 14, width: 1.5, color: ink),
                    ),
                ],
              ),
            );
          },
        ),
        if (threshold != null) ...[
          const SizedBox(height: 8),
          Text('SCREENING CUT-OFF ${threshold!.toStringAsFixed(1)}%',
              style: AppType.label
                  .copyWith(color: muted, fontSize: 9, letterSpacing: 0.9)),
        ],
      ],
    );
  }
}
