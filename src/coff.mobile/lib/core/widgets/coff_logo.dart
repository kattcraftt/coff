import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';

import '../theme/app_colors.dart';

/// Replace assets/images/coff-logo.svg with coff.client/public/coff-logo.svg.
/// If that file already contains the "coff" wordmark, pass showWordmark: false.
class CoffLogo extends StatelessWidget {
  const CoffLogo({this.height = 30, this.showWordmark = true, super.key});

  final double height;
  final bool showWordmark;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        SvgPicture.asset('assets/images/coff-logo.svg', height: height),
        if (showWordmark) ...[
          const SizedBox(width: 8),
          Text(
            'coff',
            style: GoogleFonts.jetBrainsMono(
              fontSize: height * 0.9,
              fontWeight: FontWeight.w700,
              color: AppColors.ink,
            ),
          ),
        ],
      ],
    );
  }
}
