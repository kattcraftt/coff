import 'package:dio/dio.dart';

/// A user-presentable error. Mirrors the backend's RFC 7807 problem details
/// (CustomResults.Problem) so messages from the API reach the UI unchanged.
class ApiException implements Exception {
  const ApiException(this.message, {this.statusCode});

  final String message;
  final int? statusCode;

  factory ApiException.fromDio(DioException e) {
    final status = e.response?.statusCode;
    final data = e.response?.data;

    if (data is Map) {
      final validation = _firstValidationMessage(data['errors']);
      if (validation != null) return ApiException(validation, statusCode: status);

      final detail = data['detail'] ?? data['title'];
      if (detail is String && detail.isNotEmpty) {
        return ApiException(detail, statusCode: status);
      }
    }

    return switch (e.type) {
      DioExceptionType.connectionTimeout ||
      DioExceptionType.sendTimeout ||
      DioExceptionType.receiveTimeout =>
      const ApiException('The server took too long to respond.'),
      DioExceptionType.connectionError =>
      const ApiException("Can't reach the server. Check your connection."),
      _ => ApiException('Something went wrong.', statusCode: status),
    };
  }

  static String? _firstValidationMessage(Object? errors) {
    if (errors is List && errors.isNotEmpty) {
      final first = errors.first;
      if (first is String) return first;
      if (first is Map) {
        final text = first['description'] ?? first['message'];
        if (text is String) return text;
      }
    }
    if (errors is Map && errors.isNotEmpty) {
      final first = errors.values.first;
      if (first is List && first.isNotEmpty) return first.first.toString();
    }
    return null;
  }

  @override
  String toString() => message;
}

/// Runs a Dio call and converts transport errors into [ApiException].
Future<T> guardApi<T>(Future<T> Function() run) async {
  try {
    return await run();
  } on DioException catch (e) {
    throw ApiException.fromDio(e);
  }
}
