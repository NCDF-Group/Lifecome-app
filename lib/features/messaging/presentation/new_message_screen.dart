import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/network/api_exception.dart';
import '../../../core/router/route_paths.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_palette.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/utils/validators.dart';
import '../../../core/widgets/buttons/primary_button.dart';
import '../../../core/widgets/feedback/app_popup.dart';
import '../../../core/widgets/layout/back_app_bar.dart';
import '../../../core/widgets/layout/max_content_width.dart';
import '../../../core/widgets/layout/screen_title.dart';
import '../application/messaging_controller.dart';
import '../../profile/presentation/profile_required_prompt.dart';
import '../domain/models/message_thread.dart';
import 'widgets/message_composer.dart';

IconData _topicIcon(MessageTopic topic) => switch (topic) {
  MessageTopic.bookingPayments => Icons.payments_outlined,
  MessageTopic.onlineAppointment => Icons.videocam_outlined,
  MessageTopic.clinicVisit => Icons.apartment_outlined,
  MessageTopic.followUp => Icons.event_repeat_outlined,
};

/// "What do you need help with?" — pick a topic and write the first message to
/// the care team.
class NewMessageScreen extends ConsumerStatefulWidget {
  const NewMessageScreen({super.key, this.initialTopic});

  final MessageTopic? initialTopic;

  @override
  ConsumerState<NewMessageScreen> createState() => _NewMessageScreenState();
}

class _NewMessageScreenState extends ConsumerState<NewMessageScreen> {
  final _bodyController = TextEditingController();
  MessageTopic? _topic;
  String? _topicError;
  String? _bodyError;
  bool _submitted = false;
  bool _sending = false;

  @override
  void initState() {
    super.initState();
    _topic = widget.initialTopic;
  }

  @override
  void dispose() {
    _bodyController.dispose();
    super.dispose();
  }

  bool _validate() {
    setState(() {
      _topicError = _topic == null ? 'Choose what you need help with.' : null;
      _bodyError = Validators.text(
        _bodyController.text,
        label: 'a message',
        required: true,
        maxLength: maxMessageLength,
      );
    });
    return _topicError == null && _bodyError == null;
  }

  Future<void> _send() async {
    if (_sending) return;
    setState(() => _submitted = true);
    if (!_validate()) return;

    setState(() => _sending = true);
    try {
      final thread = await ref
          .read(threadsProvider.notifier)
          .start(topic: _topic!, body: _bodyController.text.trim());
      if (!mounted) return;
      context.pushReplacement('${RoutePaths.messageThread}/${thread.id}');
    } on ApiException catch (error) {
      if (!mounted) return;
      if (error.code == 'PROFILE_REQUIRED') {
        await promptCompleteProfile(context);
      } else {
        await showErrorPopup(context, error.message);
      }
    } catch (_) {
      if (mounted) {
        await showErrorPopup(
          context,
          'Something went wrong. Please try again.',
        );
      }
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return Scaffold(
      backgroundColor: palette.background,
      appBar: const BackAppBar(
        title: 'New message',
        fallback: RoutePaths.messages,
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          children: [
            MaxContentWidth(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const ScreenTitle(
                    title: 'What do you need help with?',
                    subtitle:
                        'Pick a topic so your message reaches the right '
                        'person.',
                  ),
                  const SizedBox(height: AppSpacing.md),
                  for (final topic in MessageTopic.values) ...[
                    _TopicTile(
                      topic: topic,
                      selected: _topic == topic,
                      onTap: () {
                        setState(() => _topic = topic);
                        if (_submitted) _validate();
                      },
                    ),
                    const SizedBox(height: AppSpacing.xs),
                  ],
                  if (_topicError != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 2),
                      child: Text(
                        _topicError!,
                        style: TextStyle(fontSize: 12, color: palette.danger),
                      ),
                    ),
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    'Your message',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: palette.ink,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  TextField(
                    controller: _bodyController,
                    minLines: 4,
                    maxLines: 8,
                    onChanged: (_) {
                      if (_submitted) _validate();
                    },
                    style: TextStyle(fontSize: 16, color: palette.ink),
                    decoration: InputDecoration(
                      hintText: 'Tell us how we can help',
                      errorText: _bodyError,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  PrimaryButton(
                    label: 'Send message',
                    icon: Icons.send_outlined,
                    loading: _sending,
                    onPressed: _send,
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Center(
                    child: Text(
                      'Messages are reviewed during service hours, not '
                      'continuously.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 12, color: palette.inkMuted),
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

class _TopicTile extends StatelessWidget {
  const _TopicTile({
    required this.topic,
    required this.selected,
    required this.onTap,
  });

  final MessageTopic topic;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Material(
      color: selected ? palette.tintBlue : palette.elevated,
      borderRadius: BorderRadius.circular(AppRadius.card),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadius.card),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.sm),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadius.card),
            border: Border.all(
              color: selected ? palette.accent : palette.line,
              width: 1.5,
            ),
          ),
          child: Row(
            children: [
              Icon(_topicIcon(topic), color: palette.accent),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  topic.label,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: palette.ink,
                  ),
                ),
              ),
              Container(
                width: 22,
                height: 22,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: selected ? palette.accent : palette.line,
                    width: 2,
                  ),
                ),
                child: selected
                    ? Center(
                        child: Container(
                          width: 11,
                          height: 11,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.blue,
                          ),
                        ),
                      )
                    : null,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
