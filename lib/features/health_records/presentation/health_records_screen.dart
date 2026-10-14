import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/route_paths.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_palette.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/feedback/app_popup.dart';
import '../../../core/widgets/feedback/empty_state.dart';
import '../../../core/widgets/feedback/info_banner.dart';
import '../../../core/widgets/layout/app_header_bar.dart';
import '../../../core/widgets/layout/screen_title.dart';

/// Blueprint view 21 — Health Records.
///
/// The backend has no way to return a patient's records yet, so there is
/// nothing real to list: the screen says so rather than showing sample records.
/// The two actions below it are the ones that are not waiting on a records
/// endpoint.
class HealthRecordsScreen extends StatelessWidget {
  const HealthRecordsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.palette.background,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
          children: [
            const AppHeaderBar(
              showBack: true,
              backFallback: RoutePaths.profile,
            ),
            const SizedBox(height: 20),
            const ScreenTitle(
              title: 'Your health records',
              subtitle:
                  'Your visit summaries, results and care plans will be kept '
                  'here.',
            ),
            const SizedBox(height: AppSpacing.sm),
            const EmptyState(
              icon: Icons.folder_open_outlined,
              title: 'No records yet',
              message:
                  'Records from your visits will appear here once your care '
                  'team adds them to your account.',
            ),
            const SizedBox(height: AppSpacing.sm),
            Material(
              color: AppColors.blue,
              borderRadius: BorderRadius.circular(AppRadius.card),
              child: InkWell(
                borderRadius: BorderRadius.circular(AppRadius.card),
                onTap: () =>
                    showComingSoonPopup(context, feature: 'Document upload'),
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: context.palette.elevated.withValues(
                            alpha: 0.18,
                          ),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.cloud_upload_outlined,
                          color: AppColors.white,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Upload a document',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: AppColors.white,
                              ),
                            ),
                            Text(
                              'Share test results, letters or other '
                              'documents with your care team.',
                              style: TextStyle(
                                fontSize: 12.5,
                                color: AppColors.white,
                                height: 1.4,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Icon(Icons.chevron_right, color: AppColors.white),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Material(
              color: context.palette.surface,
              borderRadius: BorderRadius.circular(AppRadius.card),
              child: InkWell(
                borderRadius: BorderRadius.circular(AppRadius.card),
                onTap: () => context.push(RoutePaths.privacyAndSharing),
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: context.palette.tintBlue,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.people_outline,
                          color: context.palette.accent,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Manage sharing permissions',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: context.palette.ink,
                              ),
                            ),
                            Text(
                              'Choose who can view your records.',
                              style: TextStyle(
                                fontSize: 12.5,
                                color: context.palette.inkMuted,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Icon(
                        Icons.chevron_right,
                        color: context.palette.inkMuted,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            const InfoBanner(
              message:
                  'These records may not include your complete NHS history.',
            ),
          ],
        ),
      ),
    );
  }
}
