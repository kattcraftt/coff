import 'dart:math' as math;

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../core/config/env.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/formatters.dart';
import '../data/overview.dart';

enum _ChartType {
  area('Area chart', Icons.area_chart_outlined),
  line('Line chart', Icons.show_chart),
  bar('Bar chart', Icons.bar_chart);

  const _ChartType(this.label, this.icon);

  final String label;
  final IconData icon;
}

/// "Transactions" card: income vs expenses per day, as area / line / bar.
class TransactionsChartCard extends StatefulWidget {
  const TransactionsChartCard({required this.daily, super.key});

  final List<DailyTotal> daily;

  @override
  State<TransactionsChartCard> createState() => _TransactionsChartCardState();
}

class _TransactionsChartCardState extends State<TransactionsChartCard> {
  _ChartType _type = _ChartType.area;

  List<DailyTotal> get _daily => widget.daily;

  double get _maxY {
    var max = 0.0;
    for (final d in _daily) {
      max = math.max(max, math.max(d.income, d.expenses.abs()));
    }
    return max == 0 ? 1 : max * 1.15;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasData = _daily.any((d) => d.income != 0 || d.expenses != 0);

    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Transactions',
                    style: theme.textTheme.titleMedium
                        ?.copyWith(fontWeight: FontWeight.w700),
                  ),
                ),
                _TypePicker(
                  value: _type,
                  onChanged: (t) => setState(() => _type = t),
                ),
              ],
            ),
            const SizedBox(height: 8),
            const Row(
              children: [
                _LegendDot(color: AppColors.income, label: 'Income'),
                SizedBox(width: 16),
                _LegendDot(color: AppColors.expense, label: 'Expenses'),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 220,
              child: hasData
                  ? (_type == _ChartType.bar ? _bar() : _line())
                  : const Center(
                      child: Text(
                        'No transactions in this period',
                        style: TextStyle(color: AppColors.muted),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  FlTitlesData _titles(double top) {
    const labelStyle = TextStyle(fontSize: 10, color: AppColors.muted);
    final bottomInterval = math.max(1, (_daily.length / 5).ceil()).toDouble();

    return FlTitlesData(
      topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
      rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
      leftTitles: AxisTitles(
        sideTitles: SideTitles(
          showTitles: true,
          reservedSize: 44,
          interval: top / 4,
          getTitlesWidget: (value, meta) => SideTitleWidget(
            meta: meta,
            child: Text(NumberFormat.compact().format(value), style: labelStyle),
          ),
        ),
      ),
      bottomTitles: AxisTitles(
        sideTitles: SideTitles(
          showTitles: true,
          reservedSize: 28,
          interval: bottomInterval,
          getTitlesWidget: (value, meta) {
            final i = value.toInt();
            if (i < 0 || i >= _daily.length) return const SizedBox.shrink();
            return SideTitleWidget(
              meta: meta,
              child: Text(
                DateFormat('d MMM').format(_daily[i].date),
                style: labelStyle,
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _line() {
    final top = _maxY;
    final area = _type == _ChartType.area;

    LineChartBarData series(List<FlSpot> spots, Color color) => LineChartBarData(
          spots: spots,
          isCurved: true,
          curveSmoothness: 0.2,
          color: color,
          barWidth: 2.5,
          dotData: const FlDotData(show: false),
          belowBarData: BarAreaData(
            show: area,
            color: color.withValues(alpha: 0.15),
          ),
        );

    return LineChart(
      LineChartData(
        minY: 0,
        maxY: top,
        minX: 0,
        maxX: math.max(1, _daily.length - 1).toDouble(),
        gridData: FlGridData(drawVerticalLine: false, horizontalInterval: top / 4),
        borderData: FlBorderData(show: false),
        titlesData: _titles(top),
        lineTouchData: LineTouchData(
          touchTooltipData: LineTouchTooltipData(
            getTooltipItems: (spots) => [
              for (final s in spots)
                LineTooltipItem(
                  '${s.barIndex == 0 ? 'Income' : 'Expenses'}: '
                  '${formatMoney(s.y, Env.currencyCode)}',
                  const TextStyle(color: Colors.white, fontSize: 12),
                ),
            ],
          ),
        ),
        lineBarsData: [
          series(
            [for (var i = 0; i < _daily.length; i++) FlSpot(i.toDouble(), _daily[i].income)],
            AppColors.income,
          ),
          series(
            [
              for (var i = 0; i < _daily.length; i++)
                FlSpot(i.toDouble(), _daily[i].expenses.abs()),
            ],
            AppColors.expense,
          ),
        ],
      ),
    );
  }

  Widget _bar() {
    final top = _maxY;

    return BarChart(
      BarChartData(
        minY: 0,
        maxY: top,
        gridData: FlGridData(drawVerticalLine: false, horizontalInterval: top / 4),
        borderData: FlBorderData(show: false),
        titlesData: _titles(top),
        barTouchData: BarTouchData(
          touchTooltipData: BarTouchTooltipData(
            getTooltipItem: (group, groupIndex, rod, rodIndex) => BarTooltipItem(
              '${rodIndex == 0 ? 'Income' : 'Expenses'}: '
              '${formatMoney(rod.toY, Env.currencyCode)}',
              const TextStyle(color: Colors.white, fontSize: 12),
            ),
          ),
        ),
        barGroups: [
          for (var i = 0; i < _daily.length; i++)
            BarChartGroupData(
              x: i,
              barsSpace: 1,
              barRods: [
                BarChartRodData(
                  toY: _daily[i].income,
                  color: AppColors.income,
                  width: 3,
                  borderRadius: BorderRadius.zero,
                ),
                BarChartRodData(
                  toY: _daily[i].expenses.abs(),
                  color: AppColors.expense,
                  width: 3,
                  borderRadius: BorderRadius.zero,
                ),
              ],
            ),
        ],
      ),
    );
  }
}

class _TypePicker extends StatelessWidget {
  const _TypePicker({required this.value, required this.onChanged});

  final _ChartType value;
  final ValueChanged<_ChartType> onChanged;

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<_ChartType>(
      onSelected: onChanged,
      itemBuilder: (context) => [
        for (final t in _ChartType.values)
          PopupMenuItem(
            value: t,
            child: Row(
              children: [Icon(t.icon, size: 18), const SizedBox(width: 8), Text(t.label)],
            ),
          ),
      ],
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.black26),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(value.icon, size: 18),
            const SizedBox(width: 6),
            Text(value.label, style: const TextStyle(fontSize: 13)),
            const Icon(Icons.expand_more, size: 18),
          ],
        ),
      ),
    );
  }
}

class _LegendDot extends StatelessWidget {
  const _LegendDot({required this.color, required this.label});

  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(label, style: const TextStyle(fontSize: 12, color: AppColors.muted)),
      ],
    );
  }
}
