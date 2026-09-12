import 'package:flutter/material.dart';

import '../core/theme.dart';
import '../widgets/risk_gauge.dart';
import 'whatif_screen.dart';
import 'model_screen.dart';

class ResultScreen extends StatelessWidget {
  final Map<String, dynamic> result;
  final Map<String, num>? payload; // present for a fresh check → enables What-If
  const ResultScreen({super.key, required this.result, this.payload});

  @override
  Widget build(BuildContext context) {
    final p = Palette.of(context);
    final pred = result['prediction'] as Map<String, dynamic>;
    final diabetes = pred['diabetes'] as Map<String, dynamic>;
    final kidney = pred['kidney'] as Map<String, dynamic>;
    final factors = result['key_factors'] as Map<String, dynamic>;
    final recs = (result['recommendations'] as List).cast<Map<String, dynamic>>();

    double thr(Map<String, dynamic> m) =>
        ((m['threshold'] as num?)?.toDouble() ?? 0) * 100;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Result'),
        leading: IconButton(
          icon: const Icon(Icons.close, size: 20),
          onPressed: () => Navigator.popUntil(context, (r) => r.isFirst),
        ),
      ),
      body: ListView(
        padding: EdgeInsets.zero,
        children: [
          // ---- Full-bleed dark band carrying both readings -----------------
          Container(
            width: double.infinity,
            color: p.isDark ? AppTheme.panelDark : AppTheme.panel,
            padding: const EdgeInsets.fromLTRB(
                AppTheme.gutter, 24, AppTheme.gutter, 28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: [
                  Text('ESTIMATED RISK',
                      style: AppType.label.copyWith(
                          color: Colors.white.withValues(alpha: 0.45),
                          letterSpacing: 2)),
                  const SizedBox(width: 12),
                  Expanded(
                      child: Container(
                          height: AppTheme.hair,
                          color: Colors.white.withValues(alpha: 0.2))),
                ]),
                const SizedBox(height: 24),
                RiskGauge(
                  title: 'Diabetes',
                  percent: (diabetes['risk_percent'] as num).toDouble(),
                  tier: diabetes['tier'] as String,
                  threshold: thr(diabetes),
                  onDark: true,
                ),
                const SizedBox(height: 30),
                RiskGauge(
                  title: 'Chronic kidney disease',
                  percent: (kidney['risk_percent'] as num).toDouble(),
                  tier: kidney['tier'] as String,
                  threshold: thr(kidney),
                  onDark: true,
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(
                AppTheme.gutter, 18, AppTheme.gutter, 0),
            child: Text(
                'The tick on each scale is the threshold the model was tuned '
                'to. Sitting above it means Aegis would flag you for a real '
                'test — not that you have the condition.',
                style: AppType.small.copyWith(color: p.subtle, height: 1.55)),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(
                AppTheme.gutter, 0, AppTheme.gutter, 36),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
          if (payload != null) ...[
            const SizedBox(height: 24),
            OutlinedButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => WhatIfScreen(payload: payload!, baseline: pred),
                ),
              ),
              child: const Text('OPEN WHAT-IF SIMULATOR'),
            ),
          ],

          const SizedBox(height: 36),

          // ---- Attribution --------------------------------------------------
          const SectionLabel('What drives it'),
          Text(
              'Each factor was neutralised in turn and the model re-run, to '
              'measure how much it lifts your risk.',
              style: AppType.small.copyWith(color: p.subtle, height: 1.55)),
          const SizedBox(height: 20),
          _FactorList('Diabetes', factors['diabetes'] as List),
          const SizedBox(height: 24),
          _FactorList('Kidney', factors['kidney'] as List),

          const SizedBox(height: 36),

          // ---- Actions -------------------------------------------------------
          const SectionLabel('What moves it most'),
          if (recs.isEmpty)
            Text(
                'Nothing stands out. Your answers already describe low-risk '
                'habits — the useful thing now is to keep them and re-check '
                'in a few months.',
                style: AppType.body.copyWith(color: p.ink, height: 1.55))
          else
            ...List.generate(recs.length, (i) => _Rec(recs[i], i + 1)),

          const SizedBox(height: 36),
          Rule(),
          const SizedBox(height: 16),
          Text(
              'Aegis is an educational screening tool. It does not diagnose '
              'disease and does not replace a clinician.',
              style: AppType.small
                  .copyWith(color: p.subtle, fontSize: 12, height: 1.55)),
          const SizedBox(height: 28),
          OutlinedButton(
            onPressed: () => Navigator.push(context,
                MaterialPageRoute(builder: (_) => const ModelScreen())),
            child: const Text('HOW THE MODEL WORKS'),
          ),
          const SizedBox(height: 10),
          FilledButton(
            onPressed: () => Navigator.popUntil(context, (r) => r.isFirst),
            child: const Text('DONE'),
          ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Factor attribution as a ranked table: label left, magnitude right, one
/// measure per row. No cards — the rule structure does the separating.
class _FactorList extends StatelessWidget {
  final String title;
  final List<dynamic> items;
  const _FactorList(this.title, this.items);

  @override
  Widget build(BuildContext context) {
    final p = Palette.of(context);
    if (items.isEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title.toUpperCase(),
              style: AppType.label.copyWith(color: AppTheme.green)),
          const SizedBox(height: 10),
          Text('No significant drivers found.',
              style: AppType.small.copyWith(color: p.subtle)),
        ],
      );
    }

    // Scale bars against the strongest factor so the ranking is legible.
    final maxImpact = items
        .map((f) => (f['impact'] as num).toDouble().abs())
        .reduce((a, b) => a > b ? a : b);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title.toUpperCase(),
            style: AppType.label.copyWith(color: AppTheme.green)),
        const SizedBox(height: 6),
        ...items.map((f) {
          final impact = (f['impact'] as num).toDouble();
          final frac = maxImpact == 0 ? 0.0 : (impact.abs() / maxImpact);
          return Padding(
            padding: const EdgeInsets.only(top: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                        child: Text(f['label'] as String,
                            style: AppType.small.copyWith(color: p.ink))),
                    const SizedBox(width: 12),
                    Text('+${(impact * 100).toStringAsFixed(1)}',
                        style: AppType.mono.copyWith(color: p.subtle)),
                  ],
                ),
                const SizedBox(height: 6),
                LayoutBuilder(
                  builder: (context, c) => Stack(children: [
                    Container(height: 4, color: p.line),
                    TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0, end: frac),
                      duration: const Duration(milliseconds: 600),
                      curve: Curves.easeOut,
                      builder: (_, v, __) => Container(
                          height: 4, width: c.maxWidth * v, color: AppTheme.coral),
                    ),
                  ]),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }
}

