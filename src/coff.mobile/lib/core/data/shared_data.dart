import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../network/api_client.dart';
import '../network/api_exception.dart';
import 'app_transaction.dart';
import 'data_revision.dart';
import 'named_item.dart';

/// Read access to the data every feature needs: accounts, categories and
/// transactions. Each feature owns its own writes.
class SharedDataRepository {
  const SharedDataRepository(this._dio);

  final Dio _dio;

  Future<List<NamedItem>> accounts() => _list('accounts', NamedItem.fromJson);
  Future<List<NamedItem>> categories() => _list('categories', NamedItem.fromJson);
  Future<List<AppTransaction>> transactions() =>
      _list('transactions', AppTransaction.fromJson);

  /// Both create endpoints answer with the new id as a JSON string.
  Future<String> createAccount(String name) => _create('accounts', name);
  Future<String> createCategory(String name) => _create('categories', name);

  Future<String> _create(String path, String name) {
    return guardApi(() async {
      final response = await _dio.post<dynamic>(path, data: {'name': name});
      final data = response.data;
      if (data is! String || data.isEmpty) {
        throw const ApiException('Unexpected response from the server.');
      }
      return data.startsWith('"') && data.endsWith('"') && data.length > 1
          ? data.substring(1, data.length - 1)
          : data;
    });
  }

  Future<List<T>> _list<T>(
      String path,
      T Function(Map<String, dynamic>) parse,
      ) {
    return guardApi(() async {
      final response = await _dio.get<List<dynamic>>(path);
      return (response.data ?? []).cast<Map<String, dynamic>>().map(parse).toList();
    });
  }
}

final sharedDataRepositoryProvider = Provider<SharedDataRepository>(
      (ref) => SharedDataRepository(ref.watch(dioProvider)),
);

final accountOptionsProvider = FutureProvider.autoDispose<List<NamedItem>>((ref) {
  ref.watch(dataRevisionProvider);
  return ref.watch(sharedDataRepositoryProvider).accounts();
});

final categoryOptionsProvider = FutureProvider.autoDispose<List<NamedItem>>((ref) {
  ref.watch(dataRevisionProvider);
  return ref.watch(sharedDataRepositoryProvider).categories();
});

final transactionsProvider =
FutureProvider.autoDispose<List<AppTransaction>>((ref) {
  ref.watch(dataRevisionProvider);
  return ref.watch(sharedDataRepositoryProvider).transactions();
});

/// Lets any screen create an account / category and refresh every list.
extension CreateLookups on WidgetRef {
  Future<String?> createAccountNamed(String name) async {
    final id = await read(sharedDataRepositoryProvider).createAccount(name);
    read(dataRevisionProvider.notifier).bump();
    return id;
  }

  Future<String?> createCategoryNamed(String name) async {
    final id = await read(sharedDataRepositoryProvider).createCategory(name);
    read(dataRevisionProvider.notifier).bump();
    return id;
  }
}
