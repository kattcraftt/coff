import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

class BarRow {
  const BarRow({
    required this.label,
    required this.value,
    required this.color,
    this.trailing,
  });

  final String label;
  final double value;
  final Color color;
  final String? trailing;
}

/// Labelled horizontal bars scaled to the largest value.
class HorizontalBars extends StatelessWidget {
  const HorizontalBars({required this.rows, super.key});

  final List<BarRow> rows;

  @override
  Widget build(BuildContext context) {
    final max = rows.fold<double>(0, (m, r) => r.value > m ? r.value : m);

    return Column(
      children: [
        for (final r in rows)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        r.label,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(color: AppColors.muted),
                      ),
                    ),
                    if (r.trailing != null)
                      Text(
                        r.trailing!,
                        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
                      ),
                  ],
                ),
                const SizedBox(height: 4),
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: LinearProgressIndicator(
                    value: max == 0 ? 0 : r.value / max,
                    minHeight: 8,
                    color: r.color,
                    backgroundColor: r.color.withValues(alpha: 0.12),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
