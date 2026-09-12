import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../core/api_client.dart';
import '../core/theme.dart';

/// "Under the Hood", a live transparency / model-card screen.
///
/// Everything here is real: the architecture is introspected from the trained
/// neural network on the server, and the metrics come from the training report.
/// Its job is to make the machine-learning core of the project visible.
class ModelScreen extends StatefulWidget {
  const ModelScreen({super.key});
  @override
  State<ModelScreen> createState() => _ModelScreenState();
}

class _ModelScreenState extends State<ModelScreen> {
  late Future<Map<String, dynamic>> _future;

  @override
  void initState() {
    super.initState();
    _future = ApiClient.instance.modelCard();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Under the Hood')),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _future,
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const _LoadingSkeleton();
          }
          if (snap.hasError || !snap.hasData) {
            return _error(context);
          }
          return _Content(card: snap.data!);
        },
      ),
    );
  }

  Widget _error(BuildContext context) {
    final p = Palette.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.cloud_off_rounded, size: 56, color: AppTheme.coral),
            const SizedBox(height: 14),
            Text('Couldn’t load the model details.\nMake sure the backend is running.',
                textAlign: TextAlign.center, style: TextStyle(color: p.subtle)),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: () => setState(
                  () => _future = ApiClient.instance.modelCard()),
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}

class _Content extends StatelessWidget {
  final Map<String, dynamic> card;
  const _Content({required this.card});

