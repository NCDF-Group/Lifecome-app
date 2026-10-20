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
import '../../../core/widgets/feedback/info_banner.dart';
import '../../../core/widgets/feedback/status_chip.dart';
import '../../../core/widgets/inputs/app_text_field.dart';
import '../../../core/widgets/inputs/choice_card.dart';
import '../../../core/widgets/inputs/form_fields.dart';
import '../../../core/widgets/layout/detail_list.dart';
import '../../../core/widgets/layout/screen_title.dart';
import '../../../core/widgets/lists/row_card.dart';
import '../../../core/widgets/lists/timeline_item.dart';
import '../../../core/widgets/media/lc_icons.dart';
import '../../payer/application/payer_controller.dart';
import '../application/insurance_controller.dart';
import '../domain/insurance_models.dart';
import 'insurance_policy_screens.dart';
import 'insurance_widgets.dart';

/// "Claims & support" (screen pack 136).
class InsuranceClaimsScreen extends ConsumerWidget {
  const InsuranceClaimsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final palette = context.palette;
    final claims = ref.watch(insuranceProvider).claims;
    return InsurancePage(
      children: [
        const ScreenTitle(
          title: 'Claims & support',
          subtitle: 'Keep track of the next step with your insurer.',
        ),
        const SizedBox(height: 14),
        if (claims.isEmpty)
          Container(
            padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
            decoration: BoxDecoration(
              color: palette.surface,
              border: Border.all(color: palette.line),
              borderRadius: BorderRadius.circular(17),
            ),
            child: Text(
              'You have no claim enquiries.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: palette.inkMuted),
            ),
          )
        else
          for (final claim in claims)
            RowCard(
              icon: LcIcons.file,
              title: 'Claim enquiry ${claim.reference}',
              subtitle: '${claim.type} · ${Formatters.date(claim.createdAt)}',
              onTap: () =>
                  context.push(RoutePaths.insuranceClaim, extra: claim),
            ),
        const SizedBox(height: 10),
        PrimaryButton(
          label: 'Start a claim enquiry',
          onPressed: () => context.push(RoutePaths.insuranceClaimStart),
        ),
        const SizedBox(height: 4),
        RowCard(
          icon: LcIcons.message,
          title: 'Insurance support',
          subtitle: 'Questions, changes or complaints',
          tone: RowCardTone.mint,
          onTap: () => context.push(RoutePaths.insuranceSupport),
        ),
        const SizedBox(height: 8),
        const InfoBanner(
          message:
              'Claims are assessed and decided by your insurer or their '
              'claims administrator.',
        ),
        const SizedBox(height: 10),
        const InsurancePreviewNotice(),
      ],
    );
  }
}

/// "Start a claim enquiry" (screen pack 137).
class InsuranceClaimStartScreen extends ConsumerStatefulWidget {
  const InsuranceClaimStartScreen({super.key});

  @override
  ConsumerState<InsuranceClaimStartScreen> createState() =>
      _InsuranceClaimStartScreenState();
}

class _InsuranceClaimStartScreenState
    extends ConsumerState<InsuranceClaimStartScreen> {
  static const _noPlan = 'My policy is not linked yet';
  String? _policy;
  String _type = ClaimEnquiry.types.first;
  final _detail = TextEditingController();
  String? _error;
  bool _understood = false;
  bool _showError = false;

  @override
  void dispose() {
    _detail.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final plans = ref.watch(linkedPlansProvider);
    final policies = [
      for (final p in plans)
        '${p.name} · ${maskedMemberId(p.membership.memberId)}',
      _noPlan,
    ];
    final policy = _policy ?? policies.first;
    return InsurancePage(
      backFallback: RoutePaths.insuranceClaims,
      children: [
        const ScreenTitle(
          title: 'Start a claim enquiry',
          subtitle:
              'Your insurer will confirm the claim process and the evidence '
              'they need.',
        ),
        const SizedBox(height: 10),
        SelectField(
          label: 'Policy',
          options: policies,
          value: policy,
          onChanged: (v) => setState(() => _policy = v),
        ),
        SelectField(
          label: 'Service or event',
          options: ClaimEnquiry.types,
          value: _type,
          onChanged: (v) => setState(() => _type = v),
        ),
        TextAreaField(
          label: 'Tell us about your enquiry',
          controller: _detail,
          hintText: 'What happened, and what you would like help with',
          errorText: _error,
        ),
        CheckRow(
          value: _understood,
          onChanged: (v) => setState(() {
            _understood = v;
            if (v) _showError = false;
          }),
          label:
              'I understand this is an enquiry, and that my insurer decides '
              'any claim.',
        ),
        ConfirmError(show: _showError),
        const SizedBox(height: 16),
        PrimaryButton(
          label: 'Send claim enquiry',
          onPressed: () {
            final error = Validators.text(
              _detail.text,
              label: 'your enquiry',
              required: true,
              minLength: 10,
            );
            setState(() {
              _error = error;
              _showError = !_understood;
            });
            if (error != null || !_understood) return;
            final claim = ref
                .read(insuranceProvider.notifier)
                .startClaim(
                  policy: policy,
                  type: _type,
                  detail: _detail.text.trim(),
                );
            context.pushReplacement(
              RoutePaths.insuranceClaimSent,
              extra: claim,
            );
          },
        ),
        const SizedBox(height: 12),
        const InsurancePreviewNotice(),
      ],
    );
  }
}

