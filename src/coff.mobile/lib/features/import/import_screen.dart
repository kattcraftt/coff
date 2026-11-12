import 'dart:convert';
import 'dart:math' as math;
import 'dart:typed_data';

import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/config/env.dart';
import '../../core/data/data_revision.dart';
import '../../core/data/named_item.dart';
import '../../core/data/shared_data.dart';
import '../../core/network/api_exception.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/formatters.dart';
import '../../core/widgets/lookup_dropdown.dart';
import 'csv_parser.dart';
import 'data/import_repository.dart';
import 'statement_mapper.dart';

/// Import a bank statement exported as CSV. The file is read on the phone; only
/// the rows the user confirms are sent, and the file itself is never uploaded.
class ImportScreen extends ConsumerStatefulWidget {
  const ImportScreen({super.key});

  @override
  ConsumerState<ImportScreen> createState() => _ImportScreenState();
}

class _ImportScreenState extends ConsumerState<ImportScreen> {
  static const _maxFileBytes = 5 * 1024 * 1024;
  static const _chunkSize = 500; // the server accepts up to 1000 per request

  final _formKey = GlobalKey<FormState>();

  String? _fileName;
  List<List<String>> _table = const [];
  bool _hasHeader = true;
  ColumnMapping _mapping = const ColumnMapping();
  AmountMode _mode = AmountMode.single;
  DateOrder _dateOrder = DateOrder.monthFirst;
  bool _dateOrderDetected = false;
  bool _invertSign = false;
  ParseOutcome? _outcome;
  int _fileVersion = 0;

  String? _accountId;
  String? _categoryId;
  bool _busy = false;

  List<List<String>> get _data =>
      _hasHeader ? _table.skip(1).toList() : _table;

  int get _columnCount =>
      _table.fold<int>(0, (n, r) => math.max(n, r.length));

  List<String> get _header => [
    for (var i = 0; i < _columnCount; i++)
      (_hasHeader && i < _table.first.length && _table.first[i].trim().isNotEmpty)
          ? _table.first[i].trim()
          : 'Column ${i + 1}',
  ];

  ParseOutcome _compute() => buildRows(
    rows: _data,
    mapping: _mapping,
    mode: _mode,
    dateOrder: _dateOrder,
    invertSign: _invertSign,
  );

  /// Re-guesses columns and date order for the current file / header setting.
  void _reconfigure() {
    final guess = (_hasHeader && _table.isNotEmpty)
        ? guessMapping(_table.first)
        : (mapping: const ColumnMapping(), mode: AmountMode.single);

    _mapping = fillMissingFromContent(_data, guess.mapping);
    _mode = (_mapping.debit != null && _mapping.credit != null)
        ? AmountMode.debitCredit
        : AmountMode.single;

    final dateColumn = _mapping.date;
    final samples = <String>[
      if (dateColumn != null)
        for (final row in _data.take(300))
          if (dateColumn < row.length) row[dateColumn],
    ];
    final detected = detectDateOrder(samples);
    _dateOrderDetected = detected != null;
    _dateOrder = detected ?? DateOrder.monthFirst;
    _invertSign = false;
    _outcome = _compute();
  }

  void _update(VoidCallback change) {
    setState(() {
      change();
      _outcome = _compute();
    });
  }

  String _decode(Uint8List bytes) {
    try {
      return utf8.decode(bytes);
    } on FormatException {
      // Many bank exports are Windows-1252 / Latin-1.
      return latin1.decode(bytes);
    }
  }

  Future<void> _pick() async {
    final messenger = ScaffoldMessenger.of(context);

    const csv = XTypeGroup(
      label: 'CSV',
      extensions: ['csv', 'txt'],
      mimeTypes: [
        'text/csv',
        'text/comma-separated-values',
        'application/csv',
        'application/vnd.ms-excel',
        'text/plain',
      ],
    );

    final file = await openFile(acceptedTypeGroups: [csv]);
    if (file == null) return; // cancelled

    final bytes = await file.readAsBytes();
    if (bytes.length > _maxFileBytes) {
      messenger.showSnackBar(
        const SnackBar(content: Text('That file is larger than 5 MB.')),
      );
      return;
    }

    final table = parseCsv(_decode(bytes));
    if (table.length < 2) {
      messenger.showSnackBar(
        const SnackBar(content: Text('That file has no transactions in it.')),
      );
      return;
    }

    setState(() {
      _fileName = file.name;
      _table = table;
      _hasHeader = true;
      _fileVersion++;
      _reconfigure();
    });
  }

