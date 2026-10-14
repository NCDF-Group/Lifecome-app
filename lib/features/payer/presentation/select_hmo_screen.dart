import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/route_paths.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_palette.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/utils/validators.dart';
import '../../../core/widgets/feedback/empty_state.dart';
import '../../../core/widgets/feedback/error_state.dart';
import '../../../core/widgets/feedback/loading_indicator.dart';
import '../../../core/widgets/layout/back_app_bar.dart';
import '../../booking/domain/models/booking_selection.dart';
import '../application/payer_controller.dart';
import '../domain/models/payer.dart';

/// Blueprint view 06 — Select Your HMO. The plans come from the backend, in
/// the order it lists them (the first is the one the business wants shown
/// first, per the blueprint) — nothing is hard-coded here.
class SelectHmoScreen extends ConsumerStatefulWidget {
  const SelectHmoScreen({super.key});

  @override
  ConsumerState<SelectHmoScreen> createState() => _SelectHmoScreenState();
}

class _SelectHmoScreenState extends ConsumerState<SelectHmoScreen> {
  final _searchController = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _payDirectly() => context.push(
    RoutePaths.bookingChooseService,
    extra: const BookingStart.direct(),
  );

  @override
  Widget build(BuildContext context) {
    final payers = ref.watch(payersProvider);
    final searchError = Validators.searchQuery(_query);

    return Scaffold(
      backgroundColor: context.palette.background,
      appBar: const BackAppBar(title: 'Select your HMO'),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          children: [
            Text(
              "Choose your health plan from our participating HMOs. If you can't see "
              'your HMO, you can still pay directly.',
              style: TextStyle(
                fontSize: 14,
                color: context.palette.inkMuted,
                height: 1.4,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            TextField(
              controller: _searchController,
              onChanged: (value) => setState(() => _query = value),
              style: TextStyle(fontSize: 16, color: context.palette.ink),
              decoration: InputDecoration(
                hintText: 'Search for your HMO',
                errorText: searchError,
                prefixIcon: const Icon(Icons.search),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              'Participating HMOs',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: context.palette.ink,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            payers.when(
              loading: () => const LoadingIndicator(),
              error: (error, _) => ErrorState(
                error: error,
                onRetry: () => ref.invalidate(payersProvider),
              ),
              data: (all) {
                final query = _query.trim().toLowerCase();
                final shown = [
                  for (final payer in all)
                    if (query.isEmpty ||
                        payer.name.toLowerCase().contains(query))
                      payer,
                ];
                if (shown.isEmpty) {
                  return EmptyState(
                    icon: Icons.health_and_safety_outlined,
                    title: all.isEmpty
                        ? 'No health plans yet'
                        : 'No plans match your search',
                    message: all.isEmpty
                        ? 'No HMOs are connected yet. You can still pay '
                              'directly for your consultation.'
                        : 'Try a different name, or pay directly.',
                  );
                }
                return Column(
                  children: [
                    for (var i = 0; i < shown.length; i++) ...[
                      _HmoTile(
                        payer: shown[i],
                        isDefault: query.isEmpty && i == 0,
                      ),
                      const SizedBox(height: AppSpacing.xs),
                    ],
                  ],
                );
              },
            ),
            const SizedBox(height: AppSpacing.xs),
            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: context.palette.tintBlueFaint,
                borderRadius: BorderRadius.circular(AppRadius.card),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: context.palette.accent),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Text(
                      "Can't find your HMO? You can still pay directly for your consultation.",
                      style: TextStyle(
                        fontSize: 13,
                        color: context.palette.ink,
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: _payDirectly,
                    child: const Text('Pay directly'),
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

class _HmoTile extends StatelessWidget {
  const _HmoTile({required this.payer, required this.isDefault});

  final Payer payer;
  final bool isDefault;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: isDefault ? context.palette.tintGreen : context.palette.elevated,
      borderRadius: BorderRadius.circular(AppRadius.control),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadius.control),
        onTap: () =>
            context.push(RoutePaths.payerVerifyMembership, extra: payer),
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.sm),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadius.control),
            border: Border.all(
              color: isDefault
                  ? context.palette.positive
                  : context.palette.line,
            ),
          ),
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: AppColors.blue.withValues(alpha: 0.1),
                child: Text(
                  payer.name.isEmpty ? '?' : payer.name[0].toUpperCase(),
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: context.palette.accent,
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  payer.name,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: context.palette.ink,
                  ),
                ),
              ),
              if (isDefault)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.xs,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.greenStrong,
                    borderRadius: BorderRadius.circular(AppRadius.pill),
                  ),
                  child: const Text(
                    'Default',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: AppColors.white,
                    ),
                  ),
                )
              else
                Icon(Icons.chevron_right, color: context.palette.inkMuted),
            ],
          ),
        ),
      ),
    );
  }
}
