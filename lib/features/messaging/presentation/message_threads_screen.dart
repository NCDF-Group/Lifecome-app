import 'package:flutter/material.dart';

import '../../../core/theme/app_typography.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/animation/fade_in.dart';
import '../../../core/network/api_exception.dart';
import '../../../core/providers/core_providers.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_svg_icons.dart';
import '../../../core/widgets/design/soft_widgets.dart';
import '../../../core/widgets/feedback/app_popup.dart';
import '../../dashboard/presentation/widgets/home_header.dart';

enum _Topic {
  booking(
    'booking_payments',
    'Booking and payments',
    'Questions about appointments and booking.',
    AppSvgGlyph.calendarBold,
    AppColors.actionBlue,
    false,
  ),
  online(
    'online_appointment',
    'Online appointment',
    'Help with your online consultation.',
    AppSvgGlyph.videoBold,
    AppColors.accentGreen,
    true,
  ),
  clinic(
    'clinic_visit',
    'Clinic visit',
    'Questions about your in-person appointment.',
    AppSvgGlyph.pinBold,
    AppColors.actionBlue,
    false,
  ),
  followUp(
    'follow_up',
    'Follow-up query',
    'Other questions for the care team.',
    AppSvgGlyph.chatBold,
    AppColors.actionBlue,
    false,
  );

  const _Topic(
    this.apiValue,
    this.title,
    this.hint,
    this.glyph,
    this.color,
    this.greenTint,
  );

  /// What the backend stores as the thread's topic.
  final String apiValue;
  final String title;
  final String hint;
  final AppSvgGlyph glyph;
  final Color color;
  final bool greenTint;

  Color get fill => greenTint ? AppColors.tintGreen : AppColors.tintBlue;
}

/// The Messages tab (blueprint view 22): pick a topic, write a message and
/// send it to the care team. No messaging backend exists yet, so sending only
/// confirms and clears the form.
class MessageThreadsScreen extends ConsumerStatefulWidget {
  const MessageThreadsScreen({super.key});

  @override
  ConsumerState<MessageThreadsScreen> createState() =>
      _MessageThreadsScreenState();
}

class _MessageThreadsScreenState extends ConsumerState<MessageThreadsScreen> {
  final _controller = TextEditingController();
  _Topic _topic = _Topic.booking;
  bool _sending = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    if (_controller.text.trim().isEmpty) {
      await showErrorPopup(context, 'Please type your message first.');
      return;
    }
    setState(() => _sending = true);
    try {
      await ref
          .read(messagingRepositoryProvider)
          .startThread(topic: _topic.apiValue, body: _controller.text.trim());
    } on ApiException catch (error) {
      if (!mounted) return;
      setState(() => _sending = false);
      await showErrorPopup(context, error.message);
      return;
    }
    if (!mounted) return;
    setState(() => _sending = false);
    _controller.clear();
    await showSuccessPopup(
      context,
      title: 'Message sent',
      message:
          'Thanks - the LifeCome care team will reply during service hours.',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          children: [
            const HomeHeader(),
            const SizedBox(height: 28),
            const FadeIn(
              child: PageHeading(
                'Contact your care team',
                subtitle: 'Choose a topic and tell us how we can help.',
              ),
            ),
            const SizedBox(height: 26),
            Text(
              'What do you need help with?',
              style: TextStyle(
                fontSize: 19,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.5,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 14),
            for (final topic in _Topic.values)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _TopicCard(
                  topic: topic,
                  selected: topic == _topic,
                  onTap: () => setState(() => _topic = topic),
                ),
              ),
            const SizedBox(height: 18),
            Text(
              'Your message',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                letterSpacing: -0.3,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _controller,
              minLines: 4,
              maxLines: 7,
              textCapitalization: TextCapitalization.sentences,
              style: TextStyle(fontSize: 16, color: AppColors.textPrimary),
              decoration: InputDecoration(
                hintText: 'Type your message here...',
                hintStyle: TextStyle(
                  fontSize: 17,
                  color: AppColors.textSecondary,
                ),
                filled: true,
                fillColor: AppColors.inputFill,
                contentPadding: const EdgeInsets.all(18),
                border: _border(AppColors.cardBorder),
                enabledBorder: _border(AppColors.cardBorder),
                focusedBorder: _border(AppColors.actionBlue),
              ),
            ),
            const SizedBox(height: 28),
            SizedBox(
              height: 58,
              child: FilledButton(
                onPressed: _sending ? null : _send,
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.actionBlue,
                  foregroundColor: AppColors.white,
                  shape: const StadiumBorder(),
                  textStyle: const TextStyle(
                    fontFamily: appFontFamily,
                    fontSize: 19,
                    fontWeight: FontWeight.w500,
                    letterSpacing: -0.3,
                  ),
                ),
                child: _sending
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          color: AppColors.white,
                        ),
                      )
                    : const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('Send message'),
                          SizedBox(width: 10),
                          AppSvgIcon(AppSvgGlyph.chevronLine, size: 20),
                        ],
                      ),
              ),
            ),
            const SizedBox(height: 26),
            const InfoNote(
              'Messages are not monitored continuously.\n'
              'Do not use for emergencies.',
              centerIcon: true,
            ),
            const SizedBox(height: 18),
            LinkRow(
              glyph: AppSvgGlyph.infoBold,
              color: AppColors.error,
              textColor: AppColors.alertRed,
              title: 'Emergency and urgent help',
              onTap: () => showComingSoonPopup(
                context,
                feature: 'Emergency and urgent help',
              ),
            ),
          ],
        ),
      ),
    );
  }

  static OutlineInputBorder _border(Color color) => OutlineInputBorder(
    borderRadius: BorderRadius.circular(12),
    borderSide: BorderSide(color: color),
  );
}

class _TopicCard extends StatelessWidget {
  const _TopicCard({
    required this.topic,
    required this.selected,
    required this.onTap,
  });

  final _Topic topic;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SoftCard(
      onTap: onTap,
      radius: 14,
      fill: AppColors.background,
      borderColor: selected ? AppColors.actionBlue : AppColors.cardBorder,
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
      child: Row(
        children: [
          _RadioDot(selected: selected),
          const SizedBox(width: 14),
          IconCircle(
            glyph: topic.glyph,
            color: topic.color,
            fill: topic.fill,
            size: 54,
            iconSize: 26,
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  topic.title,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.5,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  topic.hint,
                  style: TextStyle(
                    fontSize: 14,
                    height: 1.3,
                    letterSpacing: -0.3,
                    color: AppColors.textSecondary,
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

class _RadioDot extends StatelessWidget {
  const _RadioDot({required this.selected});

  final bool selected;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 160),
      width: 28,
      height: 28,
      padding: const EdgeInsets.all(3.5),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: selected ? AppColors.actionBlue : AppColors.textSecondary,
          width: selected ? 1.6 : 1,
        ),
      ),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: selected ? AppColors.actionBlue : Colors.transparent,
        ),
      ),
    );
  }
}