  @override
  Widget build(BuildContext context) {
    final p = Palette.of(context);
    final arch = card['architecture'] as Map<String, dynamic>;
    final ds = card['dataset'] as Map<String, dynamic>;
    final metrics = card['metrics'] as Map<String, dynamic>;
    final dia = metrics['diabetes'] as Map<String, dynamic>;
    final kid = metrics['kidney'] as Map<String, dynamic>;
    final methodology = (card['methodology'] as List).cast<String>();
    final layers = (arch['layer_sizes'] as List).map((e) => e as int).toList();
    final overall = (card['overall_accuracy'] as num?)?.toDouble() ?? 0;
    final calibrated = card['calibrated'] == true;
    final crossValidated = card['cross_validated'] == true;
    final folds = (card['n_folds'] as num?)?.toInt() ?? 5;

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
      children: [
        // ---- architecture hero -------------------------------------------
        BrandBlock(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Architecture',
                  style: AppType.label.copyWith(
                      color: Colors.white.withValues(alpha: 0.7),
                      letterSpacing: 1.6)),
              const SizedBox(height: 12),
              Text(arch['type'] as String,
                  style: const TextStyle(
                      fontFamily: AppTheme.sans,
                      color: Colors.white,
                      fontSize: 20,
                      height: 1.2,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.5)),
              const SizedBox(height: 6),
              Text(arch['framework'] as String,
                  style: AppType.mono.copyWith(
                      color: Colors.white.withValues(alpha: 0.8),
                      fontSize: 12)),
              const SizedBox(height: 16),
              SizedBox(
                height: 170,
                child: TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0, end: 1),
                  duration: const Duration(milliseconds: 1400),
                  curve: Curves.easeOut,
                  builder: (_, t, __) => CustomPaint(
                    painter: _NetPainter(layers, t),
                    size: Size.infinite,
                  ),
                ),
              ),
              const SizedBox(height: 6),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _heroStat('${arch['input_features']}', 'inputs'),
                  _heroStat((arch['hidden_layers'] as List).join(' · '),
                      'hidden'),
                  _heroStat('${arch['output_heads']}', 'heads'),
                  _heroStat(_fmt(arch['trainable_params'] as int), 'params'),
                ],
              ),
            ],
          ),
        ).animate().fadeIn(duration: 400.ms).moveY(begin: 14, end: 0),

        const SizedBox(height: 16),
        _PerformanceCard(
          dia: dia,
          kid: kid,
          calibrated: calibrated,
          crossValidated: crossValidated,
          folds: folds,
          p: p,
        ).animate().fadeIn(delay: 80.ms).moveY(begin: 12, end: 0),

        const SizedBox(height: 20),
        _SectionTitle('Trained on real people', Icons.groups_rounded, p),
        const SizedBox(height: 10),
        _DatasetCard(ds, p).animate().fadeIn(delay: 120.ms),

        const SizedBox(height: 22),
        _SectionTitle('How good is it?', Icons.verified_rounded, p),
        const SizedBox(height: 6),
        Text('Measured on 50,631 held-out people the model never saw in training.',
            style: TextStyle(color: p.subtle, fontSize: 12.5)),
        const SizedBox(height: 12),
        _PerfCard(dia, AppTheme.green, Icons.water_drop_rounded, p)
            .animate().fadeIn(delay: 150.ms).moveX(begin: -8, end: 0),
        const SizedBox(height: 12),
        _PerfCard(kid, AppTheme.coral, Icons.spa_rounded, p)
            .animate().fadeIn(delay: 230.ms).moveX(begin: -8, end: 0),

        const SizedBox(height: 12),
        SoftCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('ROC-AUC vs Recall',
                  style:
                      TextStyle(fontWeight: FontWeight.w700, color: p.ink)),
              const SizedBox(height: 4),
              Text('Higher is better · both diseases',
                  style: TextStyle(color: p.subtle, fontSize: 12)),
              const SizedBox(height: 16),
              SizedBox(height: 170, child: _MetricsBars(dia, kid, p)),
              const SizedBox(height: 10),
              Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                _legendDot(AppTheme.green, 'ROC-AUC', p),
                const SizedBox(width: 18),
                _legendDot(AppTheme.amber, 'Recall', p),
              ]),
            ],
          ),
        ).animate().fadeIn(delay: 300.ms),

        const SizedBox(height: 22),
        _SectionTitle('Who it catches', Icons.grid_view_rounded, p),
        const SizedBox(height: 12),
        _ConfusionCard(dia, p).animate().fadeIn(delay: 120.ms),
        const SizedBox(height: 12),
        _ConfusionCard(kid, p).animate().fadeIn(delay: 180.ms),

        const SizedBox(height: 22),
        _WhyRecallCard(p).animate().fadeIn(delay: 120.ms),

        const SizedBox(height: 22),
        _SectionTitle('The approach', Icons.architecture_rounded, p),
        const SizedBox(height: 12),
        ...List.generate(methodology.length, (i) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: _MethodTile(i + 1, methodology[i], p)
                .animate()
                .fadeIn(delay: (120 + i * 70).ms)
                .moveX(begin: -8, end: 0),
          );
        }),

        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
              color: p.tint(AppTheme.green),
              borderRadius: BorderRadius.circular(AppTheme.radius)),
          child: Row(children: [
            const Icon(Icons.info_outline_rounded,
                color: AppTheme.green, size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                  'These numbers describe an educational screening model, not a '
                  'medical device. It flags risk to encourage prevention, and it '
                  'does not diagnose.',
                  style: TextStyle(fontSize: 12, color: p.subtle)),
            ),
          ]),
        ),
      ],
    );
  }

  Widget _heroStat(String value, String label) => Column(
        children: [
          Text(value,
              style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 16)),
          Text(label,
              style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.8), fontSize: 11)),
        ],
      );

  Widget _legendDot(Color c, String label, Palette p) => Row(children: [
        Container(
            width: 11,
            height: 11,
            decoration: BoxDecoration(color: c, shape: BoxShape.circle)),
        const SizedBox(width: 6),
        Text(label, style: TextStyle(color: p.subtle, fontSize: 12.5)),
      ]);

  static String _fmt(int n) {
    final s = n.toString();
    final b = StringBuffer();
    for (var i = 0; i < s.length; i++) {
      if (i > 0 && (s.length - i) % 3 == 0) b.write(',');
      b.write(s[i]);
    }
    return b.toString();
  }
}

