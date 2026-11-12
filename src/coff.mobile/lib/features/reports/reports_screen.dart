import 'package:cross_file/cross_file.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';

import '../../core/config/env.dart';
import '../../core/data/app_transaction.dart';
import '../../core/data/named_item.dart';
import '../../core/data/shared_data.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/formatters.dart';
import '../../core/widgets/period_picker.dart';
import 'report_builder.dart';

enum _Format {
  csv('CSV', 'text/csv', 'csv'),
  pdf('PDF', 'application/pdf', 'pdf');

  const _Format(this.label, this.mime, this.extension);

  final String label;
  final String mime;
  final String extension;
}

/// Export a period of transactions as CSV or PDF and share it (email, Drive...).
class ReportsScreen extends ConsumerStatefulWidget {
  const ReportsScreen({super.key});

  @override
  ConsumerState<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends ConsumerState<ReportsScreen> {
  late DateTimeRange _range = _thisMonth();
  String? _accountId;
  _Format _format = _Format.pdf;
  bool _busy = false;

  static DateTimeRange _thisMonth() {
    final now = DateTime.now();
    return DateTimeRange(
      start: DateTime(now.year, now.month),
      end: DateTime(now.year, now.month, now.day),
    );
  }

  String get _periodLabel =>
      '${DateFormat('MMM d').format(_range.start)} - ${DateFormat('MMM d, yyyy').format(_range.end)}';

  List<AppTransaction> _select(List<AppTransaction> all) {
    return all
        .where((t) =>
    !t.date.isBefore(_range.start) &&
        !t.date.isAfter(_range.end) &&
        (_accountId == null || t.accountId == _accountId))
        .toList()
      ..sort((a, b) => a.date.compareTo(b.date));
  }

  ReportData _buildData(
      List<AppTransaction> selected,
      Map<String, String> accounts,
      Map<String, String> categories,
      ) {
    return ReportData(
      periodLabel: _periodLabel,
      accountLabel: accounts[_accountId] ?? 'All accounts',
      currency: Env.currencyCode,
      rows: [
        for (final t in selected)
          ReportRow(
            date: t.date,
            payee: t.payee,
            category: categories[t.categoryId] ?? 'Uncategorized',
            account: accounts[t.accountId] ?? '',
            amount: t.amount,
            notes: t.notes,
          ),
      ],
    );
  }

  Future<void> _share(ReportData data) async {
    setState(() => _busy = true);
    final messenger = ScaffoldMessenger.of(context);

    try {
      final bytes = _format == _Format.csv ? buildCsv(data) : await buildPdf(data);
      final stamp = DateFormat('yyyyMMdd').format(DateTime.now());
      final name = 'coff-report-$stamp.${_format.extension}';

      await SharePlus.instance.share(
        ShareParams(
          title: 'coff report',
          files: [XFile.fromData(bytes, mimeType: _format.mime)],
          fileNameOverrides: [name],
        ),
      );
    } on Exception catch (e) {
      messenger.showSnackBar(SnackBar(content: Text('Could not create the report: $e')));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final transactions = ref.watch(transactionsProvider);
    final accounts = ref.watch(accountOptionsProvider).value ?? const <NamedItem>[];
    final categories = ref.watch(categoryOptionsProvider).value ?? const <NamedItem>[];
    final accountNames = {for (final a in accounts) a.id: a.name};
    final categoryNames = {for (final c in categories) c.id: c.name};

    return Scaffold(
      appBar: AppBar(title: const Text('Reports')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            'Export your expenses for tax time or reimbursement.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.muted),
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Period', style: TextStyle(fontWeight: FontWeight.w700)),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: [
                      ActionChip(
                        avatar: const Icon(Icons.date_range, size: 18),
                        label: Text(_periodLabel),
                        onPressed: () async {
                          final picked = await pickPeriod(context, current: _range);
                          if (picked != null) setState(() => _range = picked);
                        },
                      ),
                      ActionChip(
                        label: const Text('This month'),
                        onPressed: () => setState(() => _range = _thisMonth()),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Text('Account', style: TextStyle(fontWeight: FontWeight.w700)),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      ChoiceChip(
                        label: const Text('All accounts'),
                        selected: _accountId == null,
                        onSelected: (_) => setState(() => _accountId = null),
                      ),
                      for (final a in accounts)
                        ChoiceChip(
                          label: Text(a.name),
                          selected: _accountId == a.id,
                          onSelected: (_) => setState(() => _accountId = a.id),
                        ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Text('Format', style: TextStyle(fontWeight: FontWeight.w700)),
                  const SizedBox(height: 8),
                  SegmentedButton<_Format>(
                    segments: [
                      for (final f in _Format.values)
                        ButtonSegment(value: f, label: Text(f.label)),
                    ],
                    selected: {_format},
                    onSelectionChanged: (s) => setState(() => _format = s.first),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          transactions.when(
            loading: () => const Padding(
              padding: EdgeInsets.all(32),
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (error, _) => Text('$error'),
            data: (all) {
              final data = _buildData(_select(all), accountNames, categoryNames);
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          _SummaryLine('Transactions', '${data.rows.length}'),
                          _SummaryLine('Income', formatMoney(data.income, Env.currencyCode)),
                          _SummaryLine('Expenses', formatMoney(data.expenses, Env.currencyCode)),
                          const Divider(),
                          _SummaryLine('Net', formatMoney(data.net, Env.currencyCode), bold: true),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  FilledButton.icon(
                    onPressed: (_busy || data.rows.isEmpty) ? null : () => _share(data),
                    icon: _busy
                        ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                        : const Icon(Icons.ios_share),
                    label: Text(
                      data.rows.isEmpty
                          ? 'No transactions in this period'
                          : 'Create ${_format.label} and share',
                    ),
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 96),
        ],
      ),
    );
  }
}

class _SummaryLine extends StatelessWidget {
  const _SummaryLine(this.label, this.value, {this.bold = false});

  final String label;
  final String value;
  final bool bold;

  @override
  Widget build(BuildContext context) {
    final style = TextStyle(fontWeight: bold ? FontWeight.w800 : FontWeight.w500);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(child: Text(label, style: const TextStyle(color: AppColors.muted))),
          Text(value, style: style),
        ],
      ),
    );
  }
}
