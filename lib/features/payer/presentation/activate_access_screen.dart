import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/network/api_exception.dart';
import '../../../core/router/route_paths.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_palette.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/utils/validators.dart';
import '../../../core/widgets/buttons/primary_button.dart';
import '../../../core/widgets/feedback/app_popup.dart';
import '../../../core/widgets/feedback/info_banner.dart';
import '../../../core/widgets/inputs/app_text_field.dart';
import '../../../core/widgets/layout/app_header_bar.dart';
import '../../../core/widgets/layout/screen_title.dart';
import '../../messaging/application/messaging_controller.dart';
import '../../messaging/domain/models/message_thread.dart';
import '../../profile/application/profile_controller.dart';
import '../../profile/presentation/profile_required_prompt.dart';

/// Which kind of code is being sent.
enum AccessKind { membership, employer }

/// "Activate your access" — send an invitation or membership code so funding
/// can be linked to the account.
///
/// The backend has no way to redeem a code yet, so nothing here pretends to
/// check one: the code goes to the care team as a message, and they reply in
/// Messages once the access is on the account.
class ActivateAccessScreen extends ConsumerStatefulWidget {
  const ActivateAccessScreen({super.key, this.initial = AccessKind.employer});

  /// The tab to start on.
  final AccessKind initial;

  @override
  ConsumerState<ActivateAccessScreen> createState() =>
      _ActivateAccessScreenState();
}

class _ActivateAccessScreenState extends ConsumerState<ActivateAccessScreen> {
  late AccessKind _tab = widget.initial;
  final _codeController = TextEditingController();
  final _emailController = TextEditingController();
  String? _codeError;
  String? _emailError;
  bool _submitted = false;
  bool _loading = false;

  bool get _isEmployer => _tab == AccessKind.employer;

  @override
  void initState() {
    super.initState();
    // Start from the account's own email; the person can change it.
    ref.listenManual(meProvider, (_, next) {
      final email = next.value?.account.email;
      if (email != null && _emailController.text.isEmpty) {
        _emailController.text = email;
      }
    }, fireImmediately: true);
  }

