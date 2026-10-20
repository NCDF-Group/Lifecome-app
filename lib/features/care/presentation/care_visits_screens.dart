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
import '../../../core/widgets/inputs/form_fields.dart';
import '../../../core/widgets/layout/detail_list.dart';
import '../../../core/widgets/layout/document_preview.dart';
import '../../../core/widgets/layout/screen_title.dart';
import '../../../core/widgets/lists/row_card.dart';
import '../../../core/widgets/media/avatar.dart';
import '../../../core/widgets/media/lc_icons.dart';
import '../application/care_controller.dart';
import '../domain/care_models.dart';
import 'care_widgets.dart';

const _carer = 'Taylor Brooks';
const _coordinator = 'Sam Morgan';

/// "Your care visits" (screen pack 085).
class CareVisitsScreen extends ConsumerWidget {
  const CareVisitsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final care = ref.watch(careProvider);
    final visits = care.upcomingVisits();
    final palette = context.palette;

    return CarePage(
      children: [
        const ScreenTitle(
          title: 'Your care visits',
          subtitle: 'A clear view of who is coming and when.',
        ),
        const SizedBox(height: 14),
        if (visits.isEmpty)
          Container(
            padding: const EdgeInsets.symmetric(vertical: 26, horizontal: 16),
            decoration: BoxDecoration(
              color: palette.surface,
              border: Border.all(color: palette.line),
              borderRadius: BorderRadius.circular(17),
            ),
            child: Column(
              children: [
                LcIcon(LcIcons.calendar, size: 36, color: palette.accent),
                const SizedBox(height: 10),
                Text(
                  care.request == null
                      ? 'Visits appear here once your care is arranged.'
                      : 'Visits appear here once you accept your care plan.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    height: 1.5,
                    color: palette.inkMuted,
                  ),
                ),
              ],
            ),
          )
        else ...[
          for (final visit in visits)
            RowCard(
              icon: LcIcons.calendar,
              title: Formatters.longDate(visit.date),
              subtitle: '${visit.time} · $_carer',
              onTap: () => context.push(RoutePaths.careVisit, extra: visit),
            ),
          RowCard(
            icon: LcIcons.file,
            title: 'Your first visit note',
            subtitle: 'Notes appear after each completed visit',
            tone: RowCardTone.white,
            onTap: () => context.push(RoutePaths.careVisitNote),
          ),
        ],
        const SizedBox(height: 10),
        SecondaryButton(
          label: 'Request a schedule change',
          onPressed: () => context.push(RoutePaths.careChange),
        ),
        const SizedBox(height: 12),
        const CarePreviewNotice(),
      ],
    );
  }
}

/// One upcoming visit (screen pack 086).
class CareVisitScreen extends ConsumerWidget {
  const CareVisitScreen({super.key, required this.visit});

  final CareVisit visit;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final request = ref.watch(careProvider).request;
    return CarePage(
      backFallback: RoutePaths.careVisits,
      children: [
        ScreenTitle(
          title: 'Your upcoming visit',
          subtitle: Formatters.longDate(visit.date),
        ),
        const SizedBox(height: 10),
        RowCard(
          icon: LcIcons.user,
          title: _carer,
          subtitle: 'Care professional (example)',
          tone: RowCardTone.white,
          onTap: () => context.push(RoutePaths.careTeam),
        ),
        DetailList(
          rows: [
            ('Time', '${visit.time} · UK time'),
            if (request != null) ('Service', request.need),
            if (request != null) ('Postcode', request.postcode),
            ('Status', 'Scheduled'),
          ],
        ),
        PanelCard(
          title: 'Visit preferences',
          body:
              request?.preferences ??
              'Follow the agreed care plan and record the visit notes.',
        ),
        const SizedBox(height: 6),
        PrimaryButton(
          label: 'Contact care team',
          onPressed: () => context.push(RoutePaths.newMessage),
        ),
        const SizedBox(height: 10),
        SecondaryButton(
          label: 'Request a change',
          onPressed: () => context.push(RoutePaths.careChange),
        ),
      ],
    );
  }
}

/// A completed visit's notes (screen pack 087). None have been written yet
/// in the preview, so this shows how they will appear rather than inventing
/// what happened at a visit.
class CareVisitNoteScreen extends StatelessWidget {
  const CareVisitNoteScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return CarePage(
      backFallback: RoutePaths.careVisits,
      children: [
        const ScreenTitle(
          title: 'Care visit notes',
          subtitle: 'Written by your care professional after each visit.',
        ),
        const SizedBox(height: 10),
        const StatusBadge('No visits completed yet', tone: BadgeTone.gray),
        const DocumentPreview(
          title: 'What a visit note includes',
          body:
              'The time of the visit, the agreed activities, anything your '
              'care professional noticed, and any follow-up shared with your '
              'care coordinator.',
        ),
        SecondaryButton(
          label: 'Ask your coordinator',
          onPressed: () => context.push(RoutePaths.newMessage),
        ),
      ],
    );
  }
}

