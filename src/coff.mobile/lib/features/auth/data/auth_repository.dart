import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_client.dart';
import '../../../core/network/api_exception.dart';

class AuthRepository {
  const AuthRepository(this._dio);

  final Dio _dio;

  /// `POST users/login` currently returns the bare token string.
  Future<String> login({required String email, required String password}) {
    return guardApi(() async {
      final response = await _dio.post<dynamic>(
        'users/login',
        data: {'email': email, 'password': password},
      );

      final data = response.data;
      if (data is! String || data.isEmpty) {
        throw const ApiException('Unexpected response from the server.');
      }
      // Be tolerant if the string arrives still JSON-quoted.
      return data.startsWith('"') && data.endsWith('"') && data.length > 1
          ? data.substring(1, data.length - 1)
          : data;
    });
  }

  /// `POST users/register` takes { email, password, confirmPassword }.
  Future<void> register({
    required String email,
    required String password,
    required String confirmPassword,
  }) {
    return guardApi(() async {
      await _dio.post<dynamic>(
        'users/register',
        data: {
          'email': email,
          'password': password,
          'confirmPassword': confirmPassword,
        },
      );
    });
  }
}

final authRepositoryProvider =
Provider<AuthRepository>((ref) => AuthRepository(ref.watch(dioProvider)));