// ---------------------------------------------------------------------------
// Neural-network diagram (drawn from the real layer sizes).
// ---------------------------------------------------------------------------
class _NetPainter extends CustomPainter {
  final List<int> layers; // e.g. [19, 96, 48, 2]
  final double t; // 0..1 draw-in progress
  _NetPainter(this.layers, this.t);

  static const int _maxDots = 7;

  @override
  void paint(Canvas canvas, Size size) {
    if (layers.isEmpty) return;
    final n = layers.length;
    final colX = <double>[
      for (var i = 0; i < n; i++)
        size.width * (0.10 + 0.80 * (n == 1 ? 0.5 : i / (n - 1)))
    ];
    final dotsPerCol =
        layers.map((c) => c.clamp(1, _maxDots)).toList(growable: false);

    List<Offset> colPoints(int i) {
      final count = dotsPerCol[i];
      final top = size.height * 0.14;
      final bottom = size.height * 0.78;
      final gap = count == 1 ? 0.0 : (bottom - top) / (count - 1);
      return [
        for (var k = 0; k < count; k++)
          Offset(colX[i], count == 1 ? (top + bottom) / 2 : top + gap * k)
      ];
    }

    final cols = [for (var i = 0; i < n; i++) colPoints(i)];

    // connections (fade in with t)
    final line = Paint()
      ..color = Colors.white.withValues(alpha: 0.18 * t)
      ..strokeWidth = 1;
    for (var i = 0; i < n - 1; i++) {
      for (final a in cols[i]) {
        for (final b in cols[i + 1]) {
          canvas.drawLine(a, b, line);
        }
      }
    }

    // nodes (scale in with t)
    for (var i = 0; i < n; i++) {
      final isOutput = i == n - 1;
      final fill = Paint()
        ..color = isOutput
            ? const Color(0xFFFFD9CF)
            : Colors.white.withValues(alpha: 0.95);
      for (final pt in cols[i]) {
        canvas.drawCircle(pt, (isOutput ? 7.5 : 5.5) * t, fill);
      }
      // truncation hint if the real layer is larger than what we drew
      if (layers[i] > dotsPerCol[i]) {
        final tp = TextPainter(
          text: const TextSpan(
              text: '⋮',
              style: TextStyle(color: Colors.white, fontSize: 16)),
          textDirection: TextDirection.ltr,
        )..layout();
        tp.paint(canvas,
            Offset(colX[i] - tp.width / 2, size.height * 0.80));
      }
      // layer size label
      final label = TextPainter(
        text: TextSpan(
            text: '${layers[i]}',
            style: TextStyle(
                color: Colors.white.withValues(alpha: 0.9 * t),
                fontSize: 12,
                fontWeight: FontWeight.w700)),
        textDirection: TextDirection.ltr,
      )..layout();
      label.paint(
          canvas, Offset(colX[i] - label.width / 2, size.height * 0.90));
    }

    // output labels
    if (n >= 2) {
      final outCol = cols[n - 1];
      const names = ['Diabetes', 'Kidney'];
      for (var k = 0; k < outCol.length && k < names.length; k++) {
        final tp = TextPainter(
          text: TextSpan(
              text: names[k],
              style: TextStyle(
                  color: Colors.white.withValues(alpha: t),
                  fontSize: 10.5,
                  fontWeight: FontWeight.w600)),
          textDirection: TextDirection.ltr,
        )..layout();
        tp.paint(canvas,
            Offset(outCol[k].dx - tp.width - 12, outCol[k].dy - tp.height / 2));
      }
    }
  }

  @override
  bool shouldRepaint(_NetPainter old) => old.t != t || old.layers != layers;
}

