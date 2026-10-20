import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/route_paths.dart';
import '../../../core/theme/app_palette.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/buttons/primary_button.dart';
import '../../../core/widgets/buttons/secondary_button.dart';
import '../../../core/widgets/feedback/info_banner.dart';
import '../../../core/widgets/feedback/status_chip.dart';
import '../../../core/widgets/inputs/choice_card.dart';
import '../../../core/widgets/layout/detail_list.dart';
import '../../../core/widgets/layout/document_preview.dart';
import '../../../core/widgets/layout/screen_title.dart';
import '../../../core/widgets/lists/row_card.dart';
import '../../../core/widgets/media/lc_icons.dart';
import '../../booking/domain/models/booking_selection.dart';
import '../../payer/application/payer_controller.dart';
import '../../payer/domain/models/membership.dart';
import '../domain/insurance_models.dart';
import 'insurance_widgets.dart';

/// `•••• 3456`: enough to recognise a member number, not to read it out.
String maskedMemberId(String memberId) {
  final id = memberId.trim();
  return id.length <= 4 ? id : '•••• ${id.substring(id.length - 4)}';
}

/// Shown where a linked plan is needed and there is none.
class _NoPlan extends StatelessWidget {
  const _NoPlan({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 16),
        Center(child: LcIcon(LcIcons.shield, size: 44, color: palette.accent)),
        const SizedBox(height: 12),
        Text(
          'No policy linked yet',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: palette.ink,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          message,
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 14, height: 1.6, color: palette.inkMuted),
        ),
        const SizedBox(height: 16),
        PrimaryButton(
          label: 'Link a policy',
          onPressed: () => context.push(RoutePaths.linkHealthPlan),
        ),
      ],
    );
  }
}

/// "Your policies" (screen pack 128): the plans verified since signing in.
class InsurancePoliciesScreen extends ConsumerWidget {
  const InsurancePoliciesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final plans = ref.watch(linkedPlansProvider);
    return InsurancePage(
      children: [
        const ScreenTitle(
          title: 'Your policies',
          subtitle: 'Your linked cover in one place.',
        ),
        const SizedBox(height: 14),
        if (plans.isEmpty)
          const _NoPlan(
            message:
                'Link your health plan to see its details and what it covers.',
          )
        else ...[
          for (final plan in plans)
            RowCard(
              icon: LcIcons.shield,
              title: plan.name,
              subtitle:
                  'Membership ${maskedMemberId(plan.membership.memberId)} · '
                  'verified',
              onTap: () =>
                  context.push(RoutePaths.insurancePolicy, extra: plan),
            ),
          const SizedBox(height: 10),
          SecondaryButton(
            label: 'Link another policy',
            onPressed: () => context.push(RoutePaths.linkHealthPlan),
          ),
        ],
      ],
    );
  }
}

/// One linked plan (screen pack 129).
class InsurancePolicyScreen extends StatelessWidget {
  const InsurancePolicyScreen({super.key, required this.plan});

  final LinkedPlan plan;

  @override
  Widget build(BuildContext context) {
    final verifiedAt = plan.membership.verifiedAt;
    return InsurancePage(
      backFallback: RoutePaths.insurancePolicies,
      children: [
        ScreenTitle(title: plan.name, subtitle: 'Linked health plan'),
        const SizedBox(height: 12),
        const StatusBadge('Verified'),
        DetailList(
          rows: [
            ('Insurer', plan.name),
            ('Membership', maskedMemberId(plan.membership.memberId)),
            if (plan.membership.planId != null)
              ('Plan', plan.membership.planId!),
            if (verifiedAt != null) ('Verified', Formatters.date(verifiedAt)),
          ],
        ),
        const PanelCard(
          title: 'Understanding your cover',
          body:
              'Benefits, exclusions, excesses, limits and authorisation rules '
              'come from your insurer. Check a service before you book.',
        ),
        RowCard(
          icon: LcIcons.check,
          title: 'What it covers',
          subtitle: 'Check each service with your insurer',
          tone: RowCardTone.mint,
          onTap: () => context.push(RoutePaths.payerCoverage, extra: plan),
        ),
        RowCard(
          icon: LcIcons.file,
          title: 'Policy documents',
          subtitle: 'Schedule, wording and key information',
          onTap: () => context.push(RoutePaths.insuranceDocuments, extra: plan),
        ),
        RowCard(
          icon: LcIcons.message,
          title: 'Contact insurance support',
          subtitle: 'Ask about this policy or a claim',
          onTap: () => context.push(RoutePaths.insuranceSupport),
        ),
        const SizedBox(height: 10),
        PrimaryButton(
          label: 'Book covered care',
          onPressed: () => context.push(
            RoutePaths.bookingChooseService,
            extra: BookingStart.hmo(plan),
          ),
        ),
      ],
    );
  }
}

