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
      appBar: AppBar(title: const Text('What-If Simulator')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 6, 20, 28),
        children: [
          Text('Change a habit and watch your risk move.',
              style: TextStyle(color: p.subtle)),
          const SizedBox(height: 16),
          SoftCard(
            padding: const EdgeInsets.symmetric(vertical: 22),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    RiskGauge(
                        title: 'Diabetes',
                        percent: _diabetes,
                        tier: _diaTier,
                        icon: Icons.water_drop_rounded,
                        size: 116),
                    RiskGauge(
                        title: 'Kidney',
                        percent: _kidney,
                        tier: _kidTier,
                        icon: Icons.spa_rounded,
                        size: 116),
                  ],
                ),
                const SizedBox(height: 8),
                _delta(p),
              ],
            ),
          ),
          const SizedBox(height: 22),
          Text('Try changing these',
              style: TextStyle(
                  fontSize: 16, fontWeight: FontWeight.w800, color: p.ink)),
          const SizedBox(height: 10),
          _toggle(p, 'Become physically active', 'PhysActivity', 1, 0),
          _toggle(p, 'Quit smoking', 'Smoker', 0, 1),
          _toggle(p, 'Eat fruit daily', 'Fruits', 1, 0),
          _toggle(p, 'Eat vegetables daily', 'Veggies', 1, 0),
          _toggle(p, 'Cut heavy drinking', 'HvyAlcoholConsump', 0, 1),
          const SizedBox(height: 8),
          _bmiSlider(p),
        ],
      ),
    );
  }

  Widget _delta(Palette p) {
    final dDia = _diabetes - _baseDia;
    final dKid = _kidney - _baseKid;
    String fmt(double d) => '${d > 0 ? '+' : ''}${d.toStringAsFixed(1)}%';
    Color col(double d) =>
        d < -0.05 ? AppTheme.low : (d > 0.05 ? AppTheme.high : p.subtle);
    if (_busy) {
      return Text('Updating…', style: TextStyle(color: p.subtle));
    }
    return Wrap(spacing: 18, children: [
      Text('Diabetes ${fmt(dDia)}',
          style: TextStyle(color: col(dDia), fontWeight: FontWeight.w700)),
      Text('Kidney ${fmt(dKid)}',
          style: TextStyle(color: col(dKid), fontWeight: FontWeight.w700)),
    ]);
  }

  Widget _toggle(Palette p, String label, String key, num good, num bad) {
    final isGood = _p[key] == good;
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      child: SoftCard(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        child: Row(children: [
          Expanded(
              child: Text(label,
                  style: TextStyle(color: p.ink, fontWeight: FontWeight.w600))),
          Switch(
            value: isGood,
            activeTrackColor: AppTheme.green,
            onChanged: (v) => _change(key, v ? good : bad),
          ),
        ]),
      ),
    );
  }

  Widget _bmiSlider(Palette p) {
    final bmi = (_p['BMI'] ?? 25).toDouble();
    return SoftCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Expanded(
                child: Text('Body Mass Index',
                    style:
                        TextStyle(color: p.ink, fontWeight: FontWeight.w600))),
            Text(bmi.toStringAsFixed(1),
                style: const TextStyle(
                    color: AppTheme.green, fontWeight: FontWeight.w800)),
          ]),
          Slider(
            value: bmi.clamp(15, 45),
            min: 15,
            max: 45,
            activeColor: AppTheme.green,
            onChanged: (v) =>
                _change('BMI', double.parse(v.toStringAsFixed(1))),
          ),
        ],
      ),
    );
  }
}
