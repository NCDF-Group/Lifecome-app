import 'package:flutter/material.dart';
import 'package:lifecome_mobile/core/theme/app_icons.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/route_paths.dart';
import '../../../core/theme/app_palette.dart';
import '../../../core/widgets/buttons/primary_button.dart';
import '../../../core/widgets/feedback/info_banner.dart';
import '../../../core/widgets/layout/app_header_bar.dart';
import '../../../core/widgets/layout/screen_title.dart';
import '../../../core/widgets/lists/row_card.dart';
import '../../../core/widgets/media/lc_icons.dart';

/// Prototype entry point for health information released by another
/// professional. Importing the sample changes only this screen's local state.
class ProfessionalRecordUpdatesScreen extends StatefulWidget {
  const ProfessionalRecordUpdatesScreen({super.key});

  @override
  State<ProfessionalRecordUpdatesScreen> createState() =>
      _ProfessionalRecordUpdatesScreenState();
}

class _ProfessionalRecordUpdatesScreenState
    extends State<ProfessionalRecordUpdatesScreen> {
  bool _sampleImported = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.palette.background,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 25),
          children: [
            const AppHeaderBar(
              showBack: true,
              backFallback: RoutePaths.healthRecords,
            ),
            const SizedBox(height: 4),
            const ScreenTitle(
              eyebrow: 'Health records',
              title: 'Professional record updates',
              subtitle: 'See information shared by healthcare professionals.',
            ),
            const SizedBox(height: 10),
            const InfoBanner(
              tone: BannerTone.warning,
              message:
                  'Professional Portal connection is not available in this '
                  'app yet. You can import a fictional sample to preview the screen.',
            ),
            if (_sampleImported) ...[
              const SizedBox(height: 14),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: context.palette.tintGreen,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          AppIcons.checkCircle,
                          color: context.palette.positive,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Sample record added to this preview',
                            style: TextStyle(
                              color: context.palette.ink,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Example · Blood test summary',
                      style: TextStyle(
                        color: context.palette.ink,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      'Shared by Example Health Professional · 9 November 2026',
                      style: TextStyle(
                        color: context.palette.inkMuted,
                        fontSize: 12.5,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Fictional sample record. It is not medical advice and '
                      'is not saved to your account.',
                      style: TextStyle(
                        color: context.palette.inkMuted,
                        height: 1.45,
                        fontSize: 12.5,
                      ),
                    ),
                  ],
                ),
              ),
            ] else ...[
              const SizedBox(height: 16),
              PrimaryButton(
                label: 'Import fictional sample record',
                onPressed: () => setState(() => _sampleImported = true),
              ),
            ],
            const SizedBox(height: 12),
            RowCard(
              icon: LcIcons.file,
              title: 'View health records',
              subtitle: 'Notes, prescriptions, referrals and test results',
              onTap: () => context.push(RoutePaths.healthRecords),
            ),
            if (_sampleImported)
              TextButton(
                onPressed: () => setState(() => _sampleImported = false),
                child: const Text('Clear sample preview'),
              ),
          ],
        ),
      ),
    );
  }
}
