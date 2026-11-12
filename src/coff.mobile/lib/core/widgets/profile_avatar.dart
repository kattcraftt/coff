import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../auth/current_user.dart';
import '../auth/profile_image.dart';
import '../theme/app_colors.dart';

/// The user's photo, or their initial on the orange circle when there is no photo.
class ProfileAvatar extends ConsumerWidget {
  const ProfileAvatar({this.radius = 18, super.key});

  final double radius;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider).value;
    final image = ref.watch(profileImageProvider).value;

    return CircleAvatar(
      radius: radius,
      backgroundColor: AppColors.avatar,
      foregroundImage: image == null ? null : MemoryImage(image),
      child: Text(
        user?.initial ?? '?',
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w700,
          fontSize: radius * 0.8,
        ),
      ),
    );
  }
}
