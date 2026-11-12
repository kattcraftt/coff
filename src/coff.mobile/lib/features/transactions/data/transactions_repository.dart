import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_client.dart';
import '../../../core/network/api_exception.dart';

/// Writes only; reading the list is shared (core/data/shared_data.dart).
class TransactionsRepository {
  const TransactionsRepository(this._dio);

  final Dio _dio;

  Map<String, dynamic> _body({
    required String accountId,
    required String categoryId,
    required double amount,
    required String payee,
    required DateTime date,
    String? notes,
  }) =>
      {
        'accountId': accountId,
        'categoryId': categoryId,
        'amount': amount,
        'payee': payee,
        'notes': notes,
        // Calendar date -> UTC midnight, so it round-trips without day shifts.
        'date': DateTime.utc(date.year, date.month, date.day).toIso8601String(),
      };

  Future<void> create({
    required String accountId,
    required String categoryId,
    required double amount,
    required String payee,
    required DateTime date,
    String? notes,
  }) {
    return guardApi(() async {
      await _dio.post<dynamic>(
        'transactions',
        data: _body(
          accountId: accountId,
          categoryId: categoryId,
          amount: amount,
          payee: payee,
          date: date,
          notes: notes,
        ),
      );
    });
  }

  /// ASSUMPTION: `PUT transactions/{id}` accepts the same body as create.
  Future<void> update({
    required String id,
    required String accountId,
    required String categoryId,
    required double amount,
    required String payee,
    required DateTime date,
    String? notes,
  }) {
    return guardApi(() async {
      await _dio.put<dynamic>(
        'transactions/$id',
        data: _body(
          accountId: accountId,
          categoryId: categoryId,
          amount: amount,
          payee: payee,
          date: date,
          notes: notes,
        ),
      );
    });
  }

  /// `POST transactions/bulk-delete`: removes the user's own transactions among [ids] in one go.
  Future<int> deleteMany(List<String> ids) {
    return guardApi(() async {
      final response = await _dio.post<Map<String, dynamic>>(
        'transactions/bulk-delete',
        data: {'ids': ids},
      );
      return (response.data?['deleted'] as num?)?.toInt() ?? 0;
    });
  }

  /// `DELETE transactions/{id}`.
  Future<void> delete(String id) {
    return guardApi(() async {
      await _dio.delete<dynamic>('transactions/$id');
    });
  }
}

final transactionsRepositoryProvider = Provider<TransactionsRepository>(
      (ref) => TransactionsRepository(ref.watch(dioProvider)),
);