// ---------------------------------------------------------------------------
class _LoadingSkeleton extends StatelessWidget {
  const _LoadingSkeleton();
  @override
  Widget build(BuildContext context) {
    final p = Palette.of(context);
    Widget box(double h) => Container(
          height: h,
          margin: const EdgeInsets.only(bottom: 14),
          decoration: BoxDecoration(
              color: p.isDark ? const Color(0xFF243029) : const Color(0xFFEDF1EE),
              borderRadius: BorderRadius.circular(AppTheme.radius)),
        );
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
      physics: const NeverScrollableScrollPhysics(),
      children: [box(190), box(120), box(150), box(150), box(120)],
    ).animate(onPlay: (c) => c.repeat()).shimmer(
        duration: 1200.ms,
        color: p.isDark ? Colors.white10 : Colors.white);
  }
}

/// How well the model works, reported the way a screening model should be.
///
/// Accuracy is deliberately NOT the headline. Both conditions are rare, so a
/// model that answers "no" to everybody scores extremely well on accuracy
/// while catching nobody: kidney disease appears in 3.7% of this dataset, so
/// "always no" is 96.3% accurate and 0% useful. ROC-AUC and recall cannot be
/// won that way, so those lead, and the accuracy trap is stated openly rather
/// than hidden behind a flattering number.
class _PerformanceCard extends StatelessWidget {
  final Map<String, dynamic> dia;
  final Map<String, dynamic> kid;
  final bool calibrated;
  final bool crossValidated;
  final int folds;
  final Palette p;
  const _PerformanceCard({
    required this.dia,
    required this.kid,
    required this.calibrated,
    required this.crossValidated,
    required this.folds,
    required this.p,
  });

  double _n(Map<String, dynamic> m, String k) =>
      (m[k] as num?)?.toDouble() ?? 0;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return SoftCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('How well it works', style: t.headlineSmall),
          const SizedBox(height: 6),
          Text('Measured on held-out people the model never saw in training.',
              style: t.bodySmall),
          const SizedBox(height: 20),
          Row(children: [
            const Expanded(flex: 4, child: SizedBox()),
            Expanded(
                flex: 3,
                child: Text('Diabetes',
                    textAlign: TextAlign.end,
                    style:
                        t.labelMedium?.copyWith(color: p.on(AppTheme.green)))),
            Expanded(
                flex: 3,
                child: Text('Kidney',
                    textAlign: TextAlign.end,
                    style:
                        t.labelMedium?.copyWith(color: p.on(AppTheme.coral)))),
          ]),
          const SizedBox(height: 10),
          Rule(),
          _row(context, 'ROC-AUC', _n(dia, 'roc_auc'), _n(kid, 'roc_auc'),
              decimals: 2,
              percent: false,
              note: 'Tells the two groups apart. 0.5 would be a coin toss.'),
          _row(context, 'Recall', _n(dia, 'recall'), _n(kid, 'recall'),
              note: 'Share of real cases the screening catches.'),
          _row(context, 'Precision', _n(dia, 'precision'), _n(kid, 'precision'),
              note: 'Share of flagged people who truly have it.'),
          _row(context, 'Balanced accuracy', _n(dia, 'balanced_accuracy'),
              _n(kid, 'balanced_accuracy'),
              note: 'Accuracy corrected for how rare the condition is.',
              last: true),
          const SizedBox(height: 18),
          Wrap(spacing: 8, runSpacing: 8, children: [
            if (crossValidated) _chip('$folds-fold cross-validated'),
            if (calibrated) _chip('Calibrated probabilities'),
            _chip('Held-out test set'),
          ]),
          const SizedBox(height: 22),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: p.sunk,
              borderRadius: BorderRadius.circular(AppTheme.rControl),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Why accuracy is not the headline', style: t.titleSmall),
                const SizedBox(height: 8),
                Text(
                    'Kidney disease appears in about 4 people in 100. A model '
                    'that simply answered no to everyone would be right 96% of '
                    'the time and would catch nobody. That is why this screen '
                    'leads with recall and ROC-AUC, which cannot be won that '
                    'way.',
                    style: t.bodySmall?.copyWith(height: 1.6)),
                const SizedBox(height: 12),
                Text(
                    'Aegis is tuned to catch cases rather than to look precise. '
                    'It accepts false alarms, because in screening a missed '
                    'case costs far more than an unnecessary check.',
                    style: t.bodySmall?.copyWith(height: 1.6)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _row(BuildContext context, String label, double a, double b,
      {String? note,
      int decimals = 0,
      bool percent = true,
      bool last = false}) {
    final t = Theme.of(context).textTheme;
    String fmt(double v) => percent
        ? '${(v * 100).toStringAsFixed(decimals)}%'
        : v.toStringAsFixed(decimals);

    return Column(children: [
      Padding(
        padding: const EdgeInsets.symmetric(vertical: 13),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 4,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: t.titleSmall),
                  if (note != null) ...[
                    const SizedBox(height: 3),
                    Text(note, style: t.bodySmall?.copyWith(fontSize: 11.5)),
                  ],
                ],
              ),
            ),
            Expanded(
                flex: 3,
                child: Text(fmt(a),
                    textAlign: TextAlign.end,
                    style: TextStyle(
                        fontFamily: AppTheme.mono,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: p.ink))),
            Expanded(
                flex: 3,
                child: Text(fmt(b),
                    textAlign: TextAlign.end,
                    style: TextStyle(
                        fontFamily: AppTheme.mono,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: p.ink))),
          ],
        ),
      ),
      if (!last) Rule(),
    ]);
  }

  Widget _chip(String text) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
            color: p.tint(AppTheme.green),
            borderRadius: BorderRadius.circular(AppTheme.rPill)),
        child: Text(text,
            style: TextStyle(
                fontFamily: AppTheme.sans,
                color: p.on(AppTheme.green),
                fontWeight: FontWeight.w600,
                fontSize: 12)),
      );
}

