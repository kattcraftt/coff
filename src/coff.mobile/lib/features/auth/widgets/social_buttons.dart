import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../../core/config/features.dart';

/// "or" divider + Google / GitHub buttons from the web design.
/// Not wired to a backend yet (see Features.socialLogin).
class SocialButtons extends StatelessWidget {
  const SocialButtons({super.key});

  void _comingSoon(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Social sign-in is coming soon.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!Features.socialLogin) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 24),
        const Row(
          children: [
            Expanded(child: Divider(color: Colors.black, thickness: 1)),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 8),
              child: Text('or', style: TextStyle(fontSize: 12)),
            ),
            Expanded(child: Divider(color: Colors.black, thickness: 1)),
          ],
        ),
        const SizedBox(height: 24),
        _SocialButton(
          icon: const FaIcon(
            FontAwesomeIcons.google,
            size: 18,
            color: Color(0xFF4285F4),
          ),
          label: 'Google',
          onPressed: () => _comingSoon(context),
        ),
        const SizedBox(height: 14),
        _SocialButton(
          icon: const FaIcon(FontAwesomeIcons.github, size: 20),
          label: 'Github',
          onPressed: () => _comingSoon(context),
        ),
      ],
    );
  }
}

class _SocialButton extends StatelessWidget {
  const _SocialButton({
    required this.icon,
    required this.label,
    required this.onPressed,
  });

  final Widget icon;
  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      elevation: 3,
      shadowColor: Colors.black.withValues(alpha: 0.2),
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: onPressed,
        child: SizedBox(
          height: 48,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              icon,
              const SizedBox(width: 10),
              Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
            ],
          ),
        ),
      ),
    );
  }
}