/// "Your policy documents" (screen pack 130). The insurer's documents are
/// not in the app yet, so each row explains what that document holds.
class InsuranceDocumentsScreen extends StatelessWidget {
  const InsuranceDocumentsScreen({super.key, required this.plan});

  final LinkedPlan plan;

  @override
  Widget build(BuildContext context) {
    return InsurancePage(
      backFallback: RoutePaths.insurancePolicies,
      children: [
        ScreenTitle(
          title: 'Your policy documents',
          subtitle:
              '${plan.name} · '
              '${maskedMemberId(plan.membership.memberId)}',
        ),
        const SizedBox(height: 14),
        for (final document in InsuranceDocument.all)
          RowCard(
            icon: LcIcons.file,
            title: document.title,
            subtitle: document.summary,
            onTap: () =>
                context.push(RoutePaths.insuranceDocument, extra: document),
          ),
        const SizedBox(height: 10),
        InfoBanner(
          message:
              'Your documents come from ${plan.name}. They are not available '
              'in the app yet; ask your insurer for a copy.',
        ),
      ],
    );
  }
}

/// One document, explained (screen pack 131-133).
class InsuranceDocumentScreen extends StatelessWidget {
  const InsuranceDocumentScreen({super.key, required this.document});

  final InsuranceDocument document;

  @override
  Widget build(BuildContext context) {
    return InsurancePage(
      backFallback: RoutePaths.insurancePolicies,
      children: [
        ScreenTitle(title: document.title, subtitle: document.summary),
        DocumentPreview(
          title: 'What this document contains',
          body: document.explanation,
        ),
        SecondaryButton(
          label: 'Ask insurance support',
          onPressed: () => context.push(RoutePaths.insuranceSupport),
        ),
      ],
    );
  }
}

/// "Check your service cover" (screen pack 134-135). The answer is your
/// insurer's real one, from the plan's coverage check.
class InsuranceCoverScreen extends ConsumerStatefulWidget {
  const InsuranceCoverScreen({super.key});

  @override
  ConsumerState<InsuranceCoverScreen> createState() =>
      _InsuranceCoverScreenState();
}

class _InsuranceCoverScreenState extends ConsumerState<InsuranceCoverScreen> {
  String? _planId;

  @override
  Widget build(BuildContext context) {
    final plans = ref.watch(linkedPlansProvider);
    final chosen = plans
        .where(
          (p) =>
              p.membership.id == (_planId ?? plans.firstOrNull?.membership.id),
        )
        .firstOrNull;
    return InsurancePage(
      children: [
        const ScreenTitle(
          title: 'Check your service cover',
          subtitle: 'See what your insurer says before you book.',
        ),
        const SizedBox(height: 14),
        if (plans.isEmpty)
          const _NoPlan(
            message:
                'Link your health plan first, then check which services it '
                'covers.',
          )
        else ...[
          for (final plan in plans)
            ChoiceCard(
              title: plan.name,
              subtitle:
                  'Membership ${maskedMemberId(plan.membership.memberId)}',
              selected: plan == chosen,
              onTap: () => setState(() => _planId = plan.membership.id),
            ),
          const SizedBox(height: 8),
          const InfoBanner(
            message:
                'Your insurer answers for each service: covered, co-pay, needs '
                'authorisation, or not covered.',
          ),
          const SizedBox(height: 16),
          PrimaryButton(
            label: 'Check cover',
            onPressed: chosen == null
                ? null
                : () => context.push(RoutePaths.payerCoverage, extra: chosen),
          ),
        ],
      ],
    );
  }
}
