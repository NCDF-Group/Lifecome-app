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
import '../../../core/widgets/layout/screen_title.dart';
import '../../../core/widgets/lists/row_card.dart';
import '../../../core/widgets/lists/timeline_item.dart';
import '../../../core/widgets/media/lc_icons.dart';
import '../application/care_controller.dart';
import 'care_widgets.dart';

/// Shown on journey screens before any care has been requested.
class _NoRequest extends StatelessWidget {
  const _NoRequest();

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 16),
        Center(child: LcIcon(LcIcons.care, size: 44, color: palette.accent)),
        const SizedBox(height: 12),
        Text(
          'No care requested yet',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: palette.ink,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Start with a care request and your coordinator will take it from '
          'there.',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 14, height: 1.6, color: palette.inkMuted),
        ),
        const SizedBox(height: 16),
        PrimaryButton(
          label: 'Request care',
          onPressed: () => context.push(RoutePaths.careRequest),
        ),
      ],
    );
  }
}

void _messageCoordinator(BuildContext context) =>
    context.push(RoutePaths.newMessage);

/// "Your care request" — status timeline (screen pack 080).
class CareStatusScreen extends ConsumerWidget {
  const CareStatusScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final care = ref.watch(careProvider);
    final request = care.request;
    return CarePage(
      children: [
        ScreenTitle(
          title: 'Your care request',
          subtitle: request == null ? null : 'Reference ${request.reference}',
        ),
        if (request == null)
          const _NoRequest()
        else ...[
          const SizedBox(height: 12),
          StatusBadge(
            care.accepted ? 'Care plan agreed' : 'Assessment requested',
            tone: BadgeTone.blue,
          ),
          StepTimeline(
            active: care.accepted ? 3 : 1,
            items: const [
              (
                'Request received',
                'Your needs and preferences have been shared.',
              ),
              ('Assessment', 'Meet your coordinator to discuss support.'),
              ('Care proposal', 'Review the plan, schedule and costs.'),
              ('Care begins', 'Visits start after arrangements are agreed.'),
            ],
          ),
          RowCard(
            icon: LcIcons.calendar,
            title: 'Assessment details',
            subtitle: 'Your call with the care coordinator',
            onTap: () => context.push(RoutePaths.careAssessment),
          ),
          RowCard(
            icon: LcIcons.file,
            title: care.accepted
                ? 'Your care proposal'
                : 'Preview your care proposal',
            subtitle: 'The proposed support, schedule and costs',
            tone: RowCardTone.mint,
            onTap: () => context.push(RoutePaths.careProposal),
          ),
          const SizedBox(height: 10),
          SecondaryButton(
            label: 'Message your coordinator',
            onPressed: () => _messageCoordinator(context),
          ),
        ],
        const SizedBox(height: 12),
        const CarePreviewNotice(),
      ],
    );
  }
}

/// "Your care assessment" (screen pack 081).
class CareAssessmentScreen extends ConsumerWidget {
  const CareAssessmentScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final care = ref.watch(careProvider);
    final at = care.assessmentAt;
    return CarePage(
      backFallback: RoutePaths.careStatus,
      children: [
        const ScreenTitle(
          title: 'Your care assessment',
          subtitle: 'A conversation about your needs and preferences.',
        ),
        if (care.request == null || at == null)
          const _NoRequest()
        else ...[
          const SizedBox(height: 10),
          DetailList(
            rows: [
              ('Coordinator', 'Sam Morgan (example)'),
              ('Date', Formatters.longDate(at)),
              ('Time', '${Formatters.time(at)} · UK time'),
              ('Format', 'Telephone assessment'),
              ('We will call', care.request!.phone),
            ],
          ),
          const CheckList(
            items: [
              'Think about everyday routines',
              'Include the people you want involved',
              'Bring questions about care and costs',
            ],
          ),
          PrimaryButton(
            label: 'Discuss or change the assessment',
            onPressed: () => _messageCoordinator(context),
          ),
          const SizedBox(height: 10),
          SecondaryButton(
            label: 'Preview care proposal',
            onPressed: () => context.push(RoutePaths.careProposal),
          ),
        ],
      ],
    );
  }
}

