import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/data_revision.dart';
import '../network/api_client.dart';
import '../storage/token_storage.dart';
import 'session_controller.dart';

class CurrentUser {
  const CurrentUser({
    this.email,
    this.fullName,
    this.firstName,
    this.middleName,
    this.lastName,
    this.phoneNumber,
  });

  final String? email;
  final String? fullName;
  final String? firstName;
  final String? middleName;
  final String? lastName;
  final String? phoneNumber;

  /// The FIRST name only, or null when the user has not set one yet.
  String? get greetingName {
    final first = firstName?.trim();
    return (first == null || first.isEmpty) ? null : first;
  }

  /// Full name when known, otherwise something readable from the email.
  String get displayName {
    final full = fullName?.trim();
    if (full != null && full.isNotEmpty) return full;
    return greetingName ?? _nameFromEmail(email) ?? 'Account';
  }

  String get initial {
    final source = greetingName ?? displayName;
    return source.isEmpty ? '?' : source[0].toUpperCase();
  }
}

/// Profile from `GET users/me`. If that call is refused or fails, falls back to what the
/// sign-in token says (email only), so the UI always has something to show.
final currentUserProvider = FutureProvider<CurrentUser?>((ref) async {
  final signedIn = ref.watch(sessionProvider).value ?? false;
  if (!signedIn) return null;
  ref.watch(dataRevisionProvider); // refetch after the profile is edited

  final token = await ref.watch(tokenStorageProvider).read();
  final fromToken = token == null ? null : _fromToken(token);

  try {
    final response =
    await ref.watch(dioProvider).get<Map<String, dynamic>>('users/me');
    final data = response.data;
    if (data == null) return fromToken;

    String? text(String key) {
      final value = data[key];
      return value is String ? value : null;
    }

    return CurrentUser(
      email: text('email') ?? fromToken?.email,
      fullName: text('fullName'),
      firstName: text('firstName'),
      middleName: text('middleName'),
      lastName: text('lastName'),
      phoneNumber: text('phoneNumber'),
    );
  } on DioException {
    return fromToken;
  }
});

CurrentUser? _fromToken(String token) {
  final parts = token.split('.');
  if (parts.length < 2) return null;

  try {
    final json = utf8.decode(base64Url.decode(base64Url.normalize(parts[1])));
    final claims = jsonDecode(json);
    if (claims is! Map<String, dynamic>) return null;
    final email = claims['email'];
    return CurrentUser(email: email is String ? email : null);
  } on FormatException {
    return null;
  }
}

String? _nameFromEmail(String? email) {
  if (email == null || !email.contains('@')) return null;
  final local = email.split('@').first;
  final first = local.split(RegExp(r'[._\-+0-9]')).firstWhere(
        (part) => part.isNotEmpty,
    orElse: () => '',
  );
  if (first.isEmpty) return null;
  return first[0].toUpperCase() + first.substring(1);
}
