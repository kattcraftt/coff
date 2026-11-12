import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/data/app_transaction.dart';
import '../../../core/data/shared_data.dart';

class TransactionFilter {
  const TransactionFilter({
    this.query = '',
    this.accountId,
    this.categoryId,
    this.range,
  });

  final String query;
  final String? accountId;
  final String? categoryId;
  final DateTimeRange? range;

  bool get isActive =>
      query.isNotEmpty || accountId != null || categoryId != null || range != null;
}

class TransactionFilterNotifier extends Notifier<TransactionFilter> {
  @override
  TransactionFilter build() => const TransactionFilter();

  void setQuery(String query) => state = TransactionFilter(
    query: query,
    accountId: state.accountId,
    categoryId: state.categoryId,
    range: state.range,
  );

  void setAccount(String? id) => state = TransactionFilter(
    query: state.query,
    accountId: id,
    categoryId: state.categoryId,
    range: state.range,
  );

  void setCategory(String? id) => state = TransactionFilter(
    query: state.query,
    accountId: state.accountId,
    categoryId: id,
    range: state.range,
  );

  void setRange(DateTimeRange? range) => state = TransactionFilter(
    query: state.query,
    accountId: state.accountId,
    categoryId: state.categoryId,
    range: range,
  );

  void clear() => state = const TransactionFilter();
}

final transactionFilterProvider =
NotifierProvider<TransactionFilterNotifier, TransactionFilter>(
  TransactionFilterNotifier.new,
);

/// Newest first, with the search / account / category / period filters applied.
final filteredTransactionsProvider =
Provider.autoDispose<AsyncValue<List<AppTransaction>>>((ref) {
  final filter = ref.watch(transactionFilterProvider);

  return ref.watch(transactionsProvider).whenData((all) {
    final query = filter.query.trim().toLowerCase();

    final result = all.where((t) {
      if (filter.accountId != null && t.accountId != filter.accountId) return false;
      if (filter.categoryId != null && t.categoryId != filter.categoryId) return false;
      final range = filter.range;
      if (range != null && (t.date.isBefore(range.start) || t.date.isAfter(range.end))) {
        return false;
      }
      if (query.isNotEmpty) {
        final text = '${t.payee} ${t.notes ?? ''}'.toLowerCase();
        if (!text.contains(query)) return false;
      }
      return true;
    }).toList()
      ..sort((a, b) => b.date.compareTo(a.date));

    return result;
  });
});
