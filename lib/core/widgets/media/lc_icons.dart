import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:lucide_icons_flutter/lucide_icons_500.dart';

import '../../theme/app_icons.dart';
import '../../theme/app_palette.dart';

/// Stable names used by existing screens, mapped to the shared Lucide set.
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
/// null). [bold] uses a heavier Lucide stroke for selected bottom-nav icons.
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
    final icon = switch ((name, bold)) {
      (LcIcons.home, true) => LucideIcons500.house,
      (LcIcons.calendar, true) => LucideIcons500.calendarDays,
      (LcIcons.message, true) => LucideIcons500.messageCircle,
      (LcIcons.user, true) => LucideIcons500.userRound,
      _ => _iconForName(name),
    };

    return Icon(icon, size: size, color: tint, semanticLabel: semanticLabel);
  }

  IconData _iconForName(String name) => switch (name) {
    LcIcons.arrow => AppIcons.arrowForward,
    LcIcons.back => AppIcons.arrowBack,
    LcIcons.bag => LucideIcons.shoppingBag,
    LcIcons.bell => AppIcons.notification,
    LcIcons.calendar => AppIcons.calendar,
    LcIcons.card => AppIcons.creditCard,
    LcIcons.care => AppIcons.care,
    LcIcons.check => AppIcons.check,
    LcIcons.chevron => AppIcons.chevronRight,
    LcIcons.clinic => AppIcons.clinic,
    LcIcons.clock => AppIcons.clock,
    LcIcons.close => AppIcons.close,
    LcIcons.download => AppIcons.download,
    LcIcons.file => AppIcons.file,
    LcIcons.gp => AppIcons.medical,
    LcIcons.heart => LucideIcons.heart,
    LcIcons.home => AppIcons.home,
    LcIcons.info => AppIcons.info,
    LcIcons.leaf => AppIcons.leaf,
    LcIcons.lock => AppIcons.lock,
    LcIcons.mail => AppIcons.mail,
    LcIcons.message => AppIcons.message,
    LcIcons.mic => AppIcons.mic,
    LcIcons.people => AppIcons.people,
    LcIcons.phone => AppIcons.phone,
    LcIcons.pin => AppIcons.pin,
    LcIcons.plus => AppIcons.add,
    LcIcons.search => AppIcons.search,
    LcIcons.settings => LucideIcons.settings,
    LcIcons.shield => AppIcons.shield,
    LcIcons.star => LucideIcons.star,
    LcIcons.truck => AppIcons.truck,
    LcIcons.user => AppIcons.user,
    LcIcons.video => AppIcons.video,
    LcIcons.wellbeing => AppIcons.wellbeing,
    _ => AppIcons.help,
  };
}
