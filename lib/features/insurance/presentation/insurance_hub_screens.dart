import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/route_paths.dart';
import '../../../core/router/safe_back.dart';
import '../../../core/utils/validators.dart';
import '../../../core/widgets/buttons/primary_button.dart';
import '../../../core/widgets/buttons/secondary_button.dart';
import '../../../core/widgets/feedback/info_banner.dart';
import '../../../core/widgets/feedback/status_chip.dart';
import '../../../core/widgets/inputs/app_text_field.dart';
import '../../../core/widgets/inputs/choice_card.dart';
import '../../../core/widgets/inputs/form_fields.dart';
import '../../../core/widgets/layout/detail_list.dart';
import '../../../core/widgets/layout/screen_title.dart';
import '../../../core/widgets/layout/section_header.dart';
import '../../../core/widgets/layout/step_progress.dart';
import '../../../core/widgets/lists/row_card.dart';
import '../../../core/widgets/lists/timeline_item.dart';
import '../../../core/widgets/media/lc_icons.dart';
import '../../payer/application/payer_controller.dart';
import '../../profile/application/profile_controller.dart';
import '../application/insurance_controller.dart';
import '../domain/insurance_models.dart';
import 'insurance_widgets.dart';

/// "Cover with clarity" — the Insurance hub (screen pack 117).
class InsuranceHubScreen extends ConsumerWidget {
  const InsuranceHubScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final plans = ref.watch(linkedPlansProvider);
    return InsurancePage(
      backFallback: RoutePaths.home,
      children: [
        const ScreenTitle(
          eyebrow: 'Insurance',
          title: 'Cover with clarity',
          subtitle: 'Understand your options and manage your policies.',
        ),
        const SizedBox(height: 14),
        RowCard(
          icon: LcIcons.shield,
          title: 'Explore insurance',
          subtitle: 'The kinds of cover available',
          onTap: () => context.push(RoutePaths.insuranceProducts),
        ),
        RowCard(
          icon: LcIcons.plus,
          title: 'Link an existing policy',
          subtitle: plans.isEmpty
              ? 'Connect your health plan to your account'
              : '${plans.length} linked · link another',
          tone: RowCardTone.mint,
          onTap: () => context.push(RoutePaths.linkHealthPlan),
        ),
        const SectionHeader(title: 'Your insurance'),
        RowCard(
          icon: LcIcons.file,
          title: 'My policies',
          subtitle: 'Policy details and documents',
          onTap: () => context.push(RoutePaths.insurancePolicies),
        ),
        RowCard(
          icon: LcIcons.check,
          title: 'Check service cover',
          subtitle: 'See what your plan covers before booking',
          onTap: () => context.push(RoutePaths.insuranceCover),
        ),
        RowCard(
          icon: LcIcons.clock,
          title: 'Claims & support',
          subtitle: 'Follow a claim or contact your provider',
          tone: RowCardTone.mint,
          onTap: () => context.push(RoutePaths.insuranceClaims),
        ),
        const SizedBox(height: 10),
        const InfoBanner(
          message:
              'Cover and claims depend on your policy terms and your insurer. '
              'Linking a policy does not guarantee cover.',
        ),
        const SizedBox(height: 10),
        const InsurancePreviewNotice(),
      ],
    );
  }
}

/// "Explore your cover options" (screen pack 118).
class InsuranceProductsScreen extends StatelessWidget {
  const InsuranceProductsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return InsurancePage(
      children: [
        const ScreenTitle(
          title: 'Explore your cover options',
          subtitle: 'Find out more, then talk to a provider.',
        ),
        const SizedBox(height: 14),
        for (final (i, category) in InsuranceCategory.all.indexed)
          RowCard(
            icon: category.icon,
            title: category.title,
            subtitle: category.summary,
            tone: i.isEven ? RowCardTone.blue : RowCardTone.mint,
            onTap: () =>
                context.push(RoutePaths.insuranceProduct, extra: category),
          ),
        const SizedBox(height: 10),
        const InfoBanner(
          message:
              'LifeCome does not sell or recommend insurance. Products, '
              'prices and eligibility come from authorised providers.',
        ),
      ],
    );
  }
}

