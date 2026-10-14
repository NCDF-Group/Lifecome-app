import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/theme/app_palette.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/feedback/app_popup.dart';
import '../../../core/widgets/layout/app_header_bar.dart';
import '../../../core/widgets/layout/max_content_width.dart';
import '../../../core/widgets/layout/screen_title.dart';

/// What to do in an emergency. LifeCome Live is not an emergency service, so
/// this is the first thing to read when something is seriously wrong.
///
/// The wording is general UK public guidance; it should be reviewed and signed
/// off by LifeCome's clinical governance lead before launch.
class EmergencyGuidanceScreen extends StatelessWidget {
  const EmergencyGuidanceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return Scaffold(
      backgroundColor: palette.background,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
          children: [
            MaxContentWidth(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const AppHeaderBar(showBack: true, showBell: false),
                  const SizedBox(height: 20),
                  const ScreenTitle(
                    title: 'Need urgent help?',
                    subtitle:
                        'LifeCome Live is not an emergency service. Please '
                        "don't use the app, messages or a booked appointment "
                        'in an emergency.',
                  ),
                  const SizedBox(height: AppSpacing.md),
                  const _NumberCard(
                    number: '999',
                    title: 'Life-threatening emergency',
                    body:
                        'Call 999 if someone is seriously ill or injured, '
                        'has chest pain, difficulty breathing, signs of a '
                        'stroke, or their life is at risk.',
                    emergency: true,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  const _NumberCard(
                    number: '111',
                    title: 'Urgent, but not life-threatening',
                    body:
                        'Call NHS 111, or go to 111.nhs.uk, if you need '
                        'urgent medical help or advice and it is not an '
                        'emergency.',
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  const _NumberCard(
                    number: '116 123',
                    title: 'Feeling in crisis or low',
                    body:
                        'Samaritans are free to call, any time, day or '
                        'night. If you may harm yourself, call 999.',
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    'Tap a number to copy it, then dial it from your phone.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 12.5, color: palette.inkMuted),
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

class _NumberCard extends StatelessWidget {
  const _NumberCard({
    required this.number,
    required this.title,
    required this.body,
    this.emergency = false,
  });

  final String number;
  final String title;
  final String body;
  final bool emergency;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final color = emergency ? palette.danger : palette.accent;

    return Material(
      color: emergency ? palette.tintRed : palette.tintBlue,
      borderRadius: BorderRadius.circular(AppRadius.card),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadius.card),
        onTap: () async {
          await Clipboard.setData(ClipboardData(text: number));
          if (!context.mounted) return;
          await showSuccessPopup(
            context,
            title: 'Copied',
            message: '$number is copied. Open your phone and dial it.',
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.phone_in_talk_outlined, color: color),
                  const SizedBox(width: AppSpacing.xs),
                  Text(
                    number,
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w700,
                      color: color,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                title,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: palette.ink,
                ),
              ),
              Text(
                body,
                style: TextStyle(
                  fontSize: 13.5,
                  color: palette.inkMuted,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
