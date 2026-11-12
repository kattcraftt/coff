import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../../core/config/env.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/formatters.dart';
import '../data/overview.dart';

/// "Categories" card: where the money went, as a donut or pie.
class CategoriesCard extends StatefulWidget {
  const CategoriesCard({required this.categories, super.key});

  final List<CategoryTotal> categories;

  @override
  State<CategoriesCard> createState() => _CategoriesCardState();
}

class _CategoriesCardState extends State<CategoriesCard> {
  bool _donut = true;

  Color _color(int i) =>
      AppColors.categoryPalette[i % AppColors.categoryPalette.length];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final categories = widget.categories;
    final total = categories.fold<double>(0, (sum, c) => sum + c.amount);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Categories',
                    style: theme.textTheme.titleMedium
                        ?.copyWith(fontWeight: FontWeight.w700),
                  ),
                ),
                PopupMenuButton<bool>(
                  onSelected: (v) => setState(() => _donut = v),
                  itemBuilder: (context) => const [
                    PopupMenuItem(value: true, child: Text('Donut chart')),
                    PopupMenuItem(value: false, child: Text('Pie chart')),
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
                        const Icon(Icons.pie_chart_outline, size: 18),
                        const SizedBox(width: 6),
                        Text(
                          _donut ? 'Donut chart' : 'Pie chart',
                          style: const TextStyle(fontSize: 13),
                        ),
                        const Icon(Icons.expand_more, size: 18),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (categories.isEmpty || total == 0)
              const SizedBox(
                height: 120,
                child: Center(
                  child: Text(
                    'No expenses in this period',
                    style: TextStyle(color: AppColors.muted),
                  ),
                ),
              )
            else ...[
              SizedBox(
                height: 180,
                child: PieChart(
                  PieChartData(
                    sectionsSpace: 2,
                    centerSpaceRadius: _donut ? 52 : 0,
                    pieTouchData: PieTouchData(enabled: false),
                    sections: [
                      for (var i = 0; i < categories.length; i++)
                        PieChartSectionData(
                          value: categories[i].amount,
                          color: _color(i),
                          radius: 38,
                          showTitle: false,
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              for (var i = 0; i < categories.length; i++)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    children: [
                      Container(
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                          color: _color(i),
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          categories[i].name,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(color: AppColors.muted),
                        ),
                      ),
                      Text(
                        formatMoney(categories[i].amount, Env.currencyCode),
                        style: const TextStyle(fontSize: 12, color: AppColors.muted),
                      ),
                      const SizedBox(width: 10),
                      SizedBox(
                        width: 44,
                        child: Text(
                          '${(categories[i].amount / total * 100).toStringAsFixed(0)}%',
                          textAlign: TextAlign.right,
                          style: const TextStyle(fontWeight: FontWeight.w700),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ],
        ),
      ),
    );
  }
}
