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

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _submitting = false;
  String? _error;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _submitting = true;
      _error = null;
    });

    try {
      final token = await ref.read(authRepositoryProvider).login(
        email: _email.text.trim(),
        password: _password.text,
      );
      // The router redirects to /overview once the session flips to signed-in.
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
      title: 'Welcome back!',
      headerActionLabel: 'Register',
      onHeaderAction: () => context.go('/register'),
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
              textInputAction: TextInputAction.done,
              autofillHints: const [AutofillHints.password],
              validator: (v) =>
              (v == null || v.isEmpty) ? 'Enter your password' : null,
              onSubmitted: (_) => _submit(),
            ),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Password reset is not available yet.'),
                  ),
                ),
                child: const Text(
                  'Forgot Password?',
                  style: TextStyle(color: AppColors.link, fontSize: 13),
                ),
              ),
            ),
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
                  : const Text('Login'),
            ),
            const SocialButtons(),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text("Don't have an account? ", style: TextStyle(fontSize: 13)),
                GestureDetector(
                  onTap: () => context.go('/register'),
                  child: const Text(
                    'Register',
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
