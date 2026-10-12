import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/route_paths.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/feedback/app_popup.dart';

class _Message {
  const _Message({
    required this.text,
    required this.fromPatient,
    required this.time,
    this.actionLabel,
  });

  final String text;
  final bool fromPatient;
  final String time;

  /// The small "Open care plan"-style button a care-team message can carry.
  final String? actionLabel;
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
  final _messages = <_Message>[
    const _Message(
      text: 'Your visit summary is available in Health records.',
      fromPatient: false,
      time: '10:24',
    ),
    const _Message(
      text: 'Thank you. Where can I find my care plan?',
      fromPatient: true,
      time: '10:28',
    ),
    const _Message(
      text: 'Open Health records and select Care plans.',
      fromPatient: false,
      time: '10:31',
      actionLabel: 'Open care plan',
    ),
  ];

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
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
              child: Row(
                children: [
                  SvgPicture.asset(
                    'assets/images/logo/lifecome-live-logo.svg',
                    height: 24,
                    semanticsLabel: 'LifeCome Live',
                  ),
                  const Spacer(),
                  Material(
                    color: AppColors.surface,
                    shape: const CircleBorder(),
                    child: InkWell(
                      customBorder: const CircleBorder(),
                      onTap: () => context.go(RoutePaths.profile),
                      child: const SizedBox(
                        width: 38,
                        height: 38,
                        child: Icon(
                          Icons.person_outline,
                          size: 20,
                          color: AppColors.ink,
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
                  const Text(
                    'Messages',
                    style: TextStyle(fontSize: 13, color: AppColors.inkMuted),
                  ),
                  const SizedBox(height: 2),
                  const Text(
                    'Care team messages',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      color: AppColors.ink,
                    ),
                  ),
                  const SizedBox(height: 2),
                  const Text(
                    'Patient support.',
                    style: TextStyle(fontSize: 14, color: AppColors.inkMuted),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.sm),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE3EEFB),
                      borderRadius: BorderRadius.circular(AppRadius.control),
                    ),
                    child: const Row(
                      children: [
                        Icon(
                          Icons.info_outline,
                          size: 18,
                          color: AppColors.blue,
                        ),
                        SizedBox(width: AppSpacing.xs),
                        Expanded(
                          child: Text(
                            'Messages are reviewed during service hours, not continuously.',
                            style: TextStyle(
                              fontSize: 13,
                              color: AppColors.ink,
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
              child: ListView(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.sm,
                ),
                children: [
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: AppSpacing.xs),
                      child: Text(
                        'Today',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.inkMuted,
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
                    icon: const Icon(
                      Icons.attach_file,
                      color: AppColors.inkMuted,
                    ),
                  ),
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      decoration: InputDecoration(
                        hintText: 'Type a message...',
                        filled: true,
                        fillColor: AppColors.white,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.md,
                          vertical: AppSpacing.sm,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(AppRadius.pill),
                          borderSide: const BorderSide(color: AppColors.line),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(AppRadius.pill),
                          borderSide: const BorderSide(color: AppColors.line),
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
                color: const Color(0xFFFCEAEA),
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
                        const Icon(
                          Icons.emergency_outlined,
                          size: 18,
                          color: AppColors.error,
                        ),
                        const SizedBox(width: AppSpacing.xs),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Need urgent help?',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.error,
                                ),
                              ),
                              Text(
                                'View emergency guidance.',
                                style: TextStyle(
                                  fontSize: 12.5,
                                  color: AppColors.error.withValues(
                                    alpha: 0.85,
                                  ),
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Icon(
                          Icons.chevron_right,
                          size: 18,
                          color: AppColors.error,
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
              style: const TextStyle(fontSize: 11, color: AppColors.inkMuted),
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
                  color: const Color(0xFFEAF7E8),
                  borderRadius: BorderRadius.circular(AppRadius.control),
                ),
                child: Text(
                  message.text,
                  style: const TextStyle(fontSize: 14, color: AppColors.ink),
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
          const CircleAvatar(
            radius: 16,
            backgroundColor: Color(0xFFE3EEFB),
            child: Icon(Icons.support_agent, size: 16, color: AppColors.blue),
          ),
          const SizedBox(width: AppSpacing.xs),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Text(
                      'Care team',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: AppColors.ink,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.xs),
                    Text(
                      message.time,
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.inkMuted,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.all(AppSpacing.sm),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE3EEFB),
                    borderRadius: BorderRadius.circular(AppRadius.control),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        message.text,
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppColors.ink,
                        ),
                      ),
                      if (message.actionLabel != null) ...[
                        const SizedBox(height: AppSpacing.xs),
                        Material(
                          color: AppColors.white,
                          borderRadius: BorderRadius.circular(
                            AppRadius.control,
                          ),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(
                              AppRadius.control,
                            ),
                            onTap: () => context.go(RoutePaths.healthRecords),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: AppSpacing.sm,
                                vertical: AppSpacing.xs,
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    Icons.description_outlined,
                                    size: 16,
                                    color: AppColors.blue,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    message.actionLabel!,
                                    style: const TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.blue,
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  const Icon(
                                    Icons.chevron_right,
                                    size: 16,
                                    color: AppColors.blue,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ],
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
