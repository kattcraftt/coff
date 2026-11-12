import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_client.dart';
import '../../../core/network/api_exception.dart';

class CategoriesRepository {
  const CategoriesRepository(this._dio);

  final Dio _dio;

  Future<void> create(String name) {
    return guardApi(() async {
      await _dio.post<dynamic>('categories', data: {'name': name});
    });
  }

  /// ASSUMPTION: `PUT categories/{id}` { name }, mirroring accounts.
  Future<void> rename(String id, String name) {
    return guardApi(() async {
      await _dio.put<dynamic>('categories/$id', data: {'name': name});
    });
  }
}

final categoriesRepositoryProvider = Provider<CategoriesRepository>(
      (ref) => CategoriesRepository(ref.watch(dioProvider)),
);
