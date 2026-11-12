import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/auth/session_controller.dart';
import '../../../core/network/api_exception.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/coff_text_field.dart';
import '../data/auth_repository.dart';
import '../widgets/auth_scaffold.dart';
import '../widgets/social_buttons.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _confirm = TextEditingController();
  bool _submitting = false;
  String? _error;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    _confirm.dispose();
    super.dispose();
  }

  /// Mirrors the server: 8+ characters with upper case, lower case and a digit.
  static String? _validatePassword(String? v) {
    if (v == null || v.length < 8) return 'Use at least 8 characters';
    if (!v.contains(RegExp('[A-Z]'))) return 'Add an upper case letter';
    if (!v.contains(RegExp('[a-z]'))) return 'Add a lower case letter';
    if (!v.contains(RegExp('[0-9]'))) return 'Add a number';
    return null;
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _submitting = true;
      _error = null;
    });

    try {
      final repo = ref.read(authRepositoryProvider);
      final email = _email.text.trim();
      await repo.register(
        email: email,
        password: _password.text,
        confirmPassword: _confirm.text,
      );
      // Sign the new user straight in.
      final token = await repo.login(email: email, password: _password.text);
      await ref.read(sessionProvider.notifier).signIn(token);
    } on ApiException catch (e) {
      if (mounted) setState(() => _error = e.message);
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AuthScaffold(
      title: 'Create Account',
      headerActionLabel: 'Login',
      onHeaderAction: () => context.go('/login'),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            CoffTextField(
              controller: _email,
              label: 'Email',
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
              autofillHints: const [AutofillHints.email],
              validator: (v) =>
              (v == null || !v.contains('@')) ? 'Enter a valid email' : null,
            ),
            const SizedBox(height: 14),
            CoffTextField(
              controller: _password,
              label: 'Password',
              obscure: true,
              textInputAction: TextInputAction.next,
              autofillHints: const [AutofillHints.newPassword],
              validator: _validatePassword,
            ),
            const SizedBox(height: 14),
            CoffTextField(
              controller: _confirm,
              label: 'Confirm Password',
              obscure: true,
              textInputAction: TextInputAction.done,
              validator: (v) =>
              v != _password.text ? 'Passwords do not match' : null,
              onSubmitted: (_) => _submit(),
            ),
            const SizedBox(height: 20),
            if (_error != null) ...[
              Text(
                _error!,
                style: const TextStyle(color: AppColors.expense, fontSize: 13),
              ),
              const SizedBox(height: 8),
            ],
            FilledButton(
              onPressed: _submitting ? null : _submit,
              child: _submitting
                  ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
                  : const Text('Register'),
            ),
            const SocialButtons(),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('Already have an account? ', style: TextStyle(fontSize: 13)),
                GestureDetector(
                  onTap: () => context.go('/login'),
                  child: const Text(
                    'Login',
                    style: TextStyle(color: AppColors.link, fontSize: 13),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
