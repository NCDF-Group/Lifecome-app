import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/network/api_exception.dart';
import '../../../core/router/route_paths.dart';
import '../../../core/router/safe_back.dart';
import '../../../core/theme/app_palette.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/buttons/ghost_button.dart';
import '../../../core/widgets/buttons/primary_button.dart';
import '../../../core/widgets/buttons/secondary_button.dart';
import '../../../core/widgets/feedback/error_state.dart';
import '../../../core/widgets/feedback/info_banner.dart';
import '../../../core/widgets/feedback/skeleton_loader.dart';
import '../../../core/widgets/feedback/status_chip.dart';
import '../../../core/widgets/inputs/choice_card.dart';
import '../../../core/widgets/inputs/form_fields.dart';
import '../../../core/widgets/layout/detail_list.dart';
import '../../../core/widgets/layout/screen_title.dart';
import '../../../core/widgets/lists/row_card.dart';
import '../../../core/widgets/media/lc_icons.dart';
import '../../consultation/presentation/widgets/video_stage.dart';
import '../application/wellbeing_controller.dart';
import '../domain/wellbeing_models.dart';
import 'wellbeing_booking_screens.dart';
import 'wellbeing_widgets.dart';

class _NoSession extends StatelessWidget {
  const _NoSession();

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Column(
      children: [
        const SizedBox(height: 18),
        LcIcon(LcIcons.calendar, size: 44, color: palette.accent),
        const SizedBox(height: 12),
        Text(
          'No wellbeing sessions yet',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: palette.ink),
        ),
        const SizedBox(height: 6),
        Text(
          'Your booked sessions will appear here.',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 14, height: 1.6, color: palette.inkMuted),
        ),
        const SizedBox(height: 16),
        PrimaryButton(
          label: 'Explore wellbeing',
          onPressed: () => context.goBack(fallback: RoutePaths.wellbeing),
        ),
      ],
    );
  }
}

class WellbeingSessionScreen extends ConsumerWidget {
  const WellbeingSessionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final data = ref.watch(wellbeingProvider);
    return WellbeingPage(
      children: data.when(
        loading: () => [const ScreenTitle(title: 'Your wellbeing sessions'), const SkeletonLoader()],
        error: (error, _) => [
          ErrorState(error: error, onRetry: () => ref.read(wellbeingProvider.notifier).refresh()),
        ],
        data: (state) {
          final sessions = [...state.sessions]
            ..sort((a, b) => b.startsAt.compareTo(a.startsAt));
          return [
            const ScreenTitle(title: 'Your wellbeing sessions'),
            if (sessions.isEmpty) const _NoSession()
            else for (final session in sessions) ...[
              const SizedBox(height: 12),
              _SessionCard(session: session),
            ],
          ];
        },
      ),
    );
  }
}

class _SessionCard extends StatelessWidget {
  const _SessionCard({required this.session});

  final WellbeingSession session;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      StatusBadge(
        session.status.isEmpty ? 'Scheduled' : _titleCase(session.status),
        tone: session.isCancelled ? BadgeTone.gray : BadgeTone.green,
      ),
      DetailList(
        rows: [
          ('Session', session.offer.title),
          if (session.practitionerName.isNotEmpty)
            ('Practitioner', session.practitionerName),
          ('Date', Formatters.longDate(session.startsAt.toLocal())),
          ('Time', Formatters.time(session.startsAt.toLocal())),
          ('Reference', session.id),
          if (session.notes?.isNotEmpty == true) ('Your focus', session.notes!),
        ],
      ),
      if (!session.isCancelled && session.isUpcoming) ...[
        const SizedBox(height: 6),
        PrimaryButton(
          label: 'View session details',
          onPressed: () => context.push(RoutePaths.wellbeingCall),
        ),
        const SizedBox(height: 6),
        GhostButton(
          label: 'Cancel session',
          onPressed: () => context.push(RoutePaths.wellbeingCancel),
        ),
      ],
    ],
  );
}

String _titleCase(String value) => value
    .split(RegExp(r'[_\s]+'))
    .where((part) => part.isNotEmpty)
    .map((part) => '${part[0].toUpperCase()}${part.substring(1)}')
    .join(' ');

class WellbeingCancelScreen extends ConsumerStatefulWidget {
  const WellbeingCancelScreen({super.key});

