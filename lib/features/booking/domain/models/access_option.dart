import 'package:flutter/painting.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_svg_icons.dart';

/// The ways a booking can be funded other than paying per visit.
enum AccessOption {
  lifecomeBenefits('LifeCome Benefits', 'Check eligibility.'),
  workplace('Workplace or Community', 'Use an access code.'),
  membership('Optional Membership', 'View terms.');

  const AccessOption(this.title, this.hint);

  final String title;

  /// Short line shown under the title on "Choose your access".
  final String hint;

  AppSvgGlyph get glyph => switch (this) {
    lifecomeBenefits => AppSvgGlyph.briefcaseBold,
    workplace => AppSvgGlyph.usersBold,
    membership => AppSvgGlyph.idCardBold,
  };

  Color get color => switch (this) {
    lifecomeBenefits => AppColors.accentLime,
    workplace => AppColors.accentGreen,
    membership => AppColors.accentCyan,
  };
}
