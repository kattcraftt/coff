import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/data/data_revision.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/api_exception.dart';
import 'overview.dart';

class OverviewFilter {
  const OverviewFilter({required this.range, this.accountId});

  final DateTimeRange range;

  /// null = all accounts.
  final String? accountId;
}

class OverviewFilterNotifier extends Notifier<OverviewFilter> {
  @override
  OverviewFilter build() {
    final now = DateTime.now();
    final end = DateTime(now.year, now.month, now.day);
    final start = DateTime(end.year, end.month, end.day - 29);
    return OverviewFilter(range: DateTimeRange(start: start, end: end));
  }

  void setRange(DateTimeRange range) =>
      state = OverviewFilter(range: range, accountId: state.accountId);

  void setAccount(String? accountId) =>
      state = OverviewFilter(range: state.range, accountId: accountId);
}

final overviewFilterProvider =
NotifierProvider<OverviewFilterNotifier, OverviewFilter>(
  OverviewFilterNotifier.new,
);

class OverviewRepository {
  const OverviewRepository(this._dio);

  final Dio _dio;

  static final _day = DateFormat('yyyy-MM-dd');

  Future<Overview> fetch(OverviewFilter filter) {
    return guardApi(() async {
      final response = await _dio.get<Map<String, dynamic>>(
        'analytics/overview',
        queryParameters: {
          'from': _day.format(filter.range.start),
          'to': _day.format(filter.range.end),
          if (filter.accountId != null) 'accountId': filter.accountId,
        },
      );
      return Overview.fromJson(response.data!);
    });
  }
}

final overviewRepositoryProvider = Provider<OverviewRepository>(
      (ref) => OverviewRepository(ref.watch(dioProvider)),
);

final overviewProvider = FutureProvider.autoDispose<Overview>((ref) {
  ref.watch(dataRevisionProvider);
  final filter = ref.watch(overviewFilterProvider);
  return ref.watch(overviewRepositoryProvider).fetch(filter);
});
