import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../core/auth/current_user.dart';
import '../../core/auth/session_controller.dart';
import '../../core/data/data_revision.dart';
import '../../core/network/api_exception.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/profile_avatar.dart';
import 'data/account_repository.dart';

/// Manage account: photo, name, phone, password, sign out.
class AccountScreen extends ConsumerWidget {
  const AccountScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Manage account')),
      body: user.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('$error')),
        data: (u) => _AccountBody(user: u ?? const CurrentUser()),
      ),
    );
  }
}

class _AccountBody extends ConsumerStatefulWidget {
  const _AccountBody({required this.user});

  final CurrentUser user;

  @override
  ConsumerState<_AccountBody> createState() => _AccountBodyState();
}

class _AccountBodyState extends ConsumerState<_AccountBody> {
  final _profileKey = GlobalKey<FormState>();
  final _passwordKey = GlobalKey<FormState>();

  late final _first = TextEditingController(text: widget.user.firstName ?? '');
  late final _middle = TextEditingController(text: widget.user.middleName ?? '');
  late final _last = TextEditingController(text: widget.user.lastName ?? '');
  late final _phone = TextEditingController(text: widget.user.phoneNumber ?? '');
  final _oldPassword = TextEditingController();
  final _newPassword = TextEditingController();
  final _confirmPassword = TextEditingController();

  bool _busy = false;

  @override
  void dispose() {
    for (final c in [_first, _middle, _last, _phone, _oldPassword, _newPassword, _confirmPassword]) {
      c.dispose();
    }
    super.dispose();
  }

  /// Runs an API action with a busy flag and a snackbar for success / failure.
  Future<void> _run(Future<void> Function() action, String success) async {
    setState(() => _busy = true);
    final messenger = ScaffoldMessenger.of(context);
    try {
      await action();
      messenger.showSnackBar(SnackBar(content: Text(success)));
    } on ApiException catch (e) {
      messenger.showSnackBar(SnackBar(content: Text(e.message)));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _changePhoto() async {
    final picked = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      maxWidth: 1024,
      maxHeight: 1024,
      imageQuality: 85,
    );
    if (picked == null) return;

    await _run(() async {
      await ref.read(accountRepositoryProvider).uploadPhoto(picked.path);
      ref.read(dataRevisionProvider.notifier).bump();
    }, 'Photo updated');
  }

  Future<void> _saveProfile() async {
    if (!_profileKey.currentState!.validate()) return;
    String? clean(TextEditingController c) => c.text.trim().isEmpty ? null : c.text.trim();

    await _run(() async {
      await ref.read(accountRepositoryProvider).updateProfile(
            firstName: _first.text.trim(),
            lastName: _last.text.trim(),
            middleName: clean(_middle),
            phoneNumber: clean(_phone),
          );
      ref.read(dataRevisionProvider.notifier).bump();
    }, 'Profile saved');
  }

  Future<void> _changePassword() async {
    if (!_passwordKey.currentState!.validate()) return;

    await _run(() async {
      await ref.read(accountRepositoryProvider).changePassword(
            oldPassword: _oldPassword.text,
            newPassword: _newPassword.text,
          );
      _oldPassword.clear();
      _newPassword.clear();
      _confirmPassword.clear();
    }, 'Password changed');
  }

  /// Mirrors the server: 8+ characters with upper case, lower case and a digit.
  static String? _validateNewPassword(String? v) {
    if (v == null || v.length < 8) return 'Use at least 8 characters';
    if (!v.contains(RegExp('[A-Z]'))) return 'Add an upper case letter';
    if (!v.contains(RegExp('[a-z]'))) return 'Add a lower case letter';
    if (!v.contains(RegExp('[0-9]'))) return 'Add a number';
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final user = widget.user;

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  const ProfileAvatar(radius: 44),
                  const SizedBox(height: 12),
                  Text(
                    user.displayName,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
                  ),
                  if (user.email != null)
                    Text(user.email!, style: const TextStyle(color: AppColors.muted)),
                  const SizedBox(height: 12),
                  OutlinedButton.icon(
                    onPressed: _busy ? null : _changePhoto,
                    icon: const Icon(Icons.photo_camera_outlined),
                    label: const Text('Change photo'),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _profileKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text('Your details', style: TextStyle(fontWeight: FontWeight.w700)),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _first,
                      textCapitalization: TextCapitalization.words,
                      decoration: const InputDecoration(labelText: 'First name', border: OutlineInputBorder()),
                      validator: (v) => (v == null || v.trim().isEmpty) ? 'Enter your first name' : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _middle,
                      textCapitalization: TextCapitalization.words,
                      decoration: const InputDecoration(labelText: 'Middle name (optional)', border: OutlineInputBorder()),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _last,
                      textCapitalization: TextCapitalization.words,
                      decoration: const InputDecoration(labelText: 'Last name', border: OutlineInputBorder()),
                      validator: (v) => (v == null || v.trim().isEmpty) ? 'Enter your last name' : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _phone,
                      keyboardType: TextInputType.phone,
                      decoration: const InputDecoration(labelText: 'Phone number (optional)', border: OutlineInputBorder()),
                    ),
                    const SizedBox(height: 16),
                    FilledButton(
                      onPressed: _busy ? null : _saveProfile,
                      child: const Text('Save changes'),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _passwordKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text('Change password', style: TextStyle(fontWeight: FontWeight.w700)),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _oldPassword,
                      obscureText: true,
                      decoration: const InputDecoration(labelText: 'Current password', border: OutlineInputBorder()),
                      validator: (v) => (v == null || v.isEmpty) ? 'Enter your current password' : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _newPassword,
                      obscureText: true,
                      decoration: const InputDecoration(labelText: 'New password', border: OutlineInputBorder()),
                      validator: _validateNewPassword,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _confirmPassword,
                      obscureText: true,
                      decoration: const InputDecoration(labelText: 'Confirm new password', border: OutlineInputBorder()),
                      validator: (v) => v != _newPassword.text ? 'Passwords do not match' : null,
                    ),
                    const SizedBox(height: 16),
                    FilledButton(
                      onPressed: _busy ? null : _changePassword,
                      child: const Text('Change password'),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          OutlinedButton.icon(
            onPressed: () => ref.read(sessionProvider.notifier).signOut(),
            icon: const Icon(Icons.logout, color: AppColors.expense),
            label: const Text('Sign out', style: TextStyle(color: AppColors.expense)),
            style: OutlinedButton.styleFrom(minimumSize: const Size.fromHeight(48)),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}