  Future<void> _import() async {
    final form = _formKey.currentState!;
    if (!form.validate()) return;
    form.save();

    final rows = _outcome?.rows ?? const <StatementRow>[];
    if (rows.isEmpty) return;

    setState(() => _busy = true);
    final messenger = ScaffoldMessenger.of(context);
    final repository = ref.read(importRepositoryProvider);

    try {
      var imported = 0;
      var duplicates = 0;
      for (var start = 0; start < rows.length; start += _chunkSize) {
        final end = math.min(start + _chunkSize, rows.length);
        final result = await repository.importTransactions(
          accountId: _accountId!,
          categoryId: _categoryId!,
          rows: rows.sublist(start, end),
        );
        imported += result.imported;
        duplicates += result.skippedDuplicates;
      }

      ref.read(dataRevisionProvider.notifier).bump();
      if (!mounted) return;

      final unreadable = _outcome?.skipped ?? 0;
      await showDialog<void>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Import finished'),
          content: Text(
            [
              'Imported $imported transaction${imported == 1 ? '' : 's'}.',
              if (duplicates > 0) '$duplicates already existed and were skipped.',
              if (unreadable > 0) "$unreadable line${unreadable == 1 ? '' : 's'} in the file could not be read and were ignored.",
              'You can recategorize them in the Transactions tab.',
            ].join('\n\n'),
          ),
          actions: [
            FilledButton(
              style: FilledButton.styleFrom(minimumSize: const Size(88, 40)),
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Done'),
            ),
          ],
        ),
      );
      if (mounted) context.pop();
    } on ApiException catch (e) {
      messenger.showSnackBar(SnackBar(content: Text(e.message)));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  DropdownButtonFormField<int?> _columnField(
      String label,
      int? value,
      void Function(int?) onChanged,
      ) {
    final header = _header;
    return DropdownButtonFormField<int?>(
      key: ValueKey('$label-$_fileVersion-$_hasHeader-$value'),
      initialValue: value,
      isExpanded: true,
      decoration: InputDecoration(labelText: label, border: const OutlineInputBorder()),
      items: [
        const DropdownMenuItem<int?>(value: null, child: Text('None')),
        for (var i = 0; i < header.length; i++)
          DropdownMenuItem<int?>(
            value: i,
            child: Text('${i + 1}: ${header[i]}', overflow: TextOverflow.ellipsis),
          ),
      ],
      onChanged: (v) => _update(() => onChanged(v)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final accounts = ref.watch(accountOptionsProvider);
    final categories = ref.watch(categoryOptionsProvider);
    final outcome = _outcome;
    final ready = outcome != null &&
        outcome.rows.isNotEmpty &&
        (accounts.value?.isNotEmpty ?? false) &&
        (categories.value?.isNotEmpty ?? false);

    return Scaffold(
      appBar: AppBar(title: const Text('Import statement')),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _buildFileCard(),
              if (_fileName != null) ...[
                const SizedBox(height: 16),
                _buildColumnsCard(),
                const SizedBox(height: 16),
                _buildPreviewCard(outcome),
                const SizedBox(height: 16),
                _buildSaveCard(accounts, categories, ready),
              ],
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFileCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _fileName ?? 'Bring in your bank statement',
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 6),
            Text(
              _fileName == null
                  ? 'Export a CSV from your bank\'s website or app, then choose it here. '
                  'The file is read on this phone: only the rows you confirm are sent '
                  'to your account, and your bank login is never involved.'
                  : '${_data.length} line${_data.length == 1 ? '' : 's'} found.',
              style: const TextStyle(color: AppColors.muted),
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: _busy ? null : _pick,
              icon: const Icon(Icons.upload_file),
              label: Text(_fileName == null ? 'Choose CSV file' : 'Choose another file'),
            ),
            if (_fileName != null)
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('First row is a header'),
                value: _hasHeader,
                onChanged: (v) => setState(() {
                  _hasHeader = v;
                  _fileVersion++;
                  _reconfigure();
                }),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildColumnsCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text('Match the columns', style: TextStyle(fontWeight: FontWeight.w700)),
            const SizedBox(height: 12),
            _columnField('Date', _mapping.date, (v) => _mapping = _mapping.copyWith(date: () => v)),
            const SizedBox(height: 12),
            _columnField(
              'Description',
              _mapping.description,
                  (v) => _mapping = _mapping.copyWith(description: () => v),
            ),
            const SizedBox(height: 12),
            SegmentedButton<AmountMode>(
              segments: const [
                ButtonSegment(value: AmountMode.single, label: Text('One amount')),
                ButtonSegment(value: AmountMode.debitCredit, label: Text('Debit / credit')),
              ],
              selected: {_mode},
              onSelectionChanged: (s) => _update(() => _mode = s.first),
            ),
            const SizedBox(height: 12),
            if (_mode == AmountMode.single)
              _columnField('Amount', _mapping.amount, (v) => _mapping = _mapping.copyWith(amount: () => v))
            else ...[
              _columnField(
                'Debit (money out)',
                _mapping.debit,
                    (v) => _mapping = _mapping.copyWith(debit: () => v),
              ),
              const SizedBox(height: 12),
              _columnField(
                'Credit (money in)',
                _mapping.credit,
                    (v) => _mapping = _mapping.copyWith(credit: () => v),
              ),
            ],
            const SizedBox(height: 12),
            _columnField(
              'Notes (optional)',
              _mapping.notes,
                  (v) => _mapping = _mapping.copyWith(notes: () => v),
            ),
            const SizedBox(height: 16),
            const Text('Dates look like 03/04/2026 ...', style: TextStyle(color: AppColors.muted)),
            const SizedBox(height: 8),
            SegmentedButton<DateOrder>(
              segments: const [
                ButtonSegment(value: DateOrder.monthFirst, label: Text('Month first')),
                ButtonSegment(value: DateOrder.dayFirst, label: Text('Day first')),
              ],
              selected: {_dateOrder},
              onSelectionChanged: (s) => _update(() => _dateOrder = s.first),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Text(
                _dateOrderDetected
                    ? 'Worked out from your file.'
                    : "Can't tell from this file: check the dates in the preview.",
                style: const TextStyle(color: AppColors.muted, fontSize: 12),
              ),
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Flip signs'),
              subtitle: const Text('Turn on if spending shows as positive in this file.'),
              value: _invertSign,
              onChanged: (v) => _update(() => _invertSign = v),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPreviewCard(ParseOutcome? outcome) {
    final rows = outcome?.rows ?? const <StatementRow>[];

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Preview', style: TextStyle(fontWeight: FontWeight.w700)),
            const SizedBox(height: 4),
            Text(
              '${rows.length} ready to import'
                  '${(outcome?.skipped ?? 0) > 0 ? ', ${outcome!.skipped} line(s) ignored (no date or amount)' : ''}. '
                  'Green is money in, black is money out.',
              style: const TextStyle(color: AppColors.muted, fontSize: 12),
            ),
            const SizedBox(height: 8),
            if (rows.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 12),
                child: Text('Nothing readable yet: pick the Date and Amount columns above.'),
              )
            else
              for (final r in rows.take(5))
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  dense: true,
                  title: Text(r.payee, maxLines: 1, overflow: TextOverflow.ellipsis),
                  subtitle: Text(formatDate(r.date)),
                  trailing: Text(
                    formatMoney(r.amount, Env.currencyCode),
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      color: r.amount > 0 ? AppColors.income : AppColors.ink,
                    ),
                  ),
                ),
          ],
        ),
      ),
    );
  }

  Widget _buildSaveCard(
      AsyncValue<List<NamedItem>> accounts,
      AsyncValue<List<NamedItem>> categories,
      bool ready,
      ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text('Save into', style: TextStyle(fontWeight: FontWeight.w700)),
            const SizedBox(height: 12),
            LookupDropdown(
              label: 'Account',
              items: accounts,
              emptyHint: 'Add an account to continue',
              onEmptyTap: () => context.push<void>('/accounts'),
              onCreate: ref.createAccountNamed,
              onSaved: (id) => _accountId = id,
            ),
            const SizedBox(height: 12),
            LookupDropdown(
              label: 'Category for all rows',
              items: categories,
              emptyHint: 'Add a category to continue',
              onEmptyTap: () => context.push<void>('/categories'),
              onCreate: ref.createCategoryNamed,
              noun: 'category',
              onSaved: (id) => _categoryId = id,
            ),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: (_busy || !ready) ? null : _import,
              child: _busy
                  ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
              )
                  : Text('Import ${_outcome?.rows.length ?? 0} transactions'),
            ),
          ],
        ),
      ),
    );
  }
}
