import 'package:flutter/material.dart';

import '../../../core/config/env.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/horizontal_bars.dart';
import '../data/overview.dart';

/// Where the most money went, by payee / merchant.
class TopPayeesCard extends StatelessWidget {
  const TopPayeesCard({required this.payees, super.key});

  final List<PayeeTotal> payees;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Top payees',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            if (payees.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 24),
                child: Center(
                  child: Text('No expenses in this period', style: TextStyle(color: AppColors.muted)),
                ),
              )
            else
              HorizontalBars(
                rows: [
                  for (var i = 0; i < payees.length; i++)
                    BarRow(
                      label: payees[i].payee,
                      value: payees[i].amount,
                      color: AppColors.categoryPalette[i % AppColors.categoryPalette.length],
                      trailing: formatMoney(payees[i].amount, Env.currencyCode),
                    ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
