import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/route_paths.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_svg_icons.dart';
import '../../../core/widgets/design/soft_widgets.dart';
import '../../../core/widgets/feedback/app_popup.dart';

class _Topic {
  const _Topic(this.glyph, this.color, this.label);

  final AppSvgGlyph glyph;
  final Color color;
  final String label;
}

const _topics = [
  _Topic(
    AppSvgGlyph.briefcaseBold,
    AppColors.accentLime,
    'HMO membership & cover',
  ),
  _Topic(AppSvgGlyph.walletBold, AppColors.actionBlue, 'Payments & refunds'),
  _Topic(
    AppSvgGlyph.calendarBold,
    AppColors.actionBlue,
    'Appointments & connections',
  ),
  _Topic(AppSvgGlyph.userBold, AppColors.accentGreen, 'Account & privacy'),
];

/// Help and support, under the Profile tab.
class HelpCentreScreen extends StatelessWidget {
  const HelpCentreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
          children: [
            const DesignBackButton(),
            const SizedBox(height: 14),
            const PageHeading(
              'How can we help?',
              subtitle: 'Find answers or contact patient support.',
            ),
            const SizedBox(height: 22),
            TextField(
              style: TextStyle(fontSize: 17, color: AppColors.textPrimary),
              decoration: InputDecoration(
                hintText: 'Search help topics',
                hintStyle: TextStyle(
                  fontSize: 17,
                  color: AppColors.textSecondary,
                ),
                prefixIcon: Padding(
                  padding: EdgeInsets.all(14),
                  child: AppSvgIcon(
                    AppSvgGlyph.searchLine,
                    size: 24,
                    color: AppColors.textSecondary,
                  ),
                ),
                filled: true,
                fillColor: AppColors.inputFill,
                contentPadding: const EdgeInsets.symmetric(vertical: 16),
                border: _border(AppColors.cardBorder),
                enabledBorder: _border(AppColors.cardBorder),
                focusedBorder: _border(AppColors.actionBlue),
              ),
            ),
            const SizedBox(height: 22),
            for (final topic in _topics) ...[
              ActionRow(
                glyph: topic.glyph,
                color: topic.color,
                title: topic.label,
                onTap: () => showComingSoonPopup(context, feature: topic.label),
              ),
              const SizedBox(height: 12),
            ],
            const SizedBox(height: 16),
            Text(
              'Need more help?',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.4,
                color: AppColors.heading,
              ),
            ),
            const SizedBox(height: 12),
            SoftCard(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      IconCircle(glyph: AppSvgGlyph.chatBold, size: 50),
                      SizedBox(width: 14),
                      Expanded(
                        child: Text(
                          'Contact patient support',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.5,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Message our care team and get help with your account, '
                    'appointments, cover and more.',
                    style: TextStyle(
                      fontSize: 14.5,
                      height: 1.4,
                      letterSpacing: -0.2,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  PillButton(
                    label: 'Send a message',
                    onPressed: () => context.go(RoutePaths.messages),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.tintRed,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.tintRedBorder),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      AppSvgIcon(
                        AppSvgGlyph.infoBold,
                        size: 22,
                        color: AppColors.alertRed,
                      ),
                      SizedBox(width: 12),
                      Text(
                        'Medical emergency?',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.4,
                          color: AppColors.alertRed,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 6),
                  Text(
                    'Seek immediate in-person care. Do not wait for a chat '
                    'reply.',
                    style: TextStyle(
                      fontSize: 14.5,
                      height: 1.4,
                      letterSpacing: -0.2,
                      color: AppColors.textSecondary,
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

  static OutlineInputBorder _border(Color color) => OutlineInputBorder(
    borderRadius: BorderRadius.circular(12),
    borderSide: BorderSide(color: color),
  );
}
