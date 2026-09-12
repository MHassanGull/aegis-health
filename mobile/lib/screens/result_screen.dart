import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

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

    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Results'),
        leading: IconButton(
          icon: const Icon(Icons.close_rounded),
          onPressed: () => Navigator.popUntil(context, (r) => r.isFirst),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 6, 20, 32),
        children: [
          SoftCard(
            padding: const EdgeInsets.symmetric(vertical: 26),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                RiskGauge(
                    title: 'Diabetes',
                    percent: (diabetes['risk_percent'] as num).toDouble(),
                    tier: diabetes['tier'] as String,
                    icon: Icons.water_drop_rounded),
                RiskGauge(
                    title: 'Kidney',
                    percent: (kidney['risk_percent'] as num).toDouble(),
                    tier: kidney['tier'] as String,
                    icon: Icons.spa_rounded),
              ],
            ),
          ).animate().fadeIn(duration: 400.ms).moveY(begin: 14, end: 0),
          if (payload != null) ...[
            const SizedBox(height: 14),
            FilledButton.icon(
              style: FilledButton.styleFrom(
                backgroundColor: p.tint(AppTheme.green),
                foregroundColor: AppTheme.greenDark,
                minimumSize: const Size.fromHeight(50),
              ),
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                      WhatIfScreen(payload: payload!, baseline: pred),
                ),
              ),
              icon: const Icon(Icons.tune_rounded),
              label: const Text('Try the What-If Simulator'),
            ),
          ],
          const SizedBox(height: 24),
          _Header('Explainable AI — why', Icons.troubleshoot_rounded, p)
              .animate().fadeIn(delay: 200.ms),
          const SizedBox(height: 6),
          Text(
              'The model re-ran your profile with each factor neutralised to '
              'measure how much it pushes your risk up (SHAP-style attribution).',
              style: TextStyle(color: p.subtle, fontSize: 12.5, height: 1.4))
              .animate().fadeIn(delay: 240.ms),
          const SizedBox(height: 12),
          _FactorCard('Diabetes', (factors['diabetes'] as List), p)
              .animate().fadeIn(delay: 300.ms).moveX(begin: -10, end: 0),
          const SizedBox(height: 12),
          _FactorCard('Kidney', (factors['kidney'] as List), p)
              .animate().fadeIn(delay: 380.ms).moveX(begin: -10, end: 0),
          const SizedBox(height: 24),
          _Header('What you can do', Icons.bolt_rounded, p)
              .animate().fadeIn(delay: 460.ms),
          const SizedBox(height: 12),
          if (recs.isEmpty)
            SoftCard(
              child: Row(children: [
                const Icon(Icons.celebration_rounded, color: AppTheme.green),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                      'Your habits already look healthy — keep it up! 🎉',
                      style: TextStyle(color: p.ink)),
                ),
              ]),
            ).animate().fadeIn(delay: 540.ms)
          else
            ...List.generate(recs.length, (i) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _RecCard(recs[i], p)
                    .animate()
                    .fadeIn(delay: (540 + i * 90).ms)
                    .moveY(begin: 12, end: 0),
              );
            }),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
                color: p.tint(AppTheme.green),
                borderRadius: BorderRadius.circular(14)),
            child: Row(children: [
              const Icon(Icons.info_outline_rounded,
                  color: AppTheme.green, size: 20),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                    'Aegis is an educational screening tool, not a medical diagnosis. See a doctor for clinical advice.',
                    style: TextStyle(fontSize: 12, color: p.subtle)),
              ),
            ]),
          ),
          const SizedBox(height: 18),
          OutlinedButton.icon(
            style: OutlinedButton.styleFrom(
              foregroundColor: AppTheme.green,
              minimumSize: const Size.fromHeight(50),
              side: const BorderSide(color: AppTheme.green),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
            ),
            onPressed: () => Navigator.push(context,
                MaterialPageRoute(builder: (_) => const ModelScreen())),
            icon: const Icon(Icons.hub_rounded),
            label: const Text('How the AI works'),
          ),
          const SizedBox(height: 12),
          FilledButton(
            onPressed: () => Navigator.popUntil(context, (r) => r.isFirst),
            child: const Text('Back to Home'),
          ),
        ],
      ),
    );
  }
}

class _Header extends StatelessWidget {
  final String text;
  final IconData icon;
  final Palette p;
  const _Header(this.text, this.icon, this.p);
  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Icon(icon, color: AppTheme.green, size: 22),
      const SizedBox(width: 8),
      Text(text,
          style: TextStyle(
              fontSize: 18, fontWeight: FontWeight.w800, color: p.ink)),
    ]);
  }
}

class _FactorCard extends StatelessWidget {
  final String title;
  final List<dynamic> items;
  final Palette p;
  const _FactorCard(this.title, this.items, this.p);
  @override
  Widget build(BuildContext context) {
    return SoftCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: const TextStyle(
                  fontWeight: FontWeight.w800, color: AppTheme.green)),
          const SizedBox(height: 10),
          if (items.isEmpty)
            Text('No major risk factors detected.',
                style: TextStyle(color: p.subtle))
          else
            ...items.map((f) {
              final impact = ((f['impact'] as num) * 100).toDouble();
              final frac = (impact / 25).clamp(0.06, 1.0);
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 7),
                child: Row(
                  children: [
                    Expanded(
                        flex: 5,
                        child: Text(f['label'] as String,
                            style:
                                TextStyle(fontSize: 13.5, color: p.ink))),
                    Expanded(
                      flex: 4,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: TweenAnimationBuilder<double>(
                          tween: Tween(begin: 0, end: frac.toDouble()),
                          duration: const Duration(milliseconds: 900),
                          curve: Curves.easeOut,
                          builder: (_, v, __) => LinearProgressIndicator(
                            value: v,
                            minHeight: 9,
                            backgroundColor: p.line,
                            color: AppTheme.coral,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }),
        ],
      ),
    );
  }
}

class _RecCard extends StatelessWidget {
  final Map<String, dynamic> rec;
  final Palette p;
  const _RecCard(this.rec, this.p);
  @override
  Widget build(BuildContext context) {
    final dia = (rec['diabetes_reduction_percent'] as num).toDouble();
    final kid = (rec['kidney_reduction_percent'] as num).toDouble();
    return SoftCard(
      child: Row(
        children: [
          Container(
            height: 46, width: 46,
            decoration: BoxDecoration(
                gradient: AppTheme.coralGradient,
                borderRadius: BorderRadius.circular(14)),
            child: const Icon(Icons.bolt_rounded, color: Colors.white),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(rec['action'] as String,
                    style: TextStyle(
                        fontWeight: FontWeight.w700, color: p.ink)),
                const SizedBox(height: 6),
                Wrap(spacing: 8, runSpacing: 6, children: [
                  if (dia > 0) _chip('Diabetes −${dia.toStringAsFixed(1)}%', p),
                  if (kid > 0) _chip('Kidney −${kid.toStringAsFixed(1)}%', p),
                ]),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _chip(String t, Palette p) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
            color: p.tint(AppTheme.green),
            borderRadius: BorderRadius.circular(20)),
        child: Text(t,
            style: const TextStyle(
                color: AppTheme.greenDark,
                fontWeight: FontWeight.w800,
                fontSize: 12)),
      );
}