class _DatasetCard extends StatelessWidget {
  final Map<String, dynamic> ds;
  final Palette p;
  const _DatasetCard(this.ds, this.p);
  @override
  Widget build(BuildContext context) {
    final records = ds['records'] as int;
    return SoftCard(
      child: Row(
        children: [
          Container(
            height: 54,
            width: 54,
            decoration: BoxDecoration(
                color: p.tint(AppTheme.green),
                borderRadius: BorderRadius.circular(AppTheme.radius)),
            child: const Icon(Icons.dataset_rounded,
                color: AppTheme.green, size: 26),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0, end: records.toDouble()),
                  duration: const Duration(milliseconds: 1400),
                  curve: Curves.easeOutCubic,
                  builder: (_, v, __) => Text(
                    '${_Content._fmt(v.round())} people',
                    style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: p.ink),
                  ),
                ),
                const SizedBox(height: 2),
                Text('${ds['name']} · ${ds['full_name']}',
                    style: TextStyle(color: p.subtle, fontSize: 12.5)),
                const SizedBox(height: 2),
                Text('${ds['features']} lifestyle features · ${ds['source']}',
                    style: TextStyle(color: p.subtle, fontSize: 12)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
class _PerfCard extends StatelessWidget {
  final Map<String, dynamic> m;
  final Color color;
  final IconData icon;
  final Palette p;
  const _PerfCard(this.m, this.color, this.icon, this.p);

  @override
  Widget build(BuildContext context) {
    final auc = (m['roc_auc'] as num).toDouble();
    final recall = (m['recall'] as num).toDouble();
    return SoftCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Container(width: 10, height: 10, color: color),
            const SizedBox(width: 10),
            Text(m['name'] as String,
                style: AppType.h2.copyWith(color: p.ink)),
            const Spacer(),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                  color: p.tint(color),
                  borderRadius: BorderRadius.circular(AppTheme.radius)),
              child: Text('${m['prevalence']}% have it',
                  style: TextStyle(
                      color: p.ink,
                      fontWeight: FontWeight.w700,
                      fontSize: 11.5)),
            ),
          ]),
          const SizedBox(height: 16),
          _bar('ROC-AUC', auc, color, p),
          const SizedBox(height: 12),
          _bar('Recall (cases caught)', recall, AppTheme.amber, p),
        ],
      ),
    );
  }

  Widget _bar(String label, double v, Color color, Palette p) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text(label, style: TextStyle(color: p.ink, fontSize: 13)),
          Text(v.toStringAsFixed(2),
              style: TextStyle(
                  color: color, fontWeight: FontWeight.w700, fontSize: 13)),
        ]),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(AppTheme.radius),
          child: TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: v),
            duration: const Duration(milliseconds: 1000),
            curve: Curves.easeOut,
            builder: (_, val, __) => LinearProgressIndicator(
              value: val,
              minHeight: 9,
              backgroundColor: p.line,
              color: color,
            ),
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
class _MetricsBars extends StatelessWidget {
  final Map<String, dynamic> dia;
  final Map<String, dynamic> kid;
  final Palette p;
  const _MetricsBars(this.dia, this.kid, this.p);

