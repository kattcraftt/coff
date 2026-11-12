import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/data_revision.dart';
import '../network/api_client.dart';
import 'session_controller.dart';

/// The user's profile photo, or null when none was uploaded (the API answers 404 then).
final profileImageProvider = FutureProvider.autoDispose<Uint8List?>((ref) async {
  final signedIn = ref.watch(sessionProvider).value ?? false;
  if (!signedIn) return null;
  ref.watch(dataRevisionProvider); // refetch after a new photo is uploaded

  try {
    final response = await ref.watch(dioProvider).get<List<int>>(
          'users/me/display-profile-image',
          options: Options(responseType: ResponseType.bytes),
        );
    final data = response.data;
    return data == null || data.isEmpty ? null : Uint8List.fromList(data);
  } on DioException {
    return null;
  }
});