/// One kind of cover (screen pack 119-121).
class InsuranceProductScreen extends StatelessWidget {
  const InsuranceProductScreen({super.key, required this.category});

  final InsuranceCategory category;

  @override
  Widget build(BuildContext context) {
    return InsurancePage(
      backFallback: RoutePaths.insuranceProducts,
      children: [
        ScreenTitle(
          eyebrow: 'Insurance',
          title: category.title,
          subtitle: category.description,
        ),
        const SectionHeader(title: 'What the provider explains'),
        CheckList(items: category.explains),
        const SizedBox(height: 10),
        PrimaryButton(
          label: 'Start an enquiry',
          onPressed: () =>
              context.push(RoutePaths.insuranceEnquiry, extra: category),
        ),
        const SizedBox(height: 10),
        SecondaryButton(
          label: 'Link a policy you already have',
          onPressed: () => context.push(RoutePaths.linkHealthPlan),
        ),
      ],
    );
  }
}

/// The provider enquiry (screen pack 122-124) in three steps on one screen:
/// details, review with consent, then the provider handoff.
class InsuranceEnquiryScreen extends ConsumerStatefulWidget {
  const InsuranceEnquiryScreen({super.key, required this.category});

  final InsuranceCategory category;

  @override
  ConsumerState<InsuranceEnquiryScreen> createState() =>
      _InsuranceEnquiryScreenState();
}