  @override
  ConsumerState<WellbeingCancelScreen> createState() =>
      _WellbeingCancelScreenState();
}

class _WellbeingCancelScreenState extends ConsumerState<WellbeingCancelScreen> {
  bool _confirmed = false;
  bool _submitting = false;

  Future<void> _cancel(WellbeingSession session) async {
    if (!_confirmed) return;
    setState(() => _submitting = true);
    try {
      await ref.read(wellbeingProvider.notifier).cancel(session.id);
      if (mounted) context.goBack(fallback: RoutePaths.wellbeingSession);
    } catch (error) {
      if (!mounted) return;
      final message = error is ApiException
          ? error.message
          : 'We could not cancel this session. Please try again.';
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final data = ref.watch(wellbeingProvider);
    return WellbeingPage(
      backFallback: RoutePaths.wellbeingSession,
      children: data.when(
        loading: () => [const SkeletonLoader()],
        error: (error, _) => [
          ErrorState(error: error, onRetry: () => ref.read(wellbeingProvider.notifier).refresh()),
        ],
        data: (state) {
          WellbeingSession? session;
          for (final item in state.sessions) {
            if (item.isUpcoming) {
              session = item;
              break;
            }
          }
          if (session == null) return [const _NoSession()];
          return [
            const ScreenTitle(
              title: 'Cancel your session?',
              subtitle: 'Please confirm you want to cancel this booking.',
            ),
            const SizedBox(height: 10),
            DetailList(rows: [
              ('Session', session.offer.title),
              ('Practitioner', session.practitionerName),
              ('Date', Formatters.longDate(session.startsAt.toLocal())),
              ('Time', Formatters.time(session.startsAt.toLocal())),
            ]),
            CheckRow(
              value: _confirmed,
              onChanged: (value) => setState(() => _confirmed = value),
              label: 'I want to cancel this session.',
            ),
            const SizedBox(height: 16),
            PrimaryButton(
              label: _submitting ? 'Cancelling…' : 'Confirm cancellation',
              onPressed: _submitting ? null : () => _cancel(session),
            ),
          ];
        },
      ),
    );
  }
}

class WellbeingCallScreen extends ConsumerWidget {
  const WellbeingCallScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final data = ref.watch(wellbeingProvider);
    final session = data.asData?.value.latestSession;
    return WellbeingPage(
      backFallback: RoutePaths.wellbeingSession,
      children: [
        const ScreenTitle(title: 'Your wellbeing session', subtitle: 'Online'),
        if (session == null)
          const _NoSession()
        else ...[
          const SizedBox(height: 16),
          VideoStage(
            name: session.practitionerName,
            title: session.practitionerName,
            message: session.offer.title,
          ),
          const SizedBox(height: 14),
          const InfoBanner(
            message: 'Your practitioner will share call details before the session.',
          ),
        ],
        const SizedBox(height: 16),
        PrimaryButton(
          label: 'View my wellbeing plan',
          onPressed: () => context.pushReplacement(RoutePaths.wellbeingPlan),
        ),
      ],
    );
  }
}

class WellbeingPlanScreen extends ConsumerStatefulWidget {
  const WellbeingPlanScreen({super.key});

  @override
  ConsumerState<WellbeingPlanScreen> createState() => _WellbeingPlanScreenState();
}

class _WellbeingPlanScreenState extends ConsumerState<WellbeingPlanScreen> {
  final _goal = TextEditingController();
  bool _saving = false;

