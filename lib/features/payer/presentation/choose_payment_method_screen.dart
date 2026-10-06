import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/route_paths.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import '../../booking/domain/models/appointment.dart';

/// Blueprint view 05 — Choose How to Pay. The branch point between the HMO
/// path (views 06-09) and paying directly for a one-time service (view 10
/// onward, not built yet — no booking backend exists for it either).
class ChoosePaymentMethodScreen extends StatelessWidget {
  const ChoosePaymentMethodScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        title: const Text(
          'Choose how to pay',
          style: TextStyle(color: AppColors.ink, fontWeight: FontWeight.w800),
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          children: [
            const Text(
              'Access quality healthcare in a way that works for you. You can use a '
              'participating HMO or pay directly.',
              style: TextStyle(
                fontSize: 14,
                color: AppColors.inkMuted,
                height: 1.4,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            _PaymentOptionCard(
              icon: Icons.health_and_safety_outlined,
              title: 'Use my HMO',
              description:
                  'If your health plan participates in LifeCome Live, verify your '
                  'membership and check your cover.',
              badge: 'Recommended',
              highlighted: true,
              onTap: () => context.push(RoutePaths.payerSelectHmo),
            ),
            const SizedBox(height: AppSpacing.sm),
            _PaymentOptionCard(
              icon: Icons.account_balance_wallet_outlined,
              title: 'Pay directly',
              description: 'No HMO required. Choose your service, see the price and pay securely.',
              onTap: () => context.push(
                RoutePaths.bookingChooseService,
                extra: (BookingAccessType.direct, null),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PaymentOptionCard extends StatelessWidget {
  const _PaymentOptionCard({
    required this.icon,
    required this.title,
    required this.description,
    required this.onTap,
    this.badge,
    this.highlighted = false,
  });

  final IconData icon;
  final String title;
  final String description;
  final String? badge;
  final bool highlighted;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: highlighted ? const Color(0xFFEAF7E8) : AppColors.white,
      borderRadius: BorderRadius.circular(AppRadius.card),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadius.card),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadius.card),
            border: Border.all(
              color: highlighted ? AppColors.greenStrong : AppColors.line,
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: (highlighted ? AppColors.greenStrong : AppColors.blue)
                      .withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  color: highlighted ? AppColors.greenStrong : AppColors.blue,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            title,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              color: AppColors.ink,
                            ),
                          ),
                        ),
                        if (badge != null)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.xs,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.greenStrong,
                              borderRadius: BorderRadius.circular(
                                AppRadius.pill,
                              ),
                            ),
                            child: Text(
                              badge!,
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: AppColors.white,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.xxs),
                    Text(
                      description,
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.inkMuted,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