class _InsuranceEnquiryScreenState
    extends ConsumerState<InsuranceEnquiryScreen> {
  int _step = 1;
  late InsuranceCategory _category = widget.category;
  String _forWhom = 'Myself';
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _phone = TextEditingController();
  final _errors = <String, String?>{};
  bool _consent = false;
  bool _showConsentError = false;

  @override
  void initState() {
    super.initState();
    ref.listenManual(meProvider, (_, next) {
      final me = next.value;
      if (me == null) return;
      if (_name.text.isEmpty) _name.text = me.displayName ?? '';
      if (_email.text.isEmpty) _email.text = me.account.email;
      if (_phone.text.isEmpty) _phone.text = me.account.phoneNumber ?? '';
    }, fireImmediately: true);
  }

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _phone.dispose();
    super.dispose();
  }

  void _back() {
    if (_step > 1) {
      setState(() => _step--);
    } else {
      context.goBack(fallback: RoutePaths.insuranceProducts);
    }
  }

  void _next() {
    switch (_step) {
      case 1:
        setState(() {
          _errors['name'] = Validators.text(
            _name.text,
            label: 'your name',
            required: true,
            minLength: 2,
          );
          _errors['email'] = Validators.email(_email.text);
          _errors['phone'] = Validators.ukPhone(_phone.text, required: true);
        });
        if (_errors.values.every((e) => e == null)) setState(() => _step = 2);
      case 2:
        setState(() => _showConsentError = !_consent);
        if (_consent) setState(() => _step = 3);
      default:
        final enquiry = ref
            .read(insuranceProvider.notifier)
            .enquire(
              category: _category,
              forWhom: _forWhom,
              name: _name.text.trim(),
              email: _email.text.trim(),
              phone: _phone.text.trim(),
            );
        context.pushReplacement(
          RoutePaths.insuranceEnquirySent,
          extra: enquiry,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final (title, subtitle) = switch (_step) {
      1 => ('Explore your options', 'Tell us how a provider can reach you.'),
      2 => (
        'Review your enquiry',
        'The provider will explain available products and next steps.',
      ),
      _ => (
        'Your provider journey',
        'The provider handles any quotation and purchase.',
      ),
    };

    return PopScope(
      canPop: _step == 1,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _back();
      },
      child: InsurancePage(
        onBack: _back,
        backFallback: RoutePaths.insuranceProducts,
        children: [
          StepProgress(step: _step, total: 3),
          ScreenTitle(title: title, subtitle: subtitle),
          const SizedBox(height: 12),
          ...switch (_step) {
            1 => [
              SelectField(
                label: 'Product interest',
                options: [for (final c in InsuranceCategory.all) c.title],
                value: _category.title,
                onChanged: (v) => setState(
                  () => _category = InsuranceCategory.all.firstWhere(
                    (c) => c.title == v,
                  ),
                ),
              ),
              SelectField(
                label: 'Who is the enquiry for?',
                options: const ['Myself', 'My family'],
                value: _forWhom,
                onChanged: (v) => setState(() => _forWhom = v),
              ),
              const SizedBox(height: 8),
              AppTextField(
                label: 'Name',
                controller: _name,
                errorText: _errors['name'],
              ),
              const SizedBox(height: 12),
              AppTextField(
                label: 'Email',
                controller: _email,
                keyboardType: TextInputType.emailAddress,
                errorText: _errors['email'],
              ),
              const SizedBox(height: 12),
              AppTextField(
                label: 'Contact number',
                controller: _phone,
                keyboardType: TextInputType.phone,
                errorText: _errors['phone'],
              ),
            ],
            2 => [
              DetailList(
                rows: [
                  ('Interest', _category.title),
                  ('For', _forWhom),
                  ('Name', _name.text.trim()),
                  ('Email', _email.text.trim()),
                  ('Receiving provider', 'An authorised insurance provider'),
                ],
              ),
              CheckRow(
                value: _consent,
                onChanged: (v) => setState(() {
                  _consent = v;
                  if (v) _showConsentError = false;
                }),
                label:
                    'I agree to share these details with an insurance provider '
                    'so they can contact me.',
              ),
              ConfirmError(show: _showConsentError),
              const SizedBox(height: 8),
              const InfoBanner(
                message:
                    'This is an enquiry, not a quotation, a recommendation or '
                    'a purchase.',
              ),
            ],
            _ => [
              const PanelCard(
                title: 'What the provider does',
                body:
                    'The provider confirms eligibility, explains cover and '
                    'exclusions, presents pricing and asks for any '
                    'declarations they need.',
                tone: PanelTone.blue,
              ),
              const InsurancePreviewNotice(
                message:
                    'In preview, your enquiry stays in this app. No provider '
                    'receives your details.',
              ),
            ],
          },
          const SizedBox(height: 16),
          PrimaryButton(
            label: switch (_step) {
              1 => 'Continue',
              2 => 'Continue to provider step',
              _ => 'Finish enquiry',
            },
            onPressed: _next,
          ),
        ],
      ),
    );
  }
}

/// "Your enquiry journey is complete" (screen pack 125): no policy issued.
class InsuranceEnquirySentScreen extends StatelessWidget {
  const InsuranceEnquirySentScreen({super.key, required this.enquiry});

  final InsuranceEnquiry enquiry;

  @override
  Widget build(BuildContext context) {
    return InsurancePage(
      children: [
        const SuccessIcon(),
        ScreenTitle(
          title: 'Your enquiry is recorded',
          subtitle:
              'Reference ${enquiry.reference}. No quotation or policy has been '
              'issued.',
        ),
        const SizedBox(height: 12),
        const StatusBadge('Preview', tone: BadgeTone.amber),
        const SizedBox(height: 16),
        PrimaryButton(
          label: 'Return to Insurance',
          onPressed: () => context.goBack(fallback: RoutePaths.insurance),
        ),
        const SizedBox(height: 10),
        SecondaryButton(
          label: 'Link a policy you already have',
          onPressed: () => context.push(RoutePaths.linkHealthPlan),
        ),
      ],
    );
  }
}
