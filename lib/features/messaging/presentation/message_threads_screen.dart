import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';

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
  final _messages = <_Message>[
    const _Message(
      text: 'Hello. How can we help with your visit?',
      fromPatient: false,
      time: '9:35 AM',
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
      appBar: AppBar(
        title: const Row(
          children: [
            CircleAvatar(
              radius: 18,
              backgroundColor: AppColors.blue,
              child: Icon(
                Icons.support_agent,
                color: AppColors.white,
                size: 20,
              ),
            ),
            SizedBox(width: AppSpacing.sm),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'LifeCome care team',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: AppColors.ink,
                  ),
                ),
                Text(
                  'Patient support',
                  style: TextStyle(fontSize: 12, color: AppColors.inkMuted),
                ),
              ],
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.all(AppSpacing.md),
              padding: const EdgeInsets.all(AppSpacing.sm),
              decoration: BoxDecoration(
                color: AppColors.cyan.withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(AppRadius.control),
                border: Border.all(
                  color: AppColors.cyan.withValues(alpha: 0.4),
                ),
              ),
              child: const Row(
                children: [
                  Icon(Icons.info_outline, size: 18, color: AppColors.blue),
                  SizedBox(width: AppSpacing.xs),
                  Expanded(
                    child: Text(
                      'Messages are reviewed during service hours.',
                      style: TextStyle(fontSize: 13, color: AppColors.ink),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                itemCount: _messages.length,
                itemBuilder: (context, index) =>
                    _MessageBubble(message: _messages[index]),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
              child: Row(
                children: [
                  const Icon(
                    Icons.warning_amber_rounded,
                    size: 16,
                    color: AppColors.gold,
                  ),
                  const SizedBox(width: AppSpacing.xxs),
                  const Expanded(
                    child: Text(
                      'For urgent medical help, seek in-person care.',
                      style: TextStyle(fontSize: 12, color: AppColors.inkMuted),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(AppSpacing.sm),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      decoration: InputDecoration(
                        hintText: 'Type a message',
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.md,
                          vertical: AppSpacing.sm,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(AppRadius.pill),
                          borderSide: const BorderSide(color: AppColors.line),
                        ),
                      ),
                      onSubmitted: (_) => _send(),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  CircleAvatar(
                    backgroundColor: AppColors.blue,
                    child: IconButton(
                      icon: const Icon(
                        Icons.send,
                        color: AppColors.white,
                        size: 18,
                      ),
                      onPressed: _send,
                    ),
                  ),
                ],
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
    final alignment = message.fromPatient
        ? CrossAxisAlignment.end
        : CrossAxisAlignment.start;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xxs),
      child: Column(
        crossAxisAlignment: alignment,
        children: [
          Container(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.75,
            ),
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.sm,
              vertical: AppSpacing.xs,
            ),
            decoration: BoxDecoration(
              color: message.fromPatient ? AppColors.blue : AppColors.surface,
              borderRadius: BorderRadius.circular(AppRadius.control),
            ),
            child: Text(
              message.text,
              style: TextStyle(
                fontSize: 14,
                color: message.fromPatient ? AppColors.white : AppColors.ink,
              ),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            message.time,
            style: const TextStyle(fontSize: 11, color: AppColors.inkMuted),
          ),
        ],
      ),
    );
  }
}
