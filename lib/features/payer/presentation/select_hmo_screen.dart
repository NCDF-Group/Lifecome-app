import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/route_paths.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/feedback/app_popup.dart';

class _Hmo {
  const _Hmo({required this.name, required this.tagline});

  final String name;
  final String tagline;
}

const _hmos = [
  _Hmo(name: 'LifeCome HMO', tagline: 'People. Health. Brighter Lives.'),
  _Hmo(
    name: 'AXA Mansard Health',
    tagline: 'Redefining healthcare for a better tomorrow.',
  ),
  _Hmo(name: 'Avon HMO', tagline: 'Healthcare for a better you.'),
  _Hmo(name: 'Hygeia HMO', tagline: 'Healthier lives, brighter futures.'),
  _Hmo(name: 'Reliance HMO', tagline: 'Your health, our priority.'),
  _Hmo(name: 'Total Health Trust', tagline: 'Healthcare you can trust.'),
];

/// Blueprint view 06 — Select Your HMO. LifeCome HMO is always listed first
/// (product decision, per the blueprint), not alphabetically.
class SelectHmoScreen extends StatelessWidget {
  const SelectHmoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        title: const Text(
          'Select your HMO',
          style: TextStyle(color: AppColors.ink, fontWeight: FontWeight.w800),
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          children: [
            const Text(
              "Choose your health plan from our participating HMOs. If you can't see "
              'your HMO, you can still pay directly.',
              style: TextStyle(
                fontSize: 14,
                color: AppColors.inkMuted,
                height: 1.4,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            TextField(
              decoration: InputDecoration(
                hintText: 'Search for your HMO (e.g. AXA, Avon, Hygeia)',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: AppColors.surface,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppRadius.pill),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            const Text(
              'Participating HMOs',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: AppColors.ink,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            for (var i = 0; i < _hmos.length; i++) ...[
              _HmoTile(hmo: _hmos[i], isDefault: i == 0),
              const SizedBox(height: AppSpacing.xs),
            ],
            const SizedBox(height: AppSpacing.xs),
            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: const Color(0xFFE8F4FC),
                borderRadius: BorderRadius.circular(AppRadius.card),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline, color: AppColors.blue),
                  const SizedBox(width: AppSpacing.sm),
                  const Expanded(
                    child: Text(
                      "Can't find your HMO? You can still pay directly for your consultation.",
                      style: TextStyle(fontSize: 13, color: AppColors.ink),
                    ),
                  ),
                  TextButton(
                    onPressed: () => showComingSoonPopup(
                      context,
                      feature: 'Paying directly',
                    ),
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
  const _HmoTile({required this.hmo, required this.isDefault});

  final _Hmo hmo;
  final bool isDefault;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: isDefault ? const Color(0xFFEAF7E8) : AppColors.white,
      borderRadius: BorderRadius.circular(AppRadius.control),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadius.control),
        onTap: () =>
            context.push(RoutePaths.payerVerifyMembership, extra: hmo.name),
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.sm),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadius.control),
            border: Border.all(
              color: isDefault ? AppColors.greenStrong : AppColors.line,
            ),
          ),
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: AppColors.blue.withValues(alpha: 0.1),
                child: Text(
                  hmo.name[0],
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    color: AppColors.blue,
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      hmo.name,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: AppColors.ink,
                      ),
                    ),
                    Text(
                      hmo.tagline,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.inkMuted,
                      ),
                    ),
                  ],
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
                      fontWeight: FontWeight.w700,
                      color: AppColors.white,
                    ),
                  ),
                )
              else
                const Icon(Icons.chevron_right, color: AppColors.inkMuted),
            ],
          ),
        ),
      ),
    );
  }
}