  @override
  Widget build(BuildContext context) {
    BarChartGroupData group(int x, double auc, double recall) {
      return BarChartGroupData(x: x, barsSpace: 6, barRods: [
        BarChartRodData(
            toY: auc * 100,
            color: AppTheme.green,
            width: 15,
            borderRadius: BorderRadius.circular(4)),
        BarChartRodData(
            toY: recall * 100,
            color: AppTheme.amber,
            width: 15,
            borderRadius: BorderRadius.circular(4)),
      ]);
    }

    return BarChart(
      BarChartData(
        maxY: 100,
        alignment: BarChartAlignment.spaceAround,
        gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            horizontalInterval: 25,
            getDrawingHorizontalLine: (_) =>
                FlLine(color: p.line, strokeWidth: 1)),
        borderData: FlBorderData(show: false),
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
              sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 30,
                  interval: 25,
                  getTitlesWidget: (v, _) => Text('${v.toInt()}',
                      style: TextStyle(color: p.subtle, fontSize: 10)))),
          rightTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                  showTitles: true,
                  getTitlesWidget: (v, _) {
                    const labels = ['Diabetes', 'Kidney'];
                    return Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: Text(labels[v.toInt()],
                          style: TextStyle(
                              color: p.ink,
                              fontSize: 12,
                              fontWeight: FontWeight.w600)),
                    );
                  })),
        ),
        barGroups: [
          group(0, (dia['roc_auc'] as num).toDouble(),
              (dia['recall'] as num).toDouble()),
          group(1, (kid['roc_auc'] as num).toDouble(),
              (kid['recall'] as num).toDouble()),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
class _ConfusionCard extends StatelessWidget {
  final Map<String, dynamic> m;
  final Palette p;
  const _ConfusionCard(this.m, this.p);

  @override
  Widget build(BuildContext context) {
    final c = m['confusion'] as Map<String, dynamic>;
    final tp = c['tp'] as int, fn = c['fn'] as int;
    final fp = c['fp'] as int, tn = c['tn'] as int;
    final caught = m['caught'] as int;
    final total = m['total_cases'] as int;
    final recallPct = ((m['recall'] as num) * 100).round();

    return SoftCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(m['name'] as String,
              style: TextStyle(fontWeight: FontWeight.w700, color: p.ink)),
          const SizedBox(height: 12),
          Row(children: [
            const SizedBox(width: 74),
            Expanded(
                child: Center(
                    child: Text('Flagged',
                        style: TextStyle(
                            color: p.subtle,
                            fontSize: 11.5,
                            fontWeight: FontWeight.w600)))),
            Expanded(
                child: Center(
                    child: Text('Cleared',
                        style: TextStyle(
                            color: p.subtle,
                            fontSize: 11.5,
                            fontWeight: FontWeight.w600)))),
          ]),
          const SizedBox(height: 6),
          _row('Has disease', _cell('$tp', 'caught', AppTheme.green, p),
              _cell('$fn', 'missed', AppTheme.high, p), p),
          const SizedBox(height: 8),
          _row('Healthy', _cell('$fp', 'false alarm', AppTheme.amber, p),
              _cell('$tn', 'correct', p.subtle, p), p),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
                color: p.tint(AppTheme.green),
                borderRadius: BorderRadius.circular(AppTheme.radius)),
            child: Text(
                'Caught ${_Content._fmt(caught)} of ${_Content._fmt(total)} real '
                'cases ($recallPct% recall). It leans toward caution, because a false '
                'alarm is safer than a missed case.',
                style: TextStyle(color: p.ink, fontSize: 12.5, height: 1.4)),
          ),
        ],
      ),
    );
  }

  Widget _row(String label, Widget a, Widget b, Palette p) => Row(children: [
        SizedBox(
            width: 74,
            child: Text(label,
                style: TextStyle(
                    color: p.ink, fontSize: 12, fontWeight: FontWeight.w600))),
        Expanded(child: a),
        const SizedBox(width: 8),
        Expanded(child: b),
      ]);

  Widget _cell(String value, String tag, Color color, Palette p) => Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
            color: color.withValues(alpha: p.isDark ? 0.22 : 0.12),
            borderRadius: BorderRadius.circular(AppTheme.radius)),
        child: Column(children: [
          Text(_Content._fmt(int.parse(value)),
              style: TextStyle(
                  color: color == p.subtle ? p.ink : color,
                  fontWeight: FontWeight.w700,
                  fontSize: 15)),
          Text(tag, style: TextStyle(color: p.subtle, fontSize: 10.5)),
        ]),
      );
}

