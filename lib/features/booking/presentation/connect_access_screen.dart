import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/route_paths.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_svg_icons.dart';
import '../../../core/widgets/design/soft_widgets.dart';
import '../../../core/widgets/feedback/app_popup.dart';
import '../application/access_status.dart';
import '../domain/models/access_option.dart';
import '../domain/models/appointment.dart';

/// "Connect your access": choose LifeCome Benefits, Workplace or Community,
/// or Optional Membership, enter the reference code, confirm the eligibility
/// check and verify. Self-pay is always available underneath.
///
/// No eligibility backend exists yet, so verifying only marks the access as
/// pending approval and shows "My benefits" with its "Verification required"
/// state.
class ConnectAccessScreen extends ConsumerStatefulWidget {
  const ConnectAccessScreen({
    super.key,
    this.initial = AccessOption.lifecomeBenefits,
  });

  final AccessOption initial;

  @override
  ConsumerState<ConnectAccessScreen> createState() =>
      _ConnectAccessScreenState();
}

class _ConnectAccessScreenState extends ConsumerState<ConnectAccessScreen> {
  late AccessOption _selected = widget.initial;
  final _codeController = TextEditingController();
  bool _confirmed = false;
  bool _loading = false;

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  Future<void> _verify() async {
    if (!_confirmed) {
      await showErrorPopup(
        context,
        'Tick "Check my eligibility" to confirm, then verify your access.',
      );
      return;
    }
    setState(() => _loading = true);
    await Future<void>.delayed(const Duration(milliseconds: 800));
    if (!mounted) return;
    setState(() => _loading = false);
    ref.read(accessStatusProvider.notifier).markPending();
    context.push(RoutePaths.bookBenefits);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
          children: [
            const DesignBackButton(),
            const SizedBox(height: 14),
            const PageHeading(
              'Connect your access',
              subtitle: "Choose how you'd like to check your access.",
            ),
            const SizedBox(height: 22),
            for (final option in AccessOption.values)
              _OptionRow(
                option: option,
                selected: option == _selected,
                onTap: () => setState(() => _selected = option),
              ),
            const SizedBox(height: 26),
            Text(
              'Membership or access reference',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                letterSpacing: -0.3,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _codeController,
              textCapitalization: TextCapitalization.characters,
              style: TextStyle(fontSize: 16, color: AppColors.textPrimary),
              decoration: InputDecoration(
                hintText: 'Enter code',
                hintStyle: TextStyle(
                  fontSize: 16,
                  color: AppColors.textSecondary,
                ),
                filled: true,
                fillColor: AppColors.inputFill,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 18,
                ),
                border: _inputBorder(AppColors.cardBorder),
                enabledBorder: _inputBorder(AppColors.cardBorder),
                focusedBorder: _inputBorder(AppColors.actionBlue),
              ),
            ),
            const SizedBox(height: 32),
            SoftCard(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Check your eligibility',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.4,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "We'll confirm your access and show your available "
                    'benefits',
                    style: TextStyle(
                      fontSize: 13.5,
                      letterSpacing: -0.2,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 14),
                  InkWell(
                    borderRadius: BorderRadius.circular(8),
                    onTap: () => setState(() => _confirmed = !_confirmed),
                    child: Row(
                      children: [
                        _Checkbox(checked: _confirmed),
                        const SizedBox(width: 14),
                        Text(
                          'Check my eligibility',
                          style: TextStyle(
                            fontSize: 16,
                            letterSpacing: -0.3,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  PillButton(
                    label: _loading ? 'Verifying…' : 'Verify access',
                    onPressed: _loading ? null : _verify,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 26),
            PillButton(
              label: 'Continue as self-pay',
              outlined: true,
              height: 50,
              onPressed: () => context.push(
                RoutePaths.bookingChooseService,
                extra: (BookingAccessType.direct, null),
              ),
            ),
          ],
        ),
      ),
    );
  }

  static OutlineInputBorder _inputBorder(Color color) => OutlineInputBorder(
    borderRadius: BorderRadius.circular(12),
    borderSide: BorderSide(color: color),
  );
}

class _OptionRow extends StatelessWidget {
  const _OptionRow({
    required this.option,
    required this.selected,
    required this.onTap,
  });

  final AccessOption option;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: SoftCard(
        onTap: onTap,
        radius: 12,
        fill: selected ? AppColors.cardFill : AppColors.background,
        borderColor: selected ? AppColors.cardBorder : AppColors.background,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            SizedBox(
              width: 32,
              child: AppSvgIcon(option.glyph, size: 30, color: option.color),
            ),
            const SizedBox(width: 22),
            Expanded(
              child: Text(
                option.title,
                style: TextStyle(
                  fontSize: 19,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.4,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            _Radio(selected: selected),
          ],
        ),
      ),
    );
  }
}

class _Radio extends StatelessWidget {
  const _Radio({required this.selected});

  final bool selected;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 160),
      width: 26,
      height: 26,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: selected ? AppColors.actionBlue : AppColors.textSecondary,
          width: selected ? 1.5 : 1,
        ),
      ),
      padding: const EdgeInsets.all(3),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: selected ? AppColors.actionBlue : Colors.transparent,
        ),
      ),
    );
  }
}

class _Checkbox extends StatelessWidget {
  const _Checkbox({required this.checked});

  final bool checked;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 160),
      width: 24,
      height: 24,
      decoration: BoxDecoration(
        color: checked ? AppColors.actionBlue : AppColors.background,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: checked ? AppColors.actionBlue : AppColors.textSecondary,
        ),
      ),
      child: checked
          ? const AppSvgIcon(
              AppSvgGlyph.checkLine,
              size: 18,
              color: AppColors.white,
            )
          : null,
    );
  }
}
