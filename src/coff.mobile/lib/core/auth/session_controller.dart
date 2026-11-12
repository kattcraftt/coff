import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../storage/token_storage.dart';

/// Whether the user currently holds a token. Lives in `core` because both the
/// router and the HTTP client depend on it; the login UI lives in features/auth.
class SessionController extends AsyncNotifier<bool> {
  @override
  Future<bool> build() async {
    final token = await ref.read(tokenStorageProvider).read();
    return token != null;
  }

  Future<void> signIn(String token) async {
    await ref.read(tokenStorageProvider).write(token);
    state = const AsyncData(true);
  }

  Future<void> signOut() async {
    await ref.read(tokenStorageProvider).clear();
    state = const AsyncData(false);
  }
}

final sessionProvider =
AsyncNotifierProvider<SessionController, bool>(SessionController.new);