// ---------------------------------------------------------------------------
class _WhyRecallCard extends StatelessWidget {
  final Palette p;
  const _WhyRecallCard(this.p);
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
          color: p.tint(AppTheme.amber),
          borderRadius: BorderRadius.circular(AppTheme.radius)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            const Icon(Icons.psychology_alt_rounded, color: AppTheme.amber),
            const SizedBox(width: 8),
            Text('Why Recall, not Accuracy?',
                style: TextStyle(
                    fontWeight: FontWeight.w700, color: p.ink, fontSize: 15)),
          ]),
          const SizedBox(height: 10),
          Text(
              'Only ~14% of people have diabetes and ~4% have kidney disease. '
              'A lazy model that says “nobody is at risk” would still score '
              '86 to 96% accuracy while catching zero real cases. '
              'So we optimise Recall (how many true cases we catch) and '
              'ROC-AUC instead. That is the honest way to judge a screening model.',
              style: TextStyle(color: p.ink, fontSize: 13, height: 1.5)),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
class _MethodTile extends StatelessWidget {
  final int n;
  final String text;
  final Palette p;
  const _MethodTile(this.n, this.text, this.p);
  @override
  Widget build(BuildContext context) {
    return SoftCard(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 26,
            child: Text(n.toString().padLeft(2, '0'),
                style: AppType.mono.copyWith(color: AppTheme.green)),
          ),
          Expanded(
              child: Text(text,
                  style: AppType.small.copyWith(color: p.ink, height: 1.55))),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
class _SectionTitle extends StatelessWidget {
  final String text;
  final IconData icon;
  final Palette p;
  const _SectionTitle(this.text, this.icon, this.p);
  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Icon(icon, color: AppTheme.green, size: 22),
      const SizedBox(width: 8),
      Text(text,
          style: TextStyle(
              fontSize: 18, fontWeight: FontWeight.w700, color: p.ink)),
    ]);
  }
}
