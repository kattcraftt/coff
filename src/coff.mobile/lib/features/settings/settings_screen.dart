import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/auth/current_user.dart';
import '../../core/auth/session_controller.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/profile_avatar.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider).value;

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: ListTile(
              leading: const ProfileAvatar(radius: 22),
              title: Text(user?.displayName ?? 'Account'),
              subtitle: user?.email == null ? null : Text(user!.email!),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => context.push('/account'),
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.account_balance_wallet_outlined),
                  title: const Text('Accounts'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => context.push('/accounts'),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.label_outline),
                  title: const Text('Categories'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => context.push('/categories'),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.description_outlined),
                  title: const Text('Open-source licenses'),
                  onTap: () => showLicensePage(context: context, applicationName: 'coff'),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.logout, color: AppColors.expense),
                  title: const Text('Sign out', style: TextStyle(color: AppColors.expense)),
                  onTap: () => ref.read(sessionProvider.notifier).signOut(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
