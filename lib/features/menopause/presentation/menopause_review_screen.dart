import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/route_paths.dart';
import '../../../core/theme/app_palette.dart';
import '../../../core/utils/validators.dart';
import '../../../core/widgets/buttons/primary_button.dart';
import '../../../core/widgets/inputs/form_fields.dart';
import '../../../core/widgets/layout/app_header_bar.dart';
import '../../../core/widgets/layout/max_content_width.dart';
import '../../../core/widgets/layout/screen_title.dart';
import '../application/menopause_controller.dart';
import '../domain/menopause_assessment.dart';

/// "Prepare for your review" (screen pack 068): what has changed since the
/// last visit, before booking another menopause consultation.
class MenopauseReviewScreen extends ConsumerStatefulWidget {
  const MenopauseReviewScreen({super.key});

  @override
  ConsumerState<MenopauseReviewScreen> createState() =>
      _MenopauseReviewScreenState();
}

class _MenopauseReviewScreenState extends ConsumerState<MenopauseReviewScreen> {
  String _progress = MenopauseReviewNote.progressOptions[1];
  final _review = TextEditingController();
  final _questions = TextEditingController();
  String? _reviewError;

  @override
  void dispose() {
    _review.dispose();
    _questions.dispose();
    super.dispose();
  }

  void _continue() {
    final error = Validators.text(
      _review.text,
      label: 'what you would like to review',
      required: true,
      minLength: 5,
    );
    setState(() => _reviewError = error);
    if (error != null) return;
    final questions = _questions.text.trim();
    ref
        .read(menopauseProvider.notifier)
        .saveReview(
          MenopauseReviewNote(
            progress: _progress,
            review: _review.text.trim(),
            questions: questions.isEmpty ? null : questions,
          ),
        );
    context.pushReplacement(RoutePaths.menopauseBooking);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.palette.background,
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
                    backFallback: RoutePaths.menopausePlan,
                  ),
                  const SizedBox(height: 4),
                  const ScreenTitle(
                    title: 'Prepare for your review',
                    subtitle:
                        'Tell your GP what has changed since your last visit.',
                  ),
                  const SizedBox(height: 10),
                  SelectField(
                    label: 'How have things been?',
                    options: MenopauseReviewNote.progressOptions,
                    value: _progress,
                    onChanged: (value) => setState(() => _progress = value),
                  ),
                  TextAreaField(
                    label: 'What would you like to review?',
                    controller: _review,
                    hintText: 'For example, your progress and next steps',
                    errorText: _reviewError,
                  ),
                  TextAreaField(
                    label: 'Questions or concerns',
                    controller: _questions,
                    optional: true,
                    maxLines: 3,
                  ),
                  const SizedBox(height: 16),
                  PrimaryButton(
                    label: 'Continue to booking',
                    onPressed: _continue,
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
