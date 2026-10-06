import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/route_paths.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/buttons/primary_button.dart';
import '../domain/models/appointment.dart';

const _durations = [
  'Less than a day',
  'A few days',
  'About a week',
  'More than a week',
];

/// Blueprint view 14 — Before Your Visit (clinical intake).
class BeforeYourVisitScreen extends StatefulWidget {
  const BeforeYourVisitScreen({super.key, required this.selection});

  final BookingSelection selection;

  @override
  State<BeforeYourVisitScreen> createState() => _BeforeYourVisitScreenState();
}

class _BeforeYourVisitScreenState extends State<BeforeYourVisitScreen> {
  final _concernController = TextEditingController();
  String _duration = _durations.first;
  bool _consented = false;

  @override
  void dispose() {
    _concernController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        title: const Text(
          'Help your doctor prepare',
          style: TextStyle(color: AppColors.ink, fontWeight: FontWeight.w800),
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          children: [
            const Text(
              'A few details before your consultation.',
              style: TextStyle(fontSize: 14, color: AppColors.inkMuted),
            ),
            const SizedBox(height: AppSpacing.md),
            const Text(
              'What would you like to discuss?',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: AppColors.ink,
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            TextField(
              controller: _concernController,
              maxLines: 4,
              decoration: InputDecoration(
                hintText: 'Briefly describe your concern',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppRadius.control),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            const Text(
              'How long has this been happening?',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: AppColors.ink,
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            DropdownButtonFormField<String>(
              initialValue: _duration,
              items: [
                for (final duration in _durations)
                  DropdownMenuItem(value: duration, child: Text(duration)),
              ],
              onChanged: (value) =>
                  setState(() => _duration = value ?? _duration),
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppRadius.control),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            CheckboxListTile(
              value: _consented,
              onChanged: (value) => setState(() => _consented = value ?? false),
              controlAffinity: ListTileControlAffinity.leading,
              contentPadding: EdgeInsets.zero,
              title: const Text(
                'I agree to an online consultation',
                style: TextStyle(fontSize: 14, color: AppColors.ink),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            PrimaryButton(
              label: 'Save visit details',
              onPressed: !_consented
                  ? null
                  : () => context.push(
                      RoutePaths.bookingReview,
                      extra: widget.selection.copyWith(
                        concern: _concernController.text,
                      ),
                    ),
            ),
            const SizedBox(height: AppSpacing.xs),
            const Center(
              child: Text(
                'Your doctor will review these details.',
                style: TextStyle(fontSize: 12, color: AppColors.inkMuted),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
