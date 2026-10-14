import 'package:flutter/material.dart';

import '../../theme/app_palette.dart';

const _titles = {'dr', 'mr', 'mrs', 'ms', 'miss', 'mx', 'prof', 'professor'};

/// The initials to show for a real person's name: the first letter of the
/// first and last words, ignoring a leading title ("Dr Adaeze Okafor" → "AO").
/// Returns "?" when there is no usable name.
String initialsFor(String? name) {
  final words = (name ?? '')
      .trim()
      .split(RegExp(r'\s+'))
      .where((word) => word.isNotEmpty)
      .toList();
  while (words.length > 1 &&
      _titles.contains(words.first.toLowerCase().replaceAll('.', ''))) {
    words.removeAt(0);
  }
  if (words.isEmpty) return '?';
  final first = String.fromCharCode(words.first.runes.first).toUpperCase();
  if (words.length == 1) return first;
  final last = String.fromCharCode(words.last.runes.first).toUpperCase();
  return '$first$last';
}

/// A person's avatar: their own photo when there is one, otherwise their real
/// initials. Never a stock face — if nobody has uploaded a photo, the initials
/// are all there is.
class UserAvatar extends StatelessWidget {
  const UserAvatar({
    super.key,
    required this.name,
    this.image,
    this.radius = 22,
  });

  final String? name;

  /// The person's uploaded photo, if they have one.
  final ImageProvider? image;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: name == null || name!.trim().isEmpty ? 'Profile photo' : name,
      image: true,
      child: ExcludeSemantics(
        child: CircleAvatar(
          radius: radius,
          backgroundColor: context.palette.tintBlueStrong,
          foregroundImage: image,
          // If the photo can't be loaded the initials underneath stay visible.
          onForegroundImageError: image == null ? null : (_, _) {},
          child: Text(
            initialsFor(name),
            style: TextStyle(
              fontSize: radius * 0.72,
              fontWeight: FontWeight.w600,
              color: context.palette.accent,
            ),
          ),
        ),
      ),
    );
  }
}
