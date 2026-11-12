import 'package:flutter/material.dart';

import '../../../core/config/env.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/formatters.dart';

/// One of the Remaining / Income / Expenses cards from the web dashboard.
class SummaryCard extends StatelessWidget {
  const SummaryCard({
    required this.title,
    required this.periodLabel,
    required this.amount,
    required this.previous,
    required this.icon,
    required this.iconBackground,
    required this.iconColor,
    this.higherIsBetter = true,
    this.compareMagnitude = false,
    super.key,
  });

  final String title;
  final String periodLabel;
  final double amount;
  final double previous;
  final IconData icon;
  final Color iconBackground;
  final Color iconColor;

  /// For expenses, an increase is bad news (shown in red).
  final bool higherIsBetter;

  /// Expenses are negative; compare their size, not their sign.
  final bool compareMagnitude;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: theme.textTheme.titleMedium
                        ?.copyWith(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    periodLabel,
                    style: theme.textTheme.bodySmall
                        ?.copyWith(color: AppColors.muted),
                  ),
                  const SizedBox(height: 12),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: Text(
                      formatMoney(amount, Env.currencyCode),
                      style: theme.textTheme.headlineSmall
                          ?.copyWith(fontWeight: FontWeight.w800),
                    ),
                  ),
                  const SizedBox(height: 6),
                  _Change(
                    current: compareMagnitude ? amount.abs() : amount,
                    previous: compareMagnitude ? previous.abs() : previous,
                    higherIsBetter: higherIsBetter,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: iconBackground,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: iconColor, size: 22),
            ),
          ],
        ),
      ),
    );
  }
}

class _Change extends StatelessWidget {
  const _Change({
    required this.current,
    required this.previous,
    required this.higherIsBetter,
  });

  final double current;
  final double previous;
  final bool higherIsBetter;

  @override
  Widget build(BuildContext context) {
    final style = Theme.of(context).textTheme.bodySmall;

    if (previous == 0) {
      return Text(
        'No data last period',
        style: style?.copyWith(color: AppColors.muted),
      );
    }

    final pct = (current - previous) / previous.abs() * 100;
    final up = pct >= 0;
    final good = up == higherIsBetter;
    final sign = up ? '+' : '';

    return Text(
      '$sign${pct.toStringAsFixed(0)}% from last period',
      style: style?.copyWith(
        color: good ? AppColors.income : AppColors.expense,
        fontWeight: FontWeight.w500,
      ),
    );
  }
}
