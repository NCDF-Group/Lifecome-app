import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/route_paths.dart';
import '../../../core/router/safe_back.dart';
import '../../../core/theme/app_palette.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/utils/validators.dart';
import '../../../core/widgets/buttons/primary_button.dart';
import '../../../core/widgets/buttons/secondary_button.dart';
import '../../../core/widgets/feedback/status_chip.dart';
import '../../../core/widgets/inputs/app_text_field.dart';
import '../../../core/widgets/inputs/choice_card.dart';
import '../../../core/widgets/inputs/form_fields.dart';
import '../../../core/widgets/layout/detail_list.dart';
import '../../../core/widgets/layout/screen_title.dart';
import '../../../core/widgets/layout/step_progress.dart';
import '../../profile/application/profile_controller.dart';
import '../application/care_controller.dart';
import '../domain/care_models.dart';
import 'care_widgets.dart';

/// The care request (screen pack 075-078) in four steps on one screen: who
/// the care is for, what support is needed, when, then a review.
class CareRequestScreen extends ConsumerStatefulWidget {
  const CareRequestScreen({super.key, this.service});

  /// Preselects the main type of support when started from a service page.
  final CareService? service;

  @override
  ConsumerState<CareRequestScreen> createState() => _CareRequestScreenState();
}

class _CareRequestScreenState extends ConsumerState<CareRequestScreen> {
  int _step = 1;
  bool _someoneElse = false;
  final _name = TextEditingController();
  final _postcode = TextEditingController();
  final _needs = TextEditingController();
  final _preferences = TextEditingController();
  final _phone = TextEditingController();
  late String _need = (widget.service ?? CareService.all.first).title;
  String _days = CareRequest.dayOptions.first;
  String _time = CareRequest.timeOptions.first;
  String _start = CareRequest.startOptions.first;
  bool _permission = false;
  bool _contactOk = false;
  final _errors = <String, String?>{};

  @override
  void initState() {
    super.initState();
    ref.listenManual(meProvider, (_, next) {
      final me = next.value;
      if (me == null) return;
      if (_name.text.isEmpty && !_someoneElse) {
        _name.text = me.displayName ?? '';
      }
      final phone = me.account.phoneNumber;
      if (_phone.text.isEmpty && phone != null) {
        _phone.text = Formatters.ukPhone(phone);
      }
    }, fireImmediately: true);
  }

  @override
  void dispose() {
    for (final c in [_name, _postcode, _needs, _preferences, _phone]) {
      c.dispose();
    }
    super.dispose();
  }

  bool _validateStep() {
    setState(() {
      _errors.clear();
      switch (_step) {
        case 1:
          _errors['name'] = Validators.text(
            _name.text,
            label: 'their name',
            required: true,
            minLength: 2,
          );
          _errors['postcode'] = Validators.ukPostcode(_postcode.text);
          _errors['permission'] = _permission
              ? null
              : 'Please confirm to continue.';
        case 2:
          _errors['needs'] = Validators.text(
            _needs.text,
            label: 'the support needed',
            required: true,
            minLength: 10,
          );
        case 3:
          _errors['phone'] = Validators.ukPhone(_phone.text, required: true);
        case 4:
          _errors['contact'] = _contactOk
              ? null
              : 'Please confirm to continue.';
      }
    });
    return _errors.values.every((e) => e == null);
  }

  void _next() {
    if (!_validateStep()) return;
    if (_step < 4) {
      setState(() => _step++);
      return;
    }
    final preferences = _preferences.text.trim();
    ref
        .read(careProvider.notifier)
        .submit(
          CareRequest(
            forSomeoneElse: _someoneElse,
            recipientName: _name.text.trim(),
            postcode: _postcode.text.trim().toUpperCase(),
            need: _need,
            needsDetail: _needs.text.trim(),
            preferences: preferences.isEmpty ? null : preferences,
            days: _days,
            time: _time,
            start: _start,
            phone: _phone.text.trim(),
            reference: 'LC-CARE-${1000 + Random().nextInt(9000)}',
            submittedAt: DateTime.now(),
          ),
        );
    context.pushReplacement(RoutePaths.careSubmitted);
  }

  void _back() {
    if (_step > 1) {
      setState(() => _step--);
    } else {
      context.goBack(fallback: RoutePaths.care);
    }
  }

