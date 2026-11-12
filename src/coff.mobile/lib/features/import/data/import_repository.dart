import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_client.dart';
import '../../../core/network/api_exception.dart';
import '../statement_mapper.dart';

class ImportResult {
  const ImportResult({required this.imported, required this.skippedDuplicates});

  final int imported;
  final int skippedDuplicates;
}

class ImportRepository {
  const ImportRepository(this._dio);

  final Dio _dio;

  /// `POST transactions/import`: one atomic request per call (max 1000 rows).
  /// The server skips rows that already exist (same account, day, amount, payee).
  Future<ImportResult> importTransactions({
    required String accountId,
    required String categoryId,
    required List<StatementRow> rows,
  }) {
    return guardApi(() async {
      final response = await _dio.post<Map<String, dynamic>>(
        'transactions/import',
        data: {
          'accountId': accountId,
          'categoryId': categoryId,
          'items': [
            for (final r in rows)
              {
                // Calendar date -> UTC midnight, so it never shifts a day.
                'date': DateTime.utc(r.date.year, r.date.month, r.date.day).toIso8601String(),
                'payee': r.payee,
                'amount': r.amount,
                'notes': r.notes,
              },
          ],
        },
      );
      final data = response.data!;
      return ImportResult(
        imported: (data['imported'] as num).toInt(),
        skippedDuplicates: (data['skippedDuplicates'] as num).toInt(),
      );
    });
  }
}

final importRepositoryProvider = Provider<ImportRepository>(
      (ref) => ImportRepository(ref.watch(dioProvider)),
);
