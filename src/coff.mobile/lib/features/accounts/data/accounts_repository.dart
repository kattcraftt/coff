import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_client.dart';
import '../../../core/network/api_exception.dart';

class AccountsRepository {
  const AccountsRepository(this._dio);

  final Dio _dio;

  Future<void> create(String name) {
    return guardApi(() async {
      await _dio.post<dynamic>('accounts', data: {'name': name});
    });
  }

  Future<void> rename(String id, String name) {
    return guardApi(() async {
      await _dio.put<dynamic>('accounts/$id', data: {'name': name});
    });
  }
}

final accountsRepositoryProvider = Provider<AccountsRepository>(
      (ref) => AccountsRepository(ref.watch(dioProvider)),
);
