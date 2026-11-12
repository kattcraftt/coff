import 'package:flutter/material.dart';

/// Quick presets (like the web dashboard's date picker) plus a custom range.
Future<DateTimeRange?> pickPeriod(
  BuildContext context, {
  DateTimeRange? current,
}) async {
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);

  final presets = <MapEntry<String, DateTimeRange>>[
    MapEntry('Today', DateTimeRange(start: today, end: today)),
    MapEntry(
      'Last 7 days',
      DateTimeRange(start: DateTime(today.year, today.month, today.day - 6), end: today),
    ),
    MapEntry(
      'Last 30 days',
      DateTimeRange(start: DateTime(today.year, today.month, today.day - 29), end: today),
    ),
    MapEntry(
      'This month',
      DateTimeRange(start: DateTime(today.year, today.month), end: today),
    ),
    MapEntry(
      'Last month',
      DateTimeRange(
        start: DateTime(today.year, today.month - 1),
        end: DateTime(today.year, today.month, 0),
      ),
    ),
    MapEntry(
      'Last 3 months',
      DateTimeRange(start: DateTime(today.year, today.month - 2), end: today),
    ),
    MapEntry(
      'This year',
      DateTimeRange(start: DateTime(today.year), end: today),
    ),
  ];

  bool isCurrent(DateTimeRange range) =>
      current != null && current.start == range.start && current.end == range.end;

  final choice = await showModalBottomSheet<Object>(
    context: context,
    showDragHandle: true,
    builder: (sheetContext) => SafeArea(
      child: ListView(
        shrinkWrap: true,
        children: [
          for (final preset in presets)
            ListTile(
              title: Text(preset.key),
              trailing: isCurrent(preset.value) ? const Icon(Icons.check) : null,
              onTap: () => Navigator.of(sheetContext).pop(preset.value),
            ),
          ListTile(
            leading: const Icon(Icons.date_range),
            title: const Text('Custom range...'),
            onTap: () => Navigator.of(sheetContext).pop('custom'),
          ),
        ],
      ),
    ),
  );

  if (choice is DateTimeRange) return choice;
  if (choice == 'custom' && context.mounted) {
    return showDateRangePicker(
      context: context,
      firstDate: DateTime(2000),
      lastDate: DateTime.now().add(const Duration(days: 1)),
      initialDateRange: current,
    );
  }
  return null;
}
