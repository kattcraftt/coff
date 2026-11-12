import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/data/data_revision.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/api_exception.dart';
import 'receipt.dart';

class ReceiptsRepository {
  const ReceiptsRepository(this._dio);

  final Dio _dio;

  /// Uploads the photo; the backend stores it, reads it with AI and returns a
  /// *pending* receipt for the user to review.
  Future<Receipt> scan(String imagePath) {
    return guardApi(() async {
      final form = FormData.fromMap({
        'file': await MultipartFile.fromFile(
          imagePath,
          filename: imagePath.split('/').last,
        ),
      });
      final response =
      await _dio.post<Map<String, dynamic>>('receipts/scan', data: form);
      return Receipt.fromJson(response.data!);
    });
  }

  Future<List<Receipt>> list() {
    return guardApi(() async {
      final response = await _dio.get<List<dynamic>>('receipts');
      return (response.data ?? [])
          .cast<Map<String, dynamic>>()
          .map(Receipt.fromJson)
          .toList();
    });
  }

  /// The stored photo. The endpoint needs the bearer token, so it is fetched
  /// through dio instead of Image.network.
  Future<Uint8List> image(String receiptId) {
    return guardApi(() async {
      final response = await _dio.get<List<int>>(
        'receipts/$receiptId/image',
        options: Options(responseType: ResponseType.bytes),
      );
      return Uint8List.fromList(response.data!);
    });
  }

  /// Removes the receipt and its photo. A transaction made from it is kept.
  Future<void> delete(String receiptId) {
    return guardApi(() async {
      await _dio.delete<dynamic>('receipts/$receiptId');
    });
  }

  /// Turns a pending receipt into a transaction with the user's edits.
  /// The backend stores receipts as expenses (negative), so send the plain total.
  Future<void> confirm({
    required String receiptId,
    required String accountId,
    required String categoryId,
    required double amount,
    required String payee,
    required DateTime date,
    String? notes,
  }) {
    return guardApi(() async {
      await _dio.post<dynamic>(
        'receipts/$receiptId/confirm',
        data: {
          'accountId': accountId,
          'categoryId': categoryId,
          'amount': amount,
          'payee': payee,
          'notes': notes,
          // Calendar date -> UTC midnight, so it round-trips without day shifts.
          'date': DateTime.utc(date.year, date.month, date.day).toIso8601String(),
        },
      );
    });
  }
}

final receiptsRepositoryProvider = Provider<ReceiptsRepository>(
      (ref) => ReceiptsRepository(ref.watch(dioProvider)),
);

final receiptImageProvider =
FutureProvider.autoDispose.family<Uint8List, String>(
      (ref, receiptId) => ref.watch(receiptsRepositoryProvider).image(receiptId),
);

final receiptListProvider = FutureProvider.autoDispose<List<Receipt>>((ref) {
  ref.watch(dataRevisionProvider);
  return ref.watch(receiptsRepositoryProvider).list();
});
