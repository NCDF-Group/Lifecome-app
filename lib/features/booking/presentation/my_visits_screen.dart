import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/buttons/primary_button.dart';
import '../../../core/widgets/feedback/app_popup.dart';

/// The Visits tab landing screen. No visits backend exists yet, so this
/// only ever shows the empty state — the booking flow itself (views 05-17
/// in the blueprint: choose how to pay, select a service, find a doctor,
/// book, pay, confirm) is its own, much larger piece of work.
class MyVisitsScreen extends StatelessWidget {
  const MyVisitsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        title: const Text(
          'My visits',
          style: TextStyle(color: AppColors.ink, fontWeight: FontWeight.w800),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 84,
                height: 84,
                decoration: BoxDecoration(
                  color: AppColors.blue.withValues(alpha: 0.08),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.calendar_today_outlined,
                  color: AppColors.blue,
                  size: 36,
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              const Text(
                'No visits yet',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: AppColors.ink,
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              const Text(
                'When you book a consultation, it will show up here alongside your care plan and receipts.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.inkMuted,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              PrimaryButton(
                label: 'Book a consultation',
                onPressed: () => showComingSoonPopup(
                  context,
                  feature: 'Booking a consultation',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