/// "Your claim enquiry is recorded" (screen pack 138).
class InsuranceClaimSentScreen extends StatelessWidget {
  const InsuranceClaimSentScreen({super.key, required this.claim});

  final ClaimEnquiry claim;

  @override
  Widget build(BuildContext context) {
    return InsurancePage(
      backFallback: RoutePaths.insuranceClaims,
      children: [
        const SuccessIcon(),
        ScreenTitle(
          title: 'Your claim enquiry is recorded',
          subtitle:
              'Reference ${claim.reference}. Your insurer confirms receipt and '
              'the next step.',
        ),
        const SizedBox(height: 16),
        PrimaryButton(
          label: 'View claims & support',
          onPressed: () => context.goBack(fallback: RoutePaths.insuranceClaims),
        ),
      ],
    );
  }
}

/// One claim enquiry (screen pack 139).
class InsuranceClaimScreen extends StatelessWidget {
  const InsuranceClaimScreen({super.key, required this.claim});

  final ClaimEnquiry claim;

  @override
  Widget build(BuildContext context) {
    return InsurancePage(
      backFallback: RoutePaths.insuranceClaims,
      children: [
        ScreenTitle(
          title: 'Claim enquiry ${claim.reference}',
          subtitle: claim.policy,
        ),
        const SizedBox(height: 12),
        const StatusBadge('Enquiry recorded', tone: BadgeTone.amber),
        const StepTimeline(
          active: 0,
          items: [
            ('Enquiry recorded', 'Your details are ready for your insurer.'),
            (
              'Information requested',
              'Your insurer may ask for supporting documents.',
            ),
            ('Assessment', 'Your insurer reviews the claim.'),
            ('Decision', 'Your insurer explains the outcome.'),
          ],
        ),
        DetailList(
          rows: [
            ('Service or event', claim.type),
            ('Sent', Formatters.date(claim.createdAt)),
          ],
        ),
        PanelCard(title: 'Your enquiry', body: claim.detail),
        const InfoBanner(
          message: 'LifeCome does not make claim decisions or payments.',
        ),
        const SizedBox(height: 16),
        SecondaryButton(
          label: 'Contact claims support',
          onPressed: () => context.push(RoutePaths.insuranceSupport),
        ),
      ],
    );
  }
}

/// "Insurance support" (screen pack 140).
class InsuranceSupportScreen extends ConsumerStatefulWidget {
  const InsuranceSupportScreen({super.key});

  @override
  ConsumerState<InsuranceSupportScreen> createState() =>
      _InsuranceSupportScreenState();
}

class _InsuranceSupportScreenState
    extends ConsumerState<InsuranceSupportScreen> {
  String _topic = InsuranceSupportEnquiry.topics.first;
  final _reference = TextEditingController();
  final _message = TextEditingController();
  String? _error;

  @override
  void dispose() {
    _reference.dispose();
    _message.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return InsurancePage(
      children: [
        const ScreenTitle(
          title: 'Insurance support',
          subtitle: 'Tell us which part of your insurance needs attention.',
        ),
        const SizedBox(height: 10),
        SelectField(
          label: 'Topic',
          options: InsuranceSupportEnquiry.topics,
          value: _topic,
          onChanged: (v) => setState(() => _topic = v),
        ),
        const SizedBox(height: 8),
        AppTextField(
          label: 'Policy or claim reference (optional)',
          controller: _reference,
        ),
        TextAreaField(
          label: 'Your question',
          controller: _message,
          errorText: _error,
        ),
        const SizedBox(height: 16),
        PrimaryButton(
          label: 'Send enquiry',
          onPressed: () {
            final error = Validators.text(
              _message.text,
              label: 'your question',
              required: true,
              minLength: 10,
            );
            setState(() => _error = error);
            if (error != null) return;
            final reference = _reference.text.trim();
            final enquiry = ref
                .read(insuranceProvider.notifier)
                .askSupport(
                  topic: _topic,
                  message: _message.text.trim(),
                  policyReference: reference.isEmpty ? null : reference,
                );
            context.pushReplacement(
              RoutePaths.insuranceSupportSent,
              extra: enquiry,
            );
          },
        ),
        const SizedBox(height: 12),
        const InsurancePreviewNotice(),
      ],
    );
  }
}

/// "Your enquiry is recorded" (screen pack 141).
class InsuranceSupportSentScreen extends StatelessWidget {
  const InsuranceSupportSentScreen({super.key, required this.enquiry});

  final InsuranceSupportEnquiry enquiry;

  @override
  Widget build(BuildContext context) {
    return InsurancePage(
      children: [
        const SuccessIcon(),
        ScreenTitle(
          title: 'Your enquiry is recorded',
          subtitle:
              'Reference ${enquiry.reference}. The insurance support team '
              'responds through your insurer’s usual channel.',
        ),
        const SizedBox(height: 16),
        PrimaryButton(
          label: 'Return to Insurance',
          onPressed: () => context.goBack(fallback: RoutePaths.insurance),
        ),
      ],
    );
  }
}