  @override
  void dispose() {
    _codeController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  bool _validate() {
    setState(() {
      _codeError = Validators.accessCode(_codeController.text);
      _emailError = Validators.email(_emailController.text);
    });
    return _codeError == null && _emailError == null;
  }

  String get _request =>
      'Please activate my access.\n\n'
      'Type: ${_isEmployer ? 'Employer or sponsor invitation' : 'Membership'}'
      '\nCode: ${_codeController.text.trim()}'
      '\nEmail: ${_emailController.text.trim()}';

  Future<void> _send() async {
    if (_loading) return;
    setState(() => _submitted = true);
    if (!_validate()) return;

    setState(() => _loading = true);
    try {
      final thread = await ref
          .read(threadsProvider.notifier)
          .start(topic: MessageTopic.bookingPayments, body: _request);
      if (!mounted) return;
      await showSuccessPopup(
        context,
        title: 'Request sent',
        message:
            'Our care team will check your code and reply in Messages once '
            'your access is active.',
      );
      if (!mounted) return;
      context.pushReplacement('${RoutePaths.messageThread}/${thread.id}');
    } on ApiException catch (error) {
      if (!mounted) return;
      if (error.code == 'PROFILE_REQUIRED') {
        await promptCompleteProfile(context);
      } else {
        await showErrorPopup(context, error.message);
      }
    } catch (_) {
      if (mounted) {
        await showErrorPopup(
          context,
          'Something went wrong. Please try again.',
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.palette.background,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
          children: [
            const AppHeaderBar(
              showBack: true,
              backFallback: RoutePaths.chooseAccess,
            ),
            const SizedBox(height: 20),
            const ScreenTitle(
              title: 'Activate your access',
              subtitle: 'An invitation links funding to your private account.',
            ),
            const SizedBox(height: AppSpacing.md),
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: context.palette.surface,
                borderRadius: BorderRadius.circular(AppRadius.pill),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: _TabButton(
                      label: 'Membership',
                      selected: !_isEmployer,
                      onTap: () => setState(() => _tab = AccessKind.membership),
                    ),
                  ),
                  Expanded(
                    child: _TabButton(
                      label: 'Employer or sponsor',
                      selected: _isEmployer,
                      onTap: () => setState(() => _tab = AccessKind.employer),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: _isEmployer
                    ? context.palette.tintGreen
                    : context.palette.tintBlue,
                borderRadius: BorderRadius.circular(AppRadius.card),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 22,
                    backgroundColor: context.palette.elevated,
                    child: Icon(
                      _isEmployer
                          ? Icons.apartment_outlined
                          : Icons.badge_outlined,
                      color: _isEmployer
                          ? context.palette.positive
                          : context.palette.accent,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _isEmployer
                              ? 'Employer or sponsor access'
                              : 'Personal membership access',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: context.palette.ink,
                          ),
                        ),
                        Text(
                          _isEmployer
                              ? 'Use your invitation code from your '
                                    'employer or scheme administrator.'
                              : 'Use your membership code to activate '
                                    'your account.',
                          style: TextStyle(
                            fontSize: 12.5,
                            color: context.palette.inkMuted,
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            AppTextField(
              label: _isEmployer ? 'Invitation code' : 'Membership code',
              controller: _codeController,
              hintText: _isEmployer
                  ? 'Enter invitation code'
                  : 'Enter membership code',
              textCapitalization: TextCapitalization.characters,
              textInputAction: TextInputAction.next,
              errorText: _codeError,
              onChanged: (_) {
                if (_submitted) _validate();
              },
            ),
            const SizedBox(height: AppSpacing.md),
            AppTextField(
              label: 'Personal email',
              controller: _emailController,
              hintText: 'name@example.com',
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.done,
              errorText: _emailError,
              onChanged: (_) {
                if (_submitted) _validate();
              },
              onSubmitted: (_) => _send(),
            ),
            const SizedBox(height: AppSpacing.md),
            PrimaryButton(
              label: 'Send for activation',
              icon: Icons.arrow_forward,
              loading: _loading,
              onPressed: _send,
            ),
            const SizedBox(height: AppSpacing.sm),
            const InfoBanner(
              message:
                  'Codes are activated by our care team for now. We will '
                  'reply in Messages once your access is on your account.',
            ),
            const SizedBox(height: AppSpacing.sm),
            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: context.palette.tintBlue,
                borderRadius: BorderRadius.circular(AppRadius.card),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 18,
                    backgroundColor: context.palette.elevated,
                    child: Icon(
                      Icons.help_outline,
                      size: 18,
                      color: context.palette.accent,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _isEmployer ? 'No invitation?' : 'No code?',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: context.palette.ink,
                          ),
                        ),
                        Text(
                          _isEmployer
                              ? 'Contact your scheme administrator.'
                              : 'Contact patient support.',
                          style: TextStyle(
                            fontSize: 12.5,
                            color: context.palette.inkMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              'Choose another access route',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: context.palette.ink,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Material(
              color: context.palette.tintGreen,
              borderRadius: BorderRadius.circular(AppRadius.card),
              child: InkWell(
                borderRadius: BorderRadius.circular(AppRadius.card),
                onTap: _isEmployer
                    ? () => context.push(RoutePaths.membershipPlans)
                    : () => setState(() => _tab = AccessKind.employer),
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 18,
                        backgroundColor: context.palette.elevated,
                        child: Icon(
                          Icons.person_outline,
                          size: 18,
                          color: context.palette.positive,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _isEmployer
                                  ? 'Use a personal membership'
                                  : 'Use employer or sponsor access',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: context.palette.ink,
                              ),
                            ),
                            Text(
                              _isEmployer
                                  ? "If you're paying for your own care."
                                  : 'If your employer or scheme covers you.',
                              style: TextStyle(
                                fontSize: 12.5,
                                color: context.palette.inkMuted,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Icon(
                        Icons.chevron_right,
                        color: context.palette.positive,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TabButton extends StatelessWidget {
  const _TabButton({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? AppColors.blue : Colors.transparent,
      borderRadius: BorderRadius.circular(AppRadius.pill),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadius.pill),
        onTap: onTap,
        child: Container(
          height: 44,
          alignment: Alignment.center,
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: selected ? AppColors.white : context.palette.ink,
            ),
          ),
        ),
      ),
    );
  }
}
