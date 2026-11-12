import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../auth/current_user.dart';
import '../auth/session_controller.dart';
import '../theme/app_colors.dart';
import 'profile_avatar.dart';

enum _MenuAction { account, signOut }

/// The avatar in the dashboard header. Tapping it opens the account card
/// (name, email, Manage account, Sign out).
class ProfileMenuButton extends ConsumerWidget {
  const ProfileMenuButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider).value;

    return PopupMenuButton<_MenuAction>(
      tooltip: 'Account',
      offset: const Offset(0, 48),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      onSelected: (action) {
        switch (action) {
          case _MenuAction.account:
            context.push('/account');
          case _MenuAction.signOut:
            ref.read(sessionProvider.notifier).signOut();
        }
      },
      itemBuilder: (context) => [
        PopupMenuItem<_MenuAction>(
          enabled: false,
          child: Row(
            children: [
              const ProfileAvatar(radius: 22),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      user?.displayName ?? 'Account',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppColors.ink,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    if (user?.email != null)
                      Text(
                        user!.email!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(color: AppColors.muted, fontSize: 12),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const PopupMenuDivider(),
        const PopupMenuItem<_MenuAction>(
          value: _MenuAction.account,
          child: ListTile(
            dense: true,
            contentPadding: EdgeInsets.zero,
            leading: Icon(Icons.settings_outlined),
            title: Text('Manage account'),
          ),
        ),
        const PopupMenuItem<_MenuAction>(
          value: _MenuAction.signOut,
          child: ListTile(
            dense: true,
            contentPadding: EdgeInsets.zero,
            leading: Icon(Icons.logout),
            title: Text('Sign out'),
          ),
        ),
      ],
      child: const ProfileAvatar(),
    );
  }
}