/// "Your proposed care" (screen pack 082), with illustrative costs.
class CareProposalScreen extends ConsumerWidget {
  const CareProposalScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final care = ref.watch(careProvider);
    final request = care.request;
    return CarePage(
      backFallback: RoutePaths.careStatus,
      children: [
        const ScreenTitle(
          title: 'Your proposed care',
          subtitle: 'Review the support, schedule and costs.',
        ),
        if (request == null)
          const _NoRequest()
        else ...[
          const SizedBox(height: 12),
          care.accepted
              ? const StatusBadge('Accepted')
              : const StatusBadge('For review', tone: BadgeTone.amber),
          const SizedBox(height: 6),
          DetailList(
            rows: [
              ('Care service', request.need),
              ('Visits', '${care.visitsPerWeek} visits per week'),
              ('Duration', '${CareState.hoursPerVisit} hours per visit'),
              (
                'Example rate',
                '${Formatters.money(CareState.hourlyRatePence)} per hour',
              ),
              ('Example weekly total', Formatters.money(care.weeklyTotalPence)),
              ('Proposed start', Formatters.longDate(care.startsOn!)),
            ],
          ),
          const SizedBox(height: 8),
          const InfoBanner(
            tone: BannerTone.warning,
            message:
                'Costs and availability are examples. The care provider will '
                'confirm the agreed package and terms before anything starts.',
          ),
          const SizedBox(height: 16),
          if (!care.accepted)
            PrimaryButton(
              label: 'Review care agreement',
              onPressed: () => context.push(RoutePaths.careAgreement),
            )
          else
            PrimaryButton(
              label: 'View your care plan',
              onPressed: () => context.push(RoutePaths.carePlan),
            ),
          const SizedBox(height: 10),
          SecondaryButton(
            label: 'Ask for a change',
            onPressed: () => context.push(RoutePaths.careChange),
          ),
        ],
      ],
    );
  }
}

/// "Agree your care plan" (screen pack 083): explicit acceptance.
class CareAgreementScreen extends ConsumerStatefulWidget {
  const CareAgreementScreen({super.key});

  @override
  ConsumerState<CareAgreementScreen> createState() =>
      _CareAgreementScreenState();
}

class _CareAgreementScreenState extends ConsumerState<CareAgreementScreen> {
  bool _agreed = false;
  bool _showError = false;

  @override
  Widget build(BuildContext context) {
    final care = ref.watch(careProvider);
    return CarePage(
      backFallback: RoutePaths.careProposal,
      children: [
        const ScreenTitle(
          title: 'Agree your care plan',
          subtitle: 'Please review the arrangement before accepting.',
        ),
        if (care.request == null)
          const _NoRequest()
        else ...[
          const SizedBox(height: 10),
          PanelCard(
            title: 'Your agreement',
            body:
                '${care.visitsPerWeek} visits each week, '
                '${CareState.hoursPerVisit} hours per visit, with an example '
                'weekly cost of ${Formatters.money(care.weeklyTotalPence)}. '
                'The provider’s agreement will include their details, '
                'responsibilities, cancellation terms and review dates.',
          ),
          CheckRow(
            value: _agreed,
            onChanged: (v) => setState(() {
              _agreed = v;
              if (v) _showError = false;
            }),
            label:
                'I have reviewed this care proposal and understand it is a '
                'preview: accepting does not create a care contract.',
          ),
          if (_showError)
            Padding(
              padding: const EdgeInsets.only(left: 30),
              child: Text(
                'Please confirm to continue.',
                style: TextStyle(fontSize: 12.5, color: context.palette.danger),
              ),
            ),
          const SizedBox(height: 16),
          PrimaryButton(
            label: 'Accept care plan',
            onPressed: () {
              if (!_agreed) {
                setState(() => _showError = true);
                return;
              }
              ref.read(careProvider.notifier).accept();
              context.pushReplacement(RoutePaths.carePlan);
            },
          ),
        ],
      ],
    );
  }
}

/// "Your care plan" (screen pack 084).
class CarePlanDetailScreen extends ConsumerWidget {
  const CarePlanDetailScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final care = ref.watch(careProvider);
    final request = care.request;
    return CarePage(
      children: [
        const ScreenTitle(
          title: 'Your care plan',
          subtitle: 'Support designed around your preferences.',
        ),
        if (request == null)
          const _NoRequest()
        else ...[
          const SizedBox(height: 12),
          care.accepted
              ? const StatusBadge('Agreed', tone: BadgeTone.blue)
              : const StatusBadge('Not agreed yet', tone: BadgeTone.amber),
          const SizedBox(height: 6),
          DetailList(
            rows: [
              (
                'Recipient',
                request.forSomeoneElse ? request.recipientName : 'You',
              ),
              ('Support', request.need),
              ('Schedule', request.days),
              ('Visit time', '${request.visitTime} · UK time'),
              ('Coordinator', 'Sam Morgan (example)'),
            ],
          ),
          PanelCard(
            title: 'What matters to you',
            body: request.preferences ?? request.needsDetail,
            tone: PanelTone.mint,
          ),
          if (!care.accepted) ...[
            PrimaryButton(
              label: 'Review your proposal',
              onPressed: () => context.push(RoutePaths.careProposal),
            ),
            const SizedBox(height: 6),
          ],
          RowCard(
            icon: LcIcons.calendar,
            title: 'View care visits',
            subtitle: 'Upcoming visits and completed notes',
            onTap: () => context.push(RoutePaths.careVisits),
          ),
          RowCard(
            icon: LcIcons.people,
            title: 'Your care team',
            subtitle: 'Meet your coordinator and carers',
            tone: RowCardTone.mint,
            onTap: () => context.push(RoutePaths.careTeam),
          ),
          const SizedBox(height: 10),
          SecondaryButton(
            label: 'Request a change',
            onPressed: () => context.push(RoutePaths.careChange),
          ),
        ],
        const SizedBox(height: 12),
        const CarePreviewNotice(),
      ],
    );
  }
}
