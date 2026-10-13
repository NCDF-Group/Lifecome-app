import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/route_paths.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_palette.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/feedback/app_popup.dart';

class _Message {
  const _Message({
    required this.text,
    required this.fromPatient,
    required this.time,
  });

  final String text;
  final bool fromPatient;
  final String time;
}

/// The Messages tab — blueprint view 22, Care Team Messages. There is only
/// ever one thread (the patient's own care team), so this goes straight to
/// the conversation rather than a thread list. No messaging backend exists
/// yet: sent messages are appended locally only, for now.
class MessageThreadsScreen extends StatefulWidget {
  const MessageThreadsScreen({super.key});

  @override
  State<MessageThreadsScreen> createState() => _MessageThreadsScreenState();
}

class _MessageThreadsScreenState extends State<MessageThreadsScreen> {
  final _controller = TextEditingController();

  /// No messaging backend exists yet, so this starts empty rather than
  /// showing a fabricated conversation — a real exchange only appears here
  /// once the patient sends one or the care team replies.
  final _messages = <_Message>[];

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _send() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    setState(() {
      _messages.add(_Message(text: text, fromPatient: true, time: 'Now'));
      _controller.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.palette.background,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
              child: Row(
                children: [
                  SvgPicture.asset(
                    context.palette.logoAsset,
                    height: 24,
                    semanticsLabel: 'LifeCome Live',
                  ),
                  const Spacer(),
                  Material(
                    color: context.palette.surface,
                    shape: const CircleBorder(),
                    child: InkWell(
                      customBorder: const CircleBorder(),
                      onTap: () => context.go(RoutePaths.profile),
                      child: SizedBox(
                        width: 38,
                        height: 38,
                        child: Icon(
                          Icons.person_outline,
                          size: 20,
                          color: context.palette.ink,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Messages',
                    style: TextStyle(
                      fontSize: 13,
                      color: context.palette.inkMuted,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Care team messages',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w600,
                      color: context.palette.ink,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Patient support.',
                    style: TextStyle(
                      fontSize: 14,
                      color: context.palette.inkMuted,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.sm),
                    decoration: BoxDecoration(
                      color: context.palette.tintBlue,
                      borderRadius: BorderRadius.circular(AppRadius.control),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.info_outline,
                          size: 18,
                          color: context.palette.accent,
                        ),
                        SizedBox(width: AppSpacing.xs),
                        Expanded(
                          child: Text(
                            'Messages are reviewed during service hours, not continuously.',
                            style: TextStyle(
                              fontSize: 13,
                              color: context.palette.ink,
                              height: 1.4,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: _messages.isEmpty
                  ? const _EmptyThread()
                  : ListView(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.md,
                        vertical: AppSpacing.sm,
                      ),
                      children: [
                        Center(
                          child: Padding(
                            padding: EdgeInsets.symmetric(
                              vertical: AppSpacing.xs,
                            ),
                            child: Text(
                              'Today',
                              style: TextStyle(
                                fontSize: 12,
                                color: context.palette.inkMuted,
                              ),
                            ),
                          ),
                        ),
                        for (final message in _messages)
                          _MessageBubble(message: message),
                      ],
                    ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.md,
                AppSpacing.xs,
                AppSpacing.md,
                AppSpacing.sm,
              ),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () =>
                        showComingSoonPopup(context, feature: 'Attachments'),
                    icon: Icon(
                      Icons.attach_file,
                      color: context.palette.inkMuted,
                    ),
                  ),
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      decoration: InputDecoration(
                        hintText: 'Type a message...',
                        filled: true,
                        fillColor: context.palette.elevated,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.md,
                          vertical: AppSpacing.sm,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(AppRadius.pill),
                          borderSide: BorderSide(color: context.palette.line),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(AppRadius.pill),
                          borderSide: BorderSide(color: context.palette.line),
                        ),
                      ),
                      onSubmitted: (_) => _send(),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  Material(
                    color: AppColors.blue,
                    shape: const CircleBorder(),
                    child: InkWell(
                      customBorder: const CircleBorder(),
                      onTap: _send,
                      child: const SizedBox(
                        width: 44,
                        height: 44,
                        child: Icon(
                          Icons.arrow_upward_rounded,
                          color: AppColors.white,
                          size: 20,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.md,
                0,
                AppSpacing.md,
                AppSpacing.sm,
              ),
              child: Material(
                color: context.palette.tintRed,
                borderRadius: BorderRadius.circular(AppRadius.control),
                child: InkWell(
                  borderRadius: BorderRadius.circular(AppRadius.control),
                  onTap: () => showComingSoonPopup(
                    context,
                    feature: 'Emergency guidance',
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.sm,
                      vertical: AppSpacing.sm,
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.emergency_outlined,
                          size: 18,
                          color: context.palette.danger,
                        ),
                        const SizedBox(width: AppSpacing.xs),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Need urgent help?',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: context.palette.danger,
                                ),
                              ),
                              Text(
                                'View emergency guidance.',
                                style: TextStyle(
                                  fontSize: 12.5,
                                  color: context.palette.danger.withValues(
                                    alpha: 0.85,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Icon(
                          Icons.chevron_right,
                          size: 18,
                          color: context.palette.danger,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyThread extends StatelessWidget {
  const _EmptyThread();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: context.palette.tintBlue,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.forum_outlined,
                color: context.palette.accent,
                size: 28,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'No messages yet',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: context.palette.ink,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Send a message to start a conversation with your care team.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                color: context.palette.inkMuted,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  const _MessageBubble({required this.message});

  final _Message message;

  @override
  Widget build(BuildContext context) {
    if (message.fromPatient) {
      return Padding(
        padding: const EdgeInsets.only(bottom: AppSpacing.sm),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              message.time,
              style: TextStyle(fontSize: 11, color: context.palette.inkMuted),
            ),
            const SizedBox(height: 2),
            Align(
              alignment: Alignment.centerRight,
              child: Container(
                constraints: BoxConstraints(
                  maxWidth: MediaQuery.of(context).size.width * 0.72,
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm,
                  vertical: AppSpacing.sm,
                ),
                decoration: BoxDecoration(
                  color: context.palette.tintGreen,
                  borderRadius: BorderRadius.circular(AppRadius.control),
                ),
                child: Text(
                  message.text,
                  style: TextStyle(fontSize: 14, color: context.palette.ink),
                ),
              ),
            ),
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 16,
            backgroundColor: context.palette.tintBlue,
            child: Icon(
              Icons.support_agent,
              size: 16,
              color: context.palette.accent,
            ),
          ),
          const SizedBox(width: AppSpacing.xs),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      'Care team',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: context.palette.ink,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.xs),
                    Text(
                      message.time,
                      style: TextStyle(
                        fontSize: 11,
                        color: context.palette.inkMuted,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.all(AppSpacing.sm),
                  decoration: BoxDecoration(
                    color: context.palette.tintBlue,
                    borderRadius: BorderRadius.circular(AppRadius.control),
                  ),
                  child: Text(
                    message.text,
                    style: TextStyle(fontSize: 14, color: context.palette.ink),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