/// One recommendation: a numbered entry with its projected effect stated as a
/// figure, not a coloured pill.
class _Rec extends StatelessWidget {
  final Map<String, dynamic> rec;
  final int index;
  const _Rec(this.rec, this.index);

  @override
  Widget build(BuildContext context) {
    final p = Palette.of(context);
    final dia = (rec['diabetes_reduction_percent'] as num).toDouble();
    final kid = (rec['kidney_reduction_percent'] as num).toDouble();

    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: 28,
                  child: Text(index.toString().padLeft(2, '0'),
                      style: AppType.mono.copyWith(color: AppTheme.green)),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(rec['action'] as String,
                          style: AppType.h2
                              .copyWith(color: p.ink, height: 1.35)),
                      const SizedBox(height: 10),
                      Row(children: [
                        if (dia > 0) _delta('Diabetes', dia, p),
                        if (dia > 0 && kid > 0) const SizedBox(width: 24),
                        if (kid > 0) _delta('Kidney', kid, p),
                      ]),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Rule(),
        ],
      ),
    );
  }

  Widget _delta(String label, double v, Palette p) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label.toUpperCase(),
              style: AppType.label.copyWith(color: p.subtle, fontSize: 9)),
          const SizedBox(height: 3),
          Text('−${v.toStringAsFixed(1)}%',
              style: AppType.mono.copyWith(
                  color: AppTheme.green,
                  fontSize: 15,
                  fontWeight: FontWeight.w500)),
        ],
      );
}
