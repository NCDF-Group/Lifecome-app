import 'package:flutter/material.dart';

import '../../../../core/widgets/media/avatar.dart';

/// The dark rounded panel the waiting room and call draw the other person
/// in (the screen pack's `.video-stage`): a large initials disc, a title and
/// a line or two of status.
class VideoStage extends StatelessWidget {
  const VideoStage({
    super.key,
    required this.name,
    required this.title,
    required this.message,
    this.minHeight = 300,
  });

  /// Whose initials to show.
  final String name;
  final String title;
  final String message;
  final double minHeight;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(minHeight: minHeight),
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF1A3150), Color(0xFF0B2437)],
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          UserAvatar(name: name, radius: 50),
          const SizedBox(height: 20),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 13,
              height: 1.6,
              color: Color(0xFFB9CCD9),
            ),
          ),
        ],
      ),
    );
  }
}
