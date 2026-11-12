import 'dart:math';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../auth/session_controller.dart';
import '../config/env.dart';
import '../storage/token_storage.dart';

final _random = Random.secure();

/// Sent as `Correlation-Id`, so a request from the app can be found in the
/// backend logs (RequestContextLoggingMiddleware puts it on every log line).
String _newCorrelationId() {
  final bytes = List<int>.generate(16, (_) => _random.nextInt(256));
  return bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
}

final dioProvider = Provider<Dio>((ref) {
  final dio = Dio(
    BaseOptions(
      baseUrl: Env.apiBaseUrl,
      connectTimeout: const Duration(seconds: 15),
      // Scanning uploads an image and waits for the AI, so allow longer.
      receiveTimeout: const Duration(seconds: 60),
      sendTimeout: const Duration(seconds: 60),
      headers: {'Accept': 'application/json'},
    ),
  );

  dio.interceptors.add(
    InterceptorsWrapper(
      onRequest: (options, handler) async {
        options.headers['Correlation-Id'] = _newCorrelationId();
        final token = await ref.read(tokenStorageProvider).read();
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        handler.next(options);
      },
      onError: (error, handler) async {
        final isLogin = error.requestOptions.path == 'users/login';
        if (error.response?.statusCode == 401 && !isLogin) {
          // Token expired or revoked: drop it; the router sends us to /login.
          await ref.read(sessionProvider.notifier).signOut();
        }
        handler.next(error);
      },
    ),
  );

  return dio;
});
