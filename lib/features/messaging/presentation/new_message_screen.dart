import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/network/api_exception.dart';
import '../../../core/router/route_paths.dart';
import '../../../core/theme/app_palette.dart';
import '../../../core/utils/validators.dart';
import '../../../core/widgets/buttons/primary_button.dart';
import '../../../core/widgets/feedback/app_popup.dart';
import '../../../core/widgets/feedback/info_banner.dart';
import '../../../core/widgets/inputs/choice_card.dart';
import '../../../core/widgets/inputs/form_fields.dart';
import '../../../core/widgets/layout/app_header_bar.dart';
import '../../../core/widgets/layout/max_content_width.dart';
import '../../../core/widgets/layout/screen_title.dart';
import '../application/messaging_controller.dart';
import '../../profile/presentation/profile_required_prompt.dart';
import '../domain/models/message_thread.dart';
import 'widgets/message_composer.dart';

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
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 25),
          children: [
            MaxContentWidth(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const AppHeaderBar(
                    showBack: true,
                    showBell: false,
                    backFallback: RoutePaths.messages,
                  ),
                  const SizedBox(height: 4),
                  const ScreenTitle(
                    title: 'Start a conversation',
                    subtitle:
                        'Choose what you need help with so your message '
                        'reaches the right person.',
                  ),
                  const SizedBox(height: 18),
                  const FieldLabel('What do you need help with?'),
                  for (final topic in MessageTopic.values)
                    ChoiceCard(
                      title: topic.label,
                      selected: _topic == topic,
                      onTap: () {
                        setState(() => _topic = topic);
                        if (_submitted) _validate();
                      },
                    ),
                  if (_topicError != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 2),
                      child: Text(
                        _topicError!,
                        style: TextStyle(fontSize: 12.5, color: palette.danger),
                      ),
                    ),
                  const SizedBox(height: 8),
                  TextAreaField(
                    label: 'Message',
                    controller: _bodyController,
                    hintText: 'Tell us how we can help',
                    errorText: _bodyError,
                    maxLines: 8,
                    onChanged: (_) {
                      if (_submitted) _validate();
                    },
                  ),
                  const SizedBox(height: 16),
                  PrimaryButton(
                    label: 'Send message',
                    loading: _sending,
                    onPressed: _send,
                  ),
                  const SizedBox(height: 14),
                  const InfoBanner(
                    message:
                        'Messages are reviewed during service hours and are '
                        'not monitored for emergencies.',
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
