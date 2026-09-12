import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../core/api_client.dart';
import '../core/theme.dart';
import 'result_screen.dart';

class HistoryTab extends StatefulWidget {
  const HistoryTab({super.key});
  @override
  State<HistoryTab> createState() => _HistoryTabState();
}

class _HistoryTabState extends State<HistoryTab> {
  late Future<List<dynamic>> _future;

  @override
  void initState() {
    super.initState();
    _future = ApiClient.instance.history();
  }

  void _reload() => setState(() => _future = ApiClient.instance.history());

  @override
  Widget build(BuildContext context) {
    final p = Palette.of(context);
    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
                AppTheme.gutter, 18, AppTheme.gutter, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('History', style: AppType.display.copyWith(color: p.ink)),
                const SizedBox(height: 14),
                Rule(),
              ],
            ),
          ),
          Expanded(
            child: FutureBuilder<List<dynamic>>(
              future: _future,
              builder: (context, snap) {
                if (snap.connectionState == ConnectionState.waiting) {
                  return const Center(
                      child: SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2)));
                }
                if (snap.hasError) {
                  return _empty(p, 'Could not load your history.', _reload);
                }
                final items = (snap.data ?? []).cast<Map<String, dynamic>>();
                if (items.isEmpty) {
                  return _empty(
                      p,
                      'Nothing recorded yet. Run a check and it will appear '
                      'here, so you can watch the numbers move.',
                      null);
                }
                // The header block counts as one item, so the rows below it
                // are built lazily as they scroll into view.
                final hasTrend = items.length > 1;
                return RefreshIndicator(
                  onRefresh: () async => _reload(),
                  child: ListView.builder(
                    padding: const EdgeInsets.fromLTRB(
                        AppTheme.gutter, 6, AppTheme.gutter, 28),
                    itemCount: items.length + 1,
                    itemBuilder: (context, i) {
                      if (i == 0) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (hasTrend) ...[
                              const SectionLabel('Trend'),
                              _Trend(items),
                              const SizedBox(height: 32),
                            ],
                            SectionLabel('Checks · ${items.length}'),
                          ],
                        );
                      }
                      return _HistoryRow(items[i - 1]);
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _empty(Palette p, String msg, VoidCallback? retry) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppTheme.gutter),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 8),
          Text(msg, style: AppType.body.copyWith(color: p.subtle)),
          if (retry != null) ...[
            const SizedBox(height: 16),
            TextButton(
                onPressed: retry,
                style: TextButton.styleFrom(padding: EdgeInsets.zero),
                child: const Text('Try again')),
          ],
        ],
      ),
    );
  }
}

/// Risk over time. Straight segments, square dots, a hairline grid, a plot,
/// not an infographic. No curve smoothing (it invents readings between
/// points) and no area fill.
class _Trend extends StatelessWidget {
  final List<Map<String, dynamic>> items;
  const _Trend(this.items);

  @override
  Widget build(BuildContext context) {
    final p = Palette.of(context);
    final data = items.reversed.toList();
    final dia = <FlSpot>[];
    final kid = <FlSpot>[];
    for (var i = 0; i < data.length; i++) {
      dia.add(FlSpot(i.toDouble(), (data[i]['diabetes_risk'] as num) * 100));
      kid.add(FlSpot(i.toDouble(), (data[i]['kidney_risk'] as num) * 100));
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(children: [
          _Legend(AppTheme.green, 'Diabetes'),
          const SizedBox(width: 20),
          _Legend(AppTheme.coral, 'Kidney'),
        ]),
        const SizedBox(height: 18),
        SizedBox(
          height: 150,
          child: LineChart(
            LineChartData(
              minY: 0,
              gridData: FlGridData(
                show: true,
                drawVerticalLine: false,
                getDrawingHorizontalLine: (_) =>
                    FlLine(color: p.line, strokeWidth: AppTheme.hair),
              ),
              titlesData: FlTitlesData(
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 34,
                    getTitlesWidget: (v, _) => Text('${v.toInt()}',
                        style: AppType.mono
                            .copyWith(color: p.subtle, fontSize: 10)),
                  ),
                ),
                rightTitles:
                    const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                topTitles:
                    const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                bottomTitles:
                    const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              ),
              borderData: FlBorderData(show: false),
              lineBarsData: [
                _line(dia, AppTheme.green, p),
                _line(kid, AppTheme.coral, p),
              ],
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text('PER CENT RISK · OLDEST TO NEWEST',
            style: AppType.label
                .copyWith(color: p.subtle, fontSize: 9, letterSpacing: 0.9)),
      ],
    );
  }

  LineChartBarData _line(List<FlSpot> spots, Color color, Palette p) =>
      LineChartBarData(
        spots: spots,
        isCurved: false,
        color: color,
        barWidth: 1.6,
        dotData: FlDotData(
          show: true,
          getDotPainter: (spot, _, __, ___) => FlDotSquarePainter(
            size: 5,
            color: color,
            strokeWidth: 0,
            strokeColor: Colors.transparent,
          ),
        ),
        belowBarData: BarAreaData(show: false),
      );
}

class _Legend extends StatelessWidget {
  final Color color;
  final String label;
  const _Legend(this.color, this.label);
  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Container(width: 9, height: 9, color: color),
      const SizedBox(width: 7),
      Text(label,
          style: AppType.label.copyWith(color: Palette.of(context).subtle)),
    ]);
  }
}

/// One past check as a table row: date left, both figures right-aligned in the
/// monospace face so the columns line up down the page.
class _HistoryRow extends StatelessWidget {
  final Map<String, dynamic> a;
  const _HistoryRow(this.a);

  static const _months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
  ];

  @override
  Widget build(BuildContext context) {
    final p = Palette.of(context);
    final dia = ((a['diabetes_risk'] as num) * 100).toDouble();
    final kid = ((a['kidney_risk'] as num) * 100).toDouble();
    final d = DateTime.tryParse(a['created_at'] as String)?.toLocal();
    final date = d == null
        ? (a['created_at'] as String).split('T').first
        : '${d.day.toString().padLeft(2, '0')} ${_months[d.month - 1]} ${d.year}';

    return Column(
      children: [
        InkWell(
          onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (_) => ResultScreen(
                      result: a['result'] as Map<String, dynamic>))),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 14),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Text(date,
                      style: AppType.body.copyWith(
                          color: p.ink, fontWeight: FontWeight.w500)),
                ),
                _fig('DIA', dia, AppTheme.green, p),
                const SizedBox(width: 18),
                _fig('KID', kid, AppTheme.coral, p),
                const SizedBox(width: 12),
                Icon(Icons.arrow_forward, size: 14, color: p.subtle),
              ],
            ),
          ),
        ),
        Rule(),
      ],
    );
  }

  Widget _fig(String label, double v, Color color, Palette p) => Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(label,
              style: AppType.label.copyWith(color: p.subtle, fontSize: 9)),
          const SizedBox(height: 2),
          Text('${v.toStringAsFixed(1)}%',
              style: AppType.mono.copyWith(color: color, fontSize: 14)),
        ],
      );
}
