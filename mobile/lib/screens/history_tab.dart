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
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 4),
            child: Text('Your History',
                style: TextStyle(
                    fontSize: 26, fontWeight: FontWeight.w800, color: p.ink)),
          ),
          Expanded(
            child: FutureBuilder<List<dynamic>>(
              future: _future,
              builder: (context, snap) {
                if (snap.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snap.hasError) {
                  return _empty(p, 'Couldn’t load history.', _reload);
                }
                final items = (snap.data ?? []).cast<Map<String, dynamic>>();
                if (items.isEmpty) {
                  return _empty(p, 'No assessments yet.\nRun your first check!', null);
                }
                return RefreshIndicator(
                  onRefresh: () async => _reload(),
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                    children: [
                      _TrendCard(items),
                      const SizedBox(height: 18),
                      Text('Past checks',
                          style: TextStyle(
                              fontWeight: FontWeight.w800,
                              color: p.ink,
                              fontSize: 16)),
                      const SizedBox(height: 10),
                      ...items.map((a) => _HistoryTile(a)),
                    ],
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
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.timeline_rounded, size: 60, color: p.line),
          const SizedBox(height: 12),
          Text(msg,
              textAlign: TextAlign.center,
              style: TextStyle(color: p.subtle)),
          if (retry != null) ...[
            const SizedBox(height: 12),
            TextButton(onPressed: retry, child: const Text('Retry')),
          ],
        ],
      ),
    );
  }
}

class _TrendCard extends StatelessWidget {
  final List<Map<String, dynamic>> items;
  const _TrendCard(this.items);

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
    return SoftCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Risk over time',
              style: TextStyle(fontWeight: FontWeight.w800, color: p.ink)),
          const SizedBox(height: 6),
          const Row(children: [
            _Legend(AppTheme.green, 'Diabetes'),
            SizedBox(width: 16),
            _Legend(AppTheme.coral, 'Kidney'),
          ]),
          const SizedBox(height: 16),
          SizedBox(
            height: 160,
            child: LineChart(
              LineChartData(
                minY: 0,
                gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    getDrawingHorizontalLine: (_) =>
                        FlLine(color: p.line, strokeWidth: 1)),
                titlesData: const FlTitlesData(
                  leftTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: true, reservedSize: 30)),
                  rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                borderData: FlBorderData(show: false),
                lineBarsData: [
                  _line(dia, AppTheme.green),
                  _line(kid, AppTheme.coral),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  LineChartBarData _line(List<FlSpot> spots, Color color) => LineChartBarData(
        spots: spots,
        isCurved: true,
        color: color,
        barWidth: 3,
        dotData: const FlDotData(show: true),
        belowBarData:
            BarAreaData(show: true, color: color.withValues(alpha: 0.10)),
      );
}

class _Legend extends StatelessWidget {
  final Color color;
  final String label;
  const _Legend(this.color, this.label);
  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Container(width: 12, height: 12,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
      const SizedBox(width: 6),
      Text(label,
          style: TextStyle(color: Palette.of(context).subtle, fontSize: 12.5)),
    ]);
  }
}

class _HistoryTile extends StatelessWidget {
  final Map<String, dynamic> a;
  const _HistoryTile(this.a);
  @override
  Widget build(BuildContext context) {
    final p = Palette.of(context);
    final dia = ((a['diabetes_risk'] as num) * 100).round();
    final kid = ((a['kidney_risk'] as num) * 100).round();
    final date = (a['created_at'] as String).split('T').first;
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      child: SoftCard(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
                builder: (_) =>
                    ResultScreen(result: a['result'] as Map<String, dynamic>))),
        child: Row(
          children: [
            CircleAvatar(
                radius: 22,
                backgroundColor: p.tint(AppTheme.green),
                child: const Icon(Icons.assignment_turned_in_rounded,
                    color: AppTheme.green)),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Diabetes $dia%   ·   Kidney $kid%',
                      style: TextStyle(
                          fontWeight: FontWeight.w700, color: p.ink)),
                  Text(date,
                      style: TextStyle(color: p.subtle, fontSize: 12.5)),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded, color: p.subtle),
          ],
        ),
      ),
    );
  }
}