  Widget _error(String key) {
    final error = _errors[key];
    if (error == null) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(left: 30, bottom: 4),
      child: Text(
        error,
        style: TextStyle(fontSize: 12.5, color: context.palette.danger),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final (title, subtitle) = switch (_step) {
      1 => ('Who is the care for?', 'Tell us who needs support.'),
      2 => (
        'What support is needed?',
        'Your coordinator will discuss the details with you.',
      ),
      3 => (
        'When would support help?',
        'These are preferences. Your care team will confirm availability.',
      ),
      _ => (
        'Review your care request',
        'Sending this request does not confirm a care package.',
      ),
    };

    return PopScope(
      canPop: _step == 1,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _back();
      },
      child: CarePage(
        onBack: _back,
        children: [
          StepProgress(step: _step, total: 4),
          ScreenTitle(title: title, subtitle: subtitle),
          const SizedBox(height: 14),
          ...switch (_step) {
            1 => _person(),
            2 => _support(),
            3 => _schedule(),
            _ => _review(),
          },
          const SizedBox(height: 16),
          PrimaryButton(
            label: _step == 4 ? 'Send care request' : 'Continue',
            onPressed: _next,
          ),
          if (_step == 4) ...[
            const SizedBox(height: 10),
            const CarePreviewNotice(),
          ],
        ],
      ),
    );
  }

  List<Widget> _person() => [
    ChoiceCard(
      title: 'Myself',
      subtitle: 'I am requesting care for myself',
      selected: !_someoneElse,
      onTap: () => setState(() => _someoneElse = false),
    ),
    ChoiceCard(
      title: 'Someone else',
      subtitle: 'I am helping arrange care for another person',
      selected: _someoneElse,
      onTap: () => setState(() {
        _someoneElse = true;
        _name.clear();
      }),
    ),
    const SizedBox(height: 12),
    AppTextField(
      label: 'Care recipient’s name',
      controller: _name,
      textCapitalization: TextCapitalization.words,
      errorText: _errors['name'],
    ),
    const SizedBox(height: 12),
    AppTextField(
      label: 'Care location postcode',
      controller: _postcode,
      hintText: 'e.g. SW1A 1AA',
      textCapitalization: TextCapitalization.characters,
      errorText: _errors['postcode'],
    ),
    const SizedBox(height: 6),
    CheckRow(
      value: _permission,
      onChanged: (v) => setState(() => _permission = v),
      label: 'I have permission to share the care recipient’s information.',
    ),
    _error('permission'),
  ];

  List<Widget> _support() => [
    SelectField(
      label: 'Main type of support',
      options: [for (final s in CareService.all) s.title],
      value: _need,
      onChanged: (v) => setState(() => _need = v),
    ),
    TextAreaField(
      label: 'Tell us about the support needed',
      controller: _needs,
      hintText: 'For example, help with everyday routines and regular visits',
      errorText: _errors['needs'],
    ),
    TextAreaField(
      label: 'Access or communication preferences',
      controller: _preferences,
      hintText: 'For example, please call before visiting',
      optional: true,
      maxLines: 3,
    ),
  ];

  List<Widget> _schedule() => [
    SelectField(
      label: 'Preferred days',
      options: CareRequest.dayOptions,
      value: _days,
      onChanged: (v) => setState(() => _days = v),
    ),
    SelectField(
      label: 'Preferred time',
      options: CareRequest.timeOptions,
      value: _time,
      onChanged: (v) => setState(() => _time = v),
    ),
    SelectField(
      label: 'When would you like to start?',
      options: CareRequest.startOptions,
      value: _start,
      onChanged: (v) => setState(() => _start = v),
    ),
    const SizedBox(height: 8),
    AppTextField(
      label: 'Best contact number',
      controller: _phone,
      keyboardType: TextInputType.phone,
      errorText: _errors['phone'],
    ),
  ];

  List<Widget> _review() => [
    DetailList(
      rows: [
        ('Care for', _someoneElse ? _name.text.trim() : 'Myself'),
        ('Postcode', _postcode.text.trim().toUpperCase()),
        ('Main support', _need),
        ('Preferred days', _days),
        ('Preferred time', _time),
        ('Start', _start),
        ('Contact', _phone.text.trim()),
        ('Next step', 'Care coordinator assessment'),
      ],
    ),
    CheckRow(
      value: _contactOk,
      onChanged: (v) => setState(() => _contactOk = v),
      label:
          'I agree that the care coordination team can contact me about this '
          'request.',
    ),
    _error('contact'),
  ];
}

/// "Your care request is in" (screen pack 079).
class CareSubmittedScreen extends ConsumerWidget {
  const CareSubmittedScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final request = ref.watch(careProvider).request;
    return CarePage(
      children: [
        const SuccessIcon(),
        const ScreenTitle(
          title: 'Your care request is in',
          subtitle:
              'Your coordinator will discuss your needs, availability and next '
              'steps. No care visits or charges have been confirmed.',
        ),
        const SizedBox(height: 10),
        if (request != null)
          DetailList(
            rows: [
              ('Reference', request.reference),
              ('Status', 'Awaiting coordinator review'),
            ],
          ),
        const SizedBox(height: 4),
        const StatusBadge('Received'),
        const SizedBox(height: 16),
        PrimaryButton(
          label: 'Track your request',
          onPressed: () => context.pushReplacement(RoutePaths.careStatus),
        ),
        const SizedBox(height: 10),
        SecondaryButton(
          label: 'Back to Care',
          onPressed: () => context.goBack(fallback: RoutePaths.care),
        ),
      ],
    );
  }
}
