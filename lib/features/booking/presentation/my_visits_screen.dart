import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/route_paths.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_palette.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/buttons/primary_button.dart';

/// The Visits tab landing screen. No visits backend exists yet, so this
/// only ever shows the empty state — the booking flow itself (views 05-17
/// in the blueprint: choose how to pay, select a service, find a doctor,
/// book, pay, confirm) is its own, much larger piece of work.
class MyVisitsScreen extends StatelessWidget {
  const MyVisitsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.palette.background,
      appBar: AppBar(
        title: Text(
          'My visits',
          style: TextStyle(
            color: context.palette.ink,
            fontWeight: FontWeight.w600,
          ),
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
                child: Icon(
                  Icons.calendar_today_outlined,
                  color: context.palette.accent,
                  size: 36,
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              Text(
                'No visits yet',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: context.palette.ink,
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                'When you book a consultation, it will show up here alongside your care plan and receipts.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: context.palette.inkMuted,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              PrimaryButton(
                label: 'Book a consultation',
                onPressed: () => context.push(RoutePaths.chooseAccess),
              ),
              const SizedBox(height: AppSpacing.sm),
              TextButton.icon(
                onPressed: () => context.push(RoutePaths.findSmartGpClinic),
                icon: const Icon(Icons.apartment_outlined),
                label: const Text('Find a Smart GP clinic'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
