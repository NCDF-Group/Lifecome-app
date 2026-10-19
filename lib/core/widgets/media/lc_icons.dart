import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../theme/app_palette.dart';

/// Names of the line icons in assets/icons/lc: the LifeCome Live screen
/// pack's own icon set (24x24, 1.8 stroke), drawn with [LcIcon].
abstract final class LcIcons {
  static const arrow = 'arrow';
  static const back = 'back';
  static const bag = 'bag';
  static const bell = 'bell';
  static const calendar = 'calendar';
  static const card = 'card';
  static const care = 'care';
  static const check = 'check';
  static const chevron = 'chevron';
  static const clinic = 'clinic';
  static const clock = 'clock';
  static const close = 'close';
  static const download = 'download';
  static const file = 'file';
  static const gp = 'gp';
  static const heart = 'heart';
  static const home = 'home';
  static const info = 'info';
  static const leaf = 'leaf';
  static const lock = 'lock';
  static const mail = 'mail';
  static const message = 'message';
  static const mic = 'mic';
  static const people = 'people';
  static const phone = 'phone';
  static const pin = 'pin';
  static const plus = 'plus';
  static const search = 'search';
  static const settings = 'settings';
  static const shield = 'shield';
  static const star = 'star';
  static const truck = 'truck';
  static const user = 'user';
  static const video = 'video';
  static const wellbeing = 'wellbeing';
}

/// One of the [LcIcons], tinted to [color] (the ambient icon colour when
/// null). [bold] draws the heavier 2.5 stroke the screen pack uses for the
/// selected bottom-nav tab; only home, calendar, message and user have it.
class LcIcon extends StatelessWidget {
  const LcIcon(
    this.name, {
    super.key,
    this.size = 22,
    this.color,
    this.bold = false,
    this.semanticLabel,
  });

  final String name;
  final double size;
  final Color? color;
  final bool bold;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final tint = color ?? IconTheme.of(context).color ?? context.palette.ink;
    return SvgPicture.asset(
      'assets/icons/lc/$name${bold ? '-bold' : ''}.svg',
      width: size,
      height: size,
      colorFilter: ColorFilter.mode(tint, BlendMode.srcIn),
      semanticsLabel: semanticLabel,
      excludeFromSemantics: semanticLabel == null,
    );
  }
}