/// "People you can turn to" (screen pack 088).
class CareTeamScreen extends StatelessWidget {
  const CareTeamScreen({super.key});

  @override
  Widget build(BuildContext context) {
    Widget person(String name, String role, String about) => Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: PanelCard(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            UserAvatar(name: name, radius: 24),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: context.palette.ink,
                    ),
                  ),
                  Text(
                    role,
                    style: TextStyle(
                      fontSize: 12.5,
                      color: context.palette.inkMuted,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    about,
                    style: TextStyle(
                      fontSize: 13,
                      height: 1.5,
                      color: context.palette.inkMuted,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );

    return CarePage(
      children: [
        const ScreenTitle(
          title: 'People you can turn to',
          subtitle: 'Your care team.',
        ),
        const SizedBox(height: 10),
        person(
          _coordinator,
          'Care coordinator (example)',
          'Helps arrange assessments, agree the care plan and review changes.',
        ),
        person(
          _carer,
          'Care professional (example)',
          'Supports agreed routines and records visit notes for your care '
              'team.',
        ),
        const SizedBox(height: 8),
        PrimaryButton(
          label: 'Message your care team',
          onPressed: () => context.push(RoutePaths.newMessage),
        ),
        const SizedBox(height: 12),
        const CarePreviewNotice(),
      ],
    );
  }
}

/// "Request a change" (screen pack 089). Current arrangements stay as they
/// are until the care team confirms the change.
class CareChangeScreen extends ConsumerStatefulWidget {
  const CareChangeScreen({super.key});

  @override
  ConsumerState<CareChangeScreen> createState() => _CareChangeScreenState();
}

class _CareChangeScreenState extends ConsumerState<CareChangeScreen> {
  String _type = CareChangeRequest.types.first;
  final _detail = TextEditingController();
  String? _error;

  @override
  void dispose() {
    _detail.dispose();
    super.dispose();
  }

  void _send() {
    final error = Validators.text(
      _detail.text,
      label: 'the change you would like',
      required: true,
      minLength: 10,
    );
    setState(() => _error = error);
    if (error != null) return;
    ref
        .read(careProvider.notifier)
        .requestChange(
          CareChangeRequest(
            type: _type,
            detail: _detail.text.trim(),
            sentAt: DateTime.now(),
          ),
        );
    context.pushReplacement(RoutePaths.careChangeSent);
  }

  @override
  Widget build(BuildContext context) {
    return CarePage(
      backFallback: RoutePaths.carePlan,
      children: [
        const ScreenTitle(
          title: 'Request a change',
          subtitle:
              'Your current arrangements stay in place until the care team '
              'confirms a change.',
        ),
        const SizedBox(height: 10),
        SelectField(
          label: 'What would you like to change?',
          options: CareChangeRequest.types,
          value: _type,
          onChanged: (v) => setState(() => _type = v),
        ),
        TextAreaField(
          label: 'Tell us more',
          controller: _detail,
          hintText: 'For example, could visits move to the afternoon?',
          errorText: _error,
        ),
        const SizedBox(height: 16),
        PrimaryButton(label: 'Send change request', onPressed: _send),
        const SizedBox(height: 12),
        const CarePreviewNotice(),
      ],
    );
  }
}

/// "Your request has been received" (screen pack 090).
class CareChangeSentScreen extends StatelessWidget {
  const CareChangeSentScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return CarePage(
      backFallback: RoutePaths.carePlan,
      children: [
        const SuccessIcon(),
        const ScreenTitle(
          title: 'Your request has been received',
          subtitle:
              'Your coordinator will review it with you. Your existing care '
              'arrangement has not changed.',
        ),
        const SizedBox(height: 16),
        const InfoBanner(
          message: 'You can follow up any time by messaging your care team.',
        ),
        const SizedBox(height: 16),
        PrimaryButton(
          label: 'Return to care plan',
          onPressed: () => context.goBack(fallback: RoutePaths.carePlan),
        ),
        const SizedBox(height: 10),
        SecondaryButton(
          label: 'Message your coordinator',
          onPressed: () => context.push(RoutePaths.newMessage),
        ),
      ],
    );
  }
}
