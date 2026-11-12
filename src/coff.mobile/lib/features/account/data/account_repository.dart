import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_client.dart';
import '../../../core/network/api_exception.dart';

class AccountRepository {
  const AccountRepository(this._dio);

  final Dio _dio;

  /// `PUT users/me`. First and last name are required by the server; the rest is optional.
  Future<void> updateProfile({
    required String firstName,
    required String lastName,
    String? middleName,
    String? phoneNumber,
  }) {
    return guardApi(() async {
      await _dio.put<dynamic>(
        'users/me',
        data: {
          'firstName': firstName,
          'middleName': middleName,
          'lastName': lastName,
          'phoneNumber': phoneNumber,
        },
      );
    });
  }

  /// `POST users/me/change-password`.
  Future<void> changePassword({
    required String oldPassword,
    required String newPassword,
  }) {
    return guardApi(() async {
      await _dio.post<dynamic>(
        'users/me/change-password',
        data: {'oldPassword': oldPassword, 'newPassword': newPassword},
      );
    });
  }

  /// `POST users/me/profile-image` (multipart, field name `file`).
  Future<void> uploadPhoto(String imagePath) {
    return guardApi(() async {
      final form = FormData.fromMap({
        'file': await MultipartFile.fromFile(
          imagePath,
          filename: imagePath.split('/').last,
        ),
      });
      await _dio.post<dynamic>('users/me/profile-image', data: form);
    });
  }
}

final accountRepositoryProvider = Provider<AccountRepository>(
  (ref) => AccountRepository(ref.watch(dioProvider)),
);
