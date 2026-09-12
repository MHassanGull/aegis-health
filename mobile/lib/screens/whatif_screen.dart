import 'dart:async';
import 'package:flutter/material.dart';

import '../core/api_client.dart';
import '../core/theme.dart';
import '../widgets/risk_gauge.dart';

/// Interactive what-if: change a habit and watch predicted risk move live.
class WhatIfScreen extends StatefulWidget {
  final Map<String, num> payload;
  final Map<String, dynamic> baseline; // prediction map from the first result
  const WhatIfScreen({super.key, required this.payload, required this.baseline});
  @override
  State<WhatIfScreen> createState() => _WhatIfScreenState();
}

class _WhatIfScreenState extends State<WhatIfScreen> {
  late Map<String, num> _p = Map<String, num>.from(widget.payload);
  Timer? _debounce;
  bool _busy = false;
  late double _diabetes =
      (widget.baseline['diabetes']['risk_percent'] as num).toDouble();
  late String _diaTier = widget.baseline['diabetes']['tier'] as String;
  late double _kidney =
      (widget.baseline['kidney']['risk_percent'] as num).toDouble();
  late String _kidTier = widget.baseline['kidney']['tier'] as String;

  late final double _baseDia =
      (widget.baseline['diabetes']['risk_percent'] as num).toDouble();
  late final double _baseKid =
      (widget.baseline['kidney']['risk_percent'] as num).toDouble();

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  void _change(String key, num value) {
    setState(() => _p[key] = value);
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 450), _recompute);
  }

  Future<void> _recompute() async {
    setState(() => _busy = true);
    try {
      final r = await ApiClient.instance.predict(_p);
      final pred = r['prediction'] as Map<String, dynamic>;
      setState(() {
        _diabetes = (pred['diabetes']['risk_percent'] as num).toDouble();
        _diaTier = pred['diabetes']['tier'] as String;
        _kidney = (pred['kidney']['risk_percent'] as num).toDouble();
        _kidTier = pred['kidney']['tier'] as String;
      });
    } catch (_) {} finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final p = Palette.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('What-if')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
            AppTheme.gutter, 4, AppTheme.gutter, 32),
        children: [
          Text(
              'Change a habit below. The model re-runs and the readouts move '
              'with it.',
              style: AppType.small.copyWith(color: p.subtle, height: 1.55)),
          const SizedBox(height: 28),
          const SectionLabel('Projected risk'),
          RiskGauge(title: 'Diabetes', percent: _diabetes, tier: _diaTier),
          const SizedBox(height: 24),
          RiskGauge(
              title: 'Chronic kidney disease',
              percent: _kidney,
              tier: _kidTier),
          const SizedBox(height: 20),
          _delta(p),
          const SizedBox(height: 34),
          const SectionLabel('Habits'),
          _toggle(p, 'Physically active', 'PhysActivity', 1, 0),
          _toggle(p, 'Not smoking', 'Smoker', 0, 1),
          _toggle(p, 'Fruit most days', 'Fruits', 1, 0),
          _toggle(p, 'Vegetables most days', 'Veggies', 1, 0),
          _toggle(p, 'No heavy drinking', 'HvyAlcoholConsump', 0, 1),
          const SizedBox(height: 26),
          const SectionLabel('Body mass index'),
          _bmiSlider(p),
        ],
      ),
    );
  }

  /// The change from the baseline, stated as a signed figure per condition.
  Widget _delta(Palette p) {
    final dDia = _diabetes - _baseDia;
    final dKid = _kidney - _baseKid;
    String fmt(double d) =>
        '${d > 0 ? '+' : d < 0 ? '−' : ''}${d.abs().toStringAsFixed(1)}%';
    Color col(double d) =>
        d < -0.05 ? AppTheme.low : (d > 0.05 ? AppTheme.high : p.subtle);

    if (_busy) {
      return Text('RECALCULATING',
          style: AppType.label.copyWith(color: p.subtle));
    }
    return Row(children: [
      _deltaCell(p, 'Diabetes', fmt(dDia), col(dDia)),
      const SizedBox(width: 32),
      _deltaCell(p, 'Kidney', fmt(dKid), col(dKid)),
    ]);
  }

  Widget _deltaCell(Palette p, String label, String value, Color color) =>
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('${label.toUpperCase()} CHANGE',
              style: AppType.label.copyWith(color: p.subtle, fontSize: 9)),
          const SizedBox(height: 4),
          Text(value,
              style: AppType.mono.copyWith(
                  color: color, fontSize: 17, fontWeight: FontWeight.w500)),
        ],
      );

  /// One habit per row, divided by a rule. No card per switch.
  Widget _toggle(Palette p, String label, String key, num good, num bad) {
    final isGood = _p[key] == good;
    return Column(
      children: [
        Row(children: [
          Expanded(
              child: Text(label, style: AppType.body.copyWith(color: p.ink))),
          Switch(
            value: isGood,
            activeThumbColor: Colors.white,
            activeTrackColor: AppTheme.green,
            inactiveTrackColor: p.line,
            trackOutlineColor: WidgetStateProperty.all(Colors.transparent),
            onChanged: (v) => _change(key, v ? good : bad),
          ),
        ]),
        Rule(),
      ],
    );
  }

  Widget _bmiSlider(Palette p) {
    final bmi = (_p['BMI'] ?? 25).toDouble();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic, children: [
          Text(bmi.toStringAsFixed(1),
              style: AppType.metric.copyWith(color: p.ink, fontSize: 28)),
          const SizedBox(width: 10),
          Text(_bmiBand(bmi).toUpperCase(),
              style: AppType.label.copyWith(color: p.subtle)),
        ]),
        SliderTheme(
          data: SliderThemeData(
            trackHeight: 3,
            activeTrackColor: AppTheme.green,
            inactiveTrackColor: p.line,
            thumbColor: AppTheme.green,
            overlayColor: AppTheme.green.withValues(alpha: 0.10),
            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
            trackShape: const RectangularSliderTrackShape(),
          ),
          child: Slider(
            value: bmi.clamp(15, 45),
            min: 15,
            max: 45,
            onChanged: (v) =>
                _change('BMI', double.parse(v.toStringAsFixed(1))),
          ),
        ),
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text('15', style: AppType.mono.copyWith(color: p.subtle, fontSize: 11)),
          Text('45', style: AppType.mono.copyWith(color: p.subtle, fontSize: 11)),
        ]),
      ],
    );
  }

  String _bmiBand(double b) {
    if (b < 18.5) return 'Underweight';
    if (b < 25) return 'Healthy';
    if (b < 30) return 'Overweight';
    return 'Obese';
  }
}
