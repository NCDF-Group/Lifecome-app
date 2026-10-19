import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/route_paths.dart';
import '../../../core/router/safe_back.dart';
import '../../../core/theme/app_palette.dart';
import '../../../core/utils/validators.dart';
import '../../../core/widgets/buttons/primary_button.dart';
import '../../../core/widgets/buttons/secondary_button.dart';
import '../../../core/widgets/inputs/choice_card.dart';
import '../../../core/widgets/inputs/form_fields.dart';
import '../../../core/widgets/layout/app_header_bar.dart';
import '../../../core/widgets/layout/detail_list.dart';
import '../../../core/widgets/layout/max_content_width.dart';
import '../../../core/widgets/layout/screen_title.dart';
import '../../../core/widgets/layout/step_progress.dart';
import '../application/menopause_controller.dart';
import '../domain/menopause_assessment.dart';

/// The menopause assessment (screen pack 063-065) in three steps on one
/// screen: how the person is feeling, their health background, then a
/// review before saving. It prepares the consultation; it does not diagnose.
class MenopauseAssessmentScreen extends ConsumerStatefulWidget {
  const MenopauseAssessmentScreen({super.key});

  @override
  ConsumerState<MenopauseAssessmentScreen> createState() =>
      _MenopauseAssessmentScreenState();
}

class _MenopauseAssessmentScreenState
    extends ConsumerState<MenopauseAssessmentScreen> {
  int _step = 1;
  late String _topic;
  late String _impact;
  late String _previous;
  final _priority = TextEditingController();
  final _treatment = TextEditingController();
  final _history = TextEditingController();
  bool _consented = false;
  String? _priorityError;
  bool _showConsentError = false;

  @override
  void initState() {
    super.initState();
    final saved = ref.read(menopauseProvider).assessment;
    _topic = saved?.topic ?? MenopauseAssessment.topics.first;
    _impact = saved?.impact ?? MenopauseAssessment.impacts[1];
    _previous =
        saved?.previousCare ?? MenopauseAssessment.previousCareOptions.first;
    _priority.text = saved?.priority ?? '';
    _treatment.text = saved?.treatment ?? '';
    _history.text = saved?.history ?? '';
  }

  @override
  void dispose() {
    _priority.dispose();
    _treatment.dispose();
    _history.dispose();
    super.dispose();
  }

  String? _optional(TextEditingController c) {
    final text = c.text.trim();
    return text.isEmpty ? null : text;
  }

  void _next() {
    switch (_step) {
      case 1:
        final error = Validators.text(
          _priority.text,
          label: 'what matters most to you',
          required: true,
          minLength: 5,
        );
        setState(() => _priorityError = error);
        if (error == null) setState(() => _step = 2);
      case 2:
        setState(() => _showConsentError = !_consented);
        if (_consented) setState(() => _step = 3);
      default:
        ref
            .read(menopauseProvider.notifier)
            .saveAssessment(
              MenopauseAssessment(
                topic: _topic,
                priority: _priority.text.trim(),
                impact: _impact,
                previousCare: _previous,
                treatment: _optional(_treatment),
                history: _optional(_history),
              ),
            );
        context.pushReplacement(RoutePaths.menopauseBooking);
    }
  }

  void _back() {
    if (_step > 1) {
      setState(() => _step--);
    } else {
      context.goBack(fallback: RoutePaths.menopause);
    }
  }

  @override
  Widget build(BuildContext context) {
    final (title, subtitle) = switch (_step) {
      1 => (
        'Tell us how you’re feeling',
        'This assessment helps prepare your consultation. It does not provide '
            'a diagnosis.',
      ),
      2 => (
        'Your health background',
        'Share what is relevant for your GP to review.',
      ),
      _ => (
        'Review your assessment',
        'You can change these details before continuing.',
      ),
    };

    return PopScope(
      canPop: _step == 1,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _back();
      },
      child: Scaffold(
        backgroundColor: context.palette.background,
        body: SafeArea(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 25),
            children: [
              MaxContentWidth(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    AppHeaderBar(
                      showBack: true,
                      onBack: _back,
                      backFallback: RoutePaths.menopause,
                    ),
                    StepProgress(step: _step, total: 3),
                    ScreenTitle(title: title, subtitle: subtitle),
                    const SizedBox(height: 10),
                    ...switch (_step) {
                      1 => _feeling(),
                      2 => _background(),
                      _ => _review(),
                    },
                    const SizedBox(height: 16),
                    PrimaryButton(
                      label: _step == 3
                          ? 'Save and choose an appointment'
                          : 'Continue',
                      onPressed: _next,
                    ),
                    if (_step == 3) ...[
                      const SizedBox(height: 10),
                      SecondaryButton(
                        label: 'Edit assessment',
                        onPressed: () => setState(() => _step = 1),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _feeling() => [
    SelectField(
      label: 'Main topic to discuss',
      options: MenopauseAssessment.topics,
      value: _topic,
      onChanged: (value) => setState(() => _topic = value),
    ),
    TextAreaField(
      label: 'What matters most to you?',
      controller: _priority,
      hintText:
          'For example, changes you have noticed and the support you '
          'would like',
      errorText: _priorityError,
    ),
    SelectField(
      label: 'How much does this affect daily life?',
      options: MenopauseAssessment.impacts,
      value: _impact,
      onChanged: (value) => setState(() => _impact = value),
    ),
  ];

  List<Widget> _background() => [
    SelectField(
      label: 'Have you received menopause care before?',
      options: MenopauseAssessment.previousCareOptions,
      value: _previous,
      onChanged: (value) => setState(() => _previous = value),
    ),
    TextAreaField(
      label: 'Current medication or treatment',
      controller: _treatment,
      optional: true,
      maxLines: 3,
    ),
    TextAreaField(
      label: 'Relevant medical history',
      controller: _history,
      optional: true,
      maxLines: 3,
    ),
    CheckRow(
      value: _consented,
      onChanged: (value) => setState(() {
        _consented = value;
        if (value) _showConsentError = false;
      }),
      label: 'I agree to share this assessment with my GP.',
    ),
    if (_showConsentError)
      Padding(
        padding: const EdgeInsets.only(left: 30),
        child: Text(
          'Please confirm to continue.',
          style: TextStyle(fontSize: 12.5, color: context.palette.danger),
        ),
      ),
  ];

  List<Widget> _review() => [
    DetailList(
      rows: [
        ('Main topic', _topic),
        ('Daily impact', _impact),
        ('Previous care', _previous),
        if (_optional(_treatment) != null)
          ('Medication or treatment', _treatment.text.trim()),
      ],
    ),
    PanelCard(title: 'Your priority', body: _priority.text.trim()),
  ];
}
