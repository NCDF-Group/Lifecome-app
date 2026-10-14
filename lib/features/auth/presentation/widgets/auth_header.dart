import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../core/router/route_paths.dart';
import '../../../../core/theme/app_palette.dart';
import '../../../../core/widgets/layout/app_bar_back.dart';

/// The top row of every sign-in and sign-up screen: a back arrow, then the
/// LifeCome Live logo. Back goes to the previous screen, or to [fallback]
/// (the welcome screen) when this was the first screen opened.
class AuthHeader extends StatelessWidget {
  const AuthHeader({
    super.key,
    this.fallback = RoutePaths.welcome,
    this.logoHeight = 24,
  });

  final String fallback;
  final double logoHeight;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        AppBackButton(fallback: fallback),
        SvgPicture.asset(
          context.palette.logoAsset,
          height: logoHeight,
          semanticsLabel: 'LifeCome Live',
        ),
      ],
    );
  }
}