  @override
  void dispose() {
    _goal.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final goal = _goal.text.trim();
    if (goal.length < 3) return;
    setState(() => _saving = true);
    try {
      await ref.read(wellbeingProvider.notifier).savePlan(goal);
    } catch (error) {
      if (mounted) {
        final message = error is ApiException ? error.message : 'We could not save your plan.';
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final data = ref.watch(wellbeingProvider);
    return WellbeingPage(
      children: data.when(
        loading: () => [const SkeletonLoader()],
        error: (error, _) => [
          ErrorState(error: error, onRetry: () => ref.read(wellbeingProvider.notifier).refresh()),
        ],
        data: (state) {
          final plan = state.plan;
          _goal.text = plan?.goal ?? '';
          return [
            const ScreenTitle(
              title: 'Your wellbeing plan',
              subtitle: 'Your saved goals and steps.',
            ),
            const SizedBox(height: 10),
            if (plan == null) ...[
              TextAreaField(
                label: 'Your goal',
                controller: _goal,
                hintText: 'Add a wellbeing goal',
              ),
              PrimaryButton(
                label: _saving ? 'Saving…' : 'Save my goal',
                onPressed: _saving ? null : _save,
              ),
            ] else ...[
              PanelCard(title: 'Your focus', body: plan.goal, tone: PanelTone.mint),
              for (final step in plan.steps)
                CheckboxListTile(
                  value: step.completed,
                  contentPadding: EdgeInsets.zero,
                  title: Text(step.title),
                  subtitle: step.description.isEmpty ? null : Text(step.description),
                  onChanged: (value) async {
                    try {
                      await ref.read(wellbeingProvider.notifier).setStepCompleted(
                        step.id,
                        value ?? false,
                      );
                    } catch (error) {
                      if (context.mounted) {
                        final message = error is ApiException ? error.message : 'Could not update this step.';
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
                      }
                    }
                  },
                ),
              PrimaryButton(label: 'Update my goal', onPressed: _save),
            ],
            RowCard(
              icon: LcIcons.star,
              title: 'My weekly check-in',
              subtitle: state.latestCheckIn == null
                  ? 'Record how your routine is going'
                  : '${state.latestCheckIn!.score} of 5 · latest check-in',
              tone: RowCardTone.mint,
              onTap: () => context.push(RoutePaths.wellbeingCheckIn),
            ),
            const SizedBox(height: 10),
            PrimaryButton(
              label: 'Book your next session',
              onPressed: () => context.go(RoutePaths.wellbeing),
            ),
            const SizedBox(height: 10),
            SecondaryButton(
              label: 'Message your practitioner',
              onPressed: () => context.push(RoutePaths.newMessage),
            ),
          ];
        },
      ),
    );
  }
}

class WellbeingCheckInScreen extends ConsumerStatefulWidget {
  const WellbeingCheckInScreen({super.key});

  @override
  ConsumerState<WellbeingCheckInScreen> createState() => _WellbeingCheckInScreenState();
}

class _WellbeingCheckInScreenState extends ConsumerState<WellbeingCheckInScreen> {
  int _score = 3;
  final _reflection = TextEditingController();
  bool _submitting = false;

  @override
  void dispose() {
    _reflection.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    setState(() => _submitting = true);
    try {
      await ref.read(wellbeingProvider.notifier).submitCheckIn(
        rating: _score,
        wentWell: _reflection.text.trim(),
      );
      if (mounted) context.goBack(fallback: RoutePaths.wellbeingPlan);
    } catch (error) {
      if (mounted) {
        final message = error is ApiException ? error.message : 'We could not save your check-in.';
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
      }
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final data = ref.watch(wellbeingProvider);
    return WellbeingPage(
      backFallback: RoutePaths.wellbeingPlan,
      children: [
        const ScreenTitle(
          title: 'How is your week going?',
          subtitle: 'Reflect on your personal goal. There is no right answer.',
        ),
        const SizedBox(height: 16),
        const FieldLabel('How manageable has your routine felt?'),
        Row(
          children: [
            for (var n = 1; n <= 5; n++) ...[
              if (n > 1) const SizedBox(width: 7),
              Expanded(
                child: Semantics(
                  selected: n == _score,
                  button: true,
                  child: Material(
                    color: n == _score ? palette.tintGreenStrong : palette.surface,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                      side: BorderSide(color: n == _score ? palette.positive : palette.line),
                    ),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(10),
                      onTap: () => setState(() => _score = n),
                      child: SizedBox(
                        height: 48,
                        child: Center(
                          child: Text(
                            '$n',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: n == _score ? palette.positive : palette.ink,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
        TextAreaField(
          label: 'Your reflection',
          controller: _reflection,
          optional: true,
          hintText: 'Add a reflection for your record',
        ),
        const SizedBox(height: 16),
        PrimaryButton(
          label: _submitting ? 'Saving…' : 'Save check-in',
          onPressed: _submitting || data.isLoading ? null : _submit,
        ),
      ],
    );
  }
}
