import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../core/config/env.dart';
import '../../core/data/app_transaction.dart';
import '../../core/data/data_revision.dart';
import '../../core/data/named_item.dart';
import '../../core/data/shared_data.dart';
import '../../core/network/api_exception.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/formatters.dart';
import '../../core/widgets/period_picker.dart';
import 'data/transaction_filter.dart';
import 'data/transactions_repository.dart';

class TransactionsScreen extends ConsumerStatefulWidget {
  const TransactionsScreen({super.key});

  @override
  ConsumerState<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends ConsumerState<TransactionsScreen> {
  final _search = TextEditingController();

  /// Ids ticked for bulk actions. Long-press a row to start selecting.
  final Set<String> _selected = {};

  bool get _selecting => _selected.isNotEmpty;

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  void _toggle(String id) {
    setState(() {
      if (!_selected.remove(id)) _selected.add(id);
    });
  }

  void _selectAllVisible() {
    final visible = ref.read(filteredTransactionsProvider).value ?? const <AppTransaction>[];
    setState(() {
      _selected
        ..clear()
        ..addAll(visible.map((t) => t.id));
    });
  }

  Future<void> _deleteSelected() async {
    final count = _selected.length;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete $count transaction${count == 1 ? '' : 's'}?'),
        content: const Text('This cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.of(context).pop(true), child: const Text('Delete')),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    final messenger = ScaffoldMessenger.of(context);
    try {
      final deleted = await ref.read(transactionsRepositoryProvider).deleteMany(_selected.toList());
      ref.read(dataRevisionProvider.notifier).bump();
      if (mounted) setState(_selected.clear);
      messenger.showSnackBar(SnackBar(content: Text('Deleted $deleted')));
    } on ApiException catch (e) {
      messenger.showSnackBar(SnackBar(content: Text(e.message)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final filter = ref.watch(transactionFilterProvider);
    final notifier = ref.read(transactionFilterProvider.notifier);
    final transactions = ref.watch(filteredTransactionsProvider);
    final accounts = ref.watch(accountOptionsProvider).value ?? const <NamedItem>[];
    final categories = ref.watch(categoryOptionsProvider).value ?? const <NamedItem>[];

    final accountNames = {for (final a in accounts) a.id: a.name};
    final categoryNames = {for (final c in categories) c.id: c.name};

    return Scaffold(
      appBar: _selecting
          ? AppBar(
        leading: IconButton(
          tooltip: 'Cancel selection',
          icon: const Icon(Icons.close),
          onPressed: () => setState(_selected.clear),
        ),
        title: Text('${_selected.length} selected'),
        actions: [
          IconButton(
            tooltip: 'Select all',
            icon: const Icon(Icons.select_all),
            onPressed: _selectAllVisible,
          ),
          IconButton(
            tooltip: 'Delete',
            icon: const Icon(Icons.delete_outline),
            onPressed: _deleteSelected,
          ),
        ],
      )
          : AppBar(
        title: const Text('Transactions'),
        actions: [
          IconButton(
            tooltip: 'Import a statement',
            icon: const Icon(Icons.upload_file),
            onPressed: () => context.push('/import'),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: TextField(
              controller: _search,
              onChanged: notifier.setQuery,
              decoration: InputDecoration(
                hintText: 'Search payee or notes',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 4),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _PickerChip(
                  label: accountNames[filter.accountId] ?? 'All accounts',
                  active: filter.accountId != null,
                  options: accounts,
                  allLabel: 'All accounts',
                  onSelected: notifier.setAccount,
                ),
                _PickerChip(
                  label: categoryNames[filter.categoryId] ?? 'All categories',
                  active: filter.categoryId != null,
                  options: categories,
                  allLabel: 'All categories',
                  onSelected: notifier.setCategory,
                ),
                ActionChip(
                  avatar: const Icon(Icons.date_range, size: 18),
                  label: Text(
                    filter.range == null
                        ? 'Any date'
                        : '${DateFormat('MMM d').format(filter.range!.start)} - '
                        '${DateFormat('MMM d, yyyy').format(filter.range!.end)}',
                  ),
                  backgroundColor: filter.range == null ? null : AppColors.mint,
                  onPressed: () async {
                    final picked = await pickPeriod(context, current: filter.range);
                    if (picked != null) notifier.setRange(picked);
                  },
                ),
                if (filter.isActive)
                  ActionChip(
                    avatar: const Icon(Icons.close, size: 18),
                    label: const Text('Clear'),
                    onPressed: () {
                      _search.clear();
                      notifier.clear();
                    },
                  ),
              ],
            ),
          ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: () => ref.refresh(transactionsProvider.future),
              child: transactions.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, _) => ListView(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(24),
                      child: Text('$error', textAlign: TextAlign.center),
                    ),
                  ],
                ),
                data: (items) => _TransactionList(
                  items: items,
                  accountNames: accountNames,
                  categoryNames: categoryNames,
                  filtered: filter.isActive,
                  selected: _selected,
                  onToggle: _toggle,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TransactionList extends StatelessWidget {
  const _TransactionList({
    required this.items,
    required this.accountNames,
    required this.categoryNames,
    required this.filtered,
    required this.selected,
    required this.onToggle,
  });

  final List<AppTransaction> items;
  final Map<String, String> accountNames;
  final Map<String, String> categoryNames;
  final bool filtered;
  final Set<String> selected;
  final void Function(String id) onToggle;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return ListView(
        children: [
          Padding(
            padding: const EdgeInsets.all(48),
            child: Text(
              filtered
                  ? 'Nothing matches these filters.'
                  : 'No transactions yet.\nTap "Add" to scan a receipt or enter one by hand.',
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.muted),
            ),
          ),
        ],
      );
    }

    // Net total per day, for the headers.
    final dayTotals = <DateTime, double>{};
    for (final t in items) {
      dayTotals.update(t.date, (v) => v + t.amount, ifAbsent: () => t.amount);
    }

    final selecting = selected.isNotEmpty;
    final children = <Widget>[];
    DateTime? lastDay;
    for (final t in items) {
      if (lastDay != t.date) {
        lastDay = t.date;
        children.add(_DayHeader(date: t.date, total: dayTotals[t.date]!));
      }
      children.add(
        _TransactionTile(
          transaction: t,
          subtitle: [
            categoryNames[t.categoryId],
            accountNames[t.accountId],
          ].whereType<String>().join(' • '),
          selecting: selecting,
          selected: selected.contains(t.id),
          onTap: () => selecting ? onToggle(t.id) : context.push('/transaction', extra: t),
          onLongPress: () => onToggle(t.id),
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 96),
      children: children,
    );
  }
}

class _DayHeader extends StatelessWidget {
  const _DayHeader({required this.date, required this.total});

  final DateTime date;
  final double total;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 14, 4, 6),
      child: Row(
        children: [
          Expanded(
            child: Text(
              DateFormat('EEEE, MMM d').format(date),
              style: const TextStyle(color: AppColors.muted, fontWeight: FontWeight.w600),
            ),
          ),
          Text(
            formatMoney(total, Env.currencyCode),
            style: const TextStyle(color: AppColors.muted, fontSize: 12),
          ),
        ],
      ),
    );
  }
}

class _TransactionTile extends StatelessWidget {
  const _TransactionTile({
    required this.transaction,
    required this.subtitle,
    required this.selecting,
    required this.selected,
    required this.onTap,
    required this.onLongPress,
  });

  final AppTransaction transaction;
  final String subtitle;
  final bool selecting;
  final bool selected;
  final VoidCallback onTap;
  final VoidCallback onLongPress;

  @override
  Widget build(BuildContext context) {
    final t = transaction;
    final initial = t.payee.isEmpty ? '?' : t.payee[0].toUpperCase();

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Card(
        color: selected ? AppColors.mint : null,
        child: ListTile(
          onTap: onTap,
          onLongPress: onLongPress,
          leading: selecting
              ? Checkbox(value: selected, onChanged: (_) => onTap())
              : CircleAvatar(
            backgroundColor: t.isExpense ? AppColors.expenseBg : AppColors.incomeBg,
            child: Text(
              initial,
              style: TextStyle(
                color: t.isExpense ? AppColors.expense : AppColors.income,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          title: Text(
            t.payee,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          subtitle: subtitle.isEmpty ? null : Text(subtitle, maxLines: 1),
          trailing: Text(
            formatMoney(t.amount, Env.currencyCode),
            style: TextStyle(
              fontWeight: FontWeight.w700,
              color: t.isExpense ? AppColors.ink : AppColors.income,
            ),
          ),
        ),
      ),
    );
  }
}

class _PickerChip extends StatelessWidget {
  const _PickerChip({
    required this.label,
    required this.active,
    required this.options,
    required this.allLabel,
    required this.onSelected,
  });

  final String label;
  final bool active;
  final List<NamedItem> options;
  final String allLabel;
  final void Function(String? id) onSelected;

  static const _all = '__all__';

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      onSelected: (id) => onSelected(id == _all ? null : id),
      itemBuilder: (context) => [
        PopupMenuItem(value: _all, child: Text(allLabel)),
        for (final o in options) PopupMenuItem(value: o.id, child: Text(o.name)),
      ],
      child: Chip(
        label: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(label),
            const SizedBox(width: 4),
            const Icon(Icons.expand_more, size: 18),
          ],
        ),
        backgroundColor: active ? AppColors.mint : null,
      ),
    );
  }
}
