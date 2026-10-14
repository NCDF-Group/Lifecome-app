import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/network/api_exception.dart';
import '../../../core/router/route_paths.dart';
import '../../../core/router/safe_back.dart';
import '../../../core/theme/app_palette.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/utils/validators.dart';
import '../../../core/widgets/buttons/primary_button.dart';
import '../../../core/widgets/feedback/app_popup.dart';
import '../../../core/widgets/feedback/error_state.dart';
import '../../../core/widgets/feedback/loading_indicator.dart';
import '../../../core/widgets/inputs/app_text_field.dart';
import '../../../core/widgets/layout/back_app_bar.dart';
import '../../../core/widgets/layout/max_content_width.dart';
import '../../auth/application/auth_controller.dart';
import '../application/profile_controller.dart';
import '../domain/models/me.dart';
import '../domain/models/patient_profile.dart';

/// The values the backend accepts for `sex`, with how each is shown.
const _sexOptions = [
  ('female', 'Female'),
  ('male', 'Male'),
  ('other', 'Other'),
  ('unknown', 'Prefer not to say'),
];

/// "Your care profile" — the details the care team needs: name, date of birth
/// and where the person lives. Only what the backend stores is shown here.
///
/// With [onboarding] it is the "complete your profile" step after signing up
/// (the profile does not exist yet), and saving continues to Home.
class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key, this.onboarding = false});

  final bool onboarding;

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _dobController = TextEditingController();
  final _cityController = TextEditingController();
  final _countyController = TextEditingController();

  DateTime? _dob;
  String? _sex;
  bool _prefilled = false;
  bool _saving = false;

  /// Errors stay quiet until the first attempt to save; after that each field
  /// re-checks as it is edited.
  bool _submitted = false;

  String? _firstNameError;
  String? _lastNameError;
  String? _dobError;
  String? _cityError;
  String? _countyError;

  @override
  void initState() {
    super.initState();
    ref.listenManual<AsyncValue<Me>>(
      meProvider,
      (_, next) => _prefill(next.value),
      fireImmediately: true,
    );
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _dobController.dispose();
    _cityController.dispose();
    _countyController.dispose();
    super.dispose();
  }

  /// Fills the form once with what the backend already has. When there is no
  /// profile yet (just signed up) the name typed at sign-up is the starting
  /// point.
  void _prefill(Me? me) {
    if (_prefilled || me == null) return;
    _prefilled = true;
    final profile = me.profile;
    if (profile != null) {
      _firstNameController.text = profile.firstName;
      _lastNameController.text = profile.lastName;
      _dob = profile.dateOfBirth;
      _dobController.text = Formatters.dateField(profile.dateOfBirth);
      _sex = profile.sex;
      _cityController.text = profile.city ?? '';
      _countyController.text = profile.state ?? '';
    } else {
      final fullName = ref.read(authControllerProvider).fullName?.trim() ?? '';
      if (fullName.isNotEmpty) {
        final parts = fullName.split(RegExp(r'\s+'));
        // Never overwrite what the person has already started typing.
        if (_firstNameController.text.isEmpty) {
          _firstNameController.text = parts.first;
        }
        if (_lastNameController.text.isEmpty) {
          _lastNameController.text = parts.skip(1).join(' ');
        }
      }
    }
  }

  bool _validate() {
    setState(() {
      _firstNameError = Validators.personName(
        _firstNameController.text,
        label: 'first name',
      );
      _lastNameError = Validators.personName(
        _lastNameController.text,
        label: 'last name',
      );
      _dobError = Validators.dateOfBirth(_dob);
      _cityError = Validators.place(
        _cityController.text,
        label: 'town or city',
      );
      _countyError = Validators.place(_countyController.text, label: 'county');
    });
    return [
      _firstNameError,
      _lastNameError,
      _dobError,
      _cityError,
      _countyError,
    ].every((error) => error == null);
  }

  void _revalidate() {
    if (_submitted) _validate();
  }

  Future<void> _pickDateOfBirth() async {
    final now = DateTime.now();
    // Nobody under 18 can have an account, so the picker stops there.
    final latest = DateTime(
      now.year - Validators.minimumAge,
      now.month,
      now.day,
    );
    final picked = await showDatePicker(
      context: context,
      initialDate: _dob ?? DateTime(now.year - 30, now.month, now.day),
      firstDate: DateTime(now.year - Validators.maximumAge),
      lastDate: latest,
      helpText: 'Date of birth',
    );
    if (picked == null) return;
    setState(() {
      _dob = DateTime(picked.year, picked.month, picked.day);
      _dobController.text = Formatters.dateField(_dob!);
    });
    _revalidate();
  }

  /// What to send for an optional text field: its text, or an empty string to
  /// clear a value that was set before, or nothing when it was never set.
  String? _optional(String text, String? before) {
    final trimmed = text.trim();
    if (trimmed.isNotEmpty) return trimmed;
    return before == null ? null : '';
  }

  Future<void> _save() async {
    if (_saving) return;
    setState(() => _submitted = true);
    if (!_validate()) return;

    final before = ref.read(meProvider).value?.profile;
    final input = ProfileInput(
      firstName: _firstNameController.text.trim(),
      lastName: _lastNameController.text.trim(),
      dateOfBirth: _dob!,
      sex: _sex ?? (before?.sex != null ? '' : null),
      city: _optional(_cityController.text, before?.city),
      state: _optional(_countyController.text, before?.state),
      country: before?.country ?? 'GB',
    );

    setState(() => _saving = true);
    try {
      await ref.read(meProvider.notifier).saveProfile(input);
      if (!mounted) return;
      if (widget.onboarding) {
        context.go(RoutePaths.home);
      } else {
        await showSuccessPopup(
          context,
          title: 'Profile updated',
          message: 'Your changes have been saved.',
        );
        if (mounted) context.goBack(fallback: RoutePaths.profile);
      }
    } on ApiException catch (error) {
      if (!mounted) return;
      final fields = error.fieldErrors;
      if (fields.isNotEmpty) {
        setState(() {
          _firstNameError = fields['firstName'] ?? _firstNameError;
          _lastNameError = fields['lastName'] ?? _lastNameError;
          _dobError = fields['dateOfBirth'] ?? _dobError;
          _cityError = fields['city'] ?? _cityError;
          _countyError = fields['state'] ?? _countyError;
        });
      } else {
        showErrorPopup(context, error.message);
      }
    } catch (_) {
      if (!mounted) return;
      showErrorPopup(context, 'Something went wrong. Please try again.');
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final me = ref.watch(meProvider);
    // Signing up has just created the account, so there is nothing to load
    // before the person can fill the form in; editing waits for the details.
    final ready = widget.onboarding || me.hasValue;

    return Scaffold(
      backgroundColor: context.palette.background,
      appBar: BackAppBar(
        title: widget.onboarding
            ? 'Complete your profile'
            : 'Your care profile',
        fallback: widget.onboarding ? RoutePaths.home : RoutePaths.profile,
      ),
      body: SafeArea(
        child: !ready
            ? (me.hasError
                  ? ErrorState(
                      error: me.error!,
                      onRetry: () => ref.read(meProvider.notifier).refresh(),
                    )
                  : const LoadingIndicator())
            : _form(context),
      ),
    );
  }

  Widget _form(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      children: [
        MaxContentWidth(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                widget.onboarding
                    ? 'Tell us a little about you so we can book your care. '
                          'You can change this later.'
                    : 'Keep your details up to date so we can provide the best care for you.',
                style: TextStyle(
                  fontSize: 14,
                  color: context.palette.inkMuted,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              _SectionCard(
                background: context.palette.tintGreen,
                icon: Icons.person_outline,
                iconColor: context.palette.positive,
                title: 'Personal details',
                children: [
                  AppTextField(
                    label: 'First name',
                    controller: _firstNameController,
                    textInputAction: TextInputAction.next,
                    autofillHints: const [AutofillHints.givenName],
                    errorText: _firstNameError,
                    onChanged: (_) => _revalidate(),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  AppTextField(
                    label: 'Last name',
                    controller: _lastNameController,
                    textInputAction: TextInputAction.next,
                    autofillHints: const [AutofillHints.familyName],
                    errorText: _lastNameError,
                    onChanged: (_) => _revalidate(),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  AppTextField(
                    label: 'Date of birth',
                    controller: _dobController,
                    hintText: 'DD / MM / YYYY',
                    readOnly: true,
                    onTap: _pickDateOfBirth,
                    errorText: _dobError,
                    suffixIcon: Icon(
                      Icons.calendar_today_outlined,
                      size: 18,
                      color: context.palette.inkMuted,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    'Sex (optional)',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: context.palette.ink,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Wrap(
                    spacing: AppSpacing.xs,
                    runSpacing: AppSpacing.xs,
                    children: [
                      for (final (code, label) in _sexOptions)
                        ChoiceChip(
                          label: Text(label),
                          selected: _sex?.toLowerCase() == code,
                          // Tapping the chosen one again clears it.
                          onSelected: (selected) =>
                              setState(() => _sex = selected ? code : null),
                        ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              _SectionCard(
                background: context.palette.tintBlue,
                icon: Icons.home_outlined,
                iconColor: context.palette.accent,
                title: 'Where you live',
                children: [
                  AppTextField(
                    label: 'Town or city (optional)',
                    controller: _cityController,
                    textInputAction: TextInputAction.next,
                    errorText: _cityError,
                    onChanged: (_) => _revalidate(),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  AppTextField(
                    label: 'County (optional)',
                    controller: _countyController,
                    textInputAction: TextInputAction.done,
                    errorText: _countyError,
                    onChanged: (_) => _revalidate(),
                    onSubmitted: (_) => _save(),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: context.palette.tintBlue,
                  borderRadius: BorderRadius.circular(AppRadius.control),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.shield_outlined,
                      size: 18,
                      color: context.palette.accent,
                    ),
                    const SizedBox(width: AppSpacing.xs),
                    Expanded(
                      child: Text(
                        'Your payer cannot see your clinical records.',
                        style: TextStyle(
                          fontSize: 13,
                          color: context.palette.ink,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              PrimaryButton(
                label: widget.onboarding ? 'Save and continue' : 'Save profile',
                loading: _saving,
                onPressed: _save,
              ),
              if (widget.onboarding) ...[
                const SizedBox(height: AppSpacing.xs),
                TextButton(
                  onPressed: _saving ? null : () => context.go(RoutePaths.home),
                  child: Text(
                    'Do this later',
                    style: TextStyle(
                      color: context.palette.inkMuted,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({
    required this.background,
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.children,
  });

  final Color background;
  final IconData icon;
  final Color iconColor;
  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(AppRadius.card),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: context.palette.elevated,
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 16, color: iconColor),
              ),
              const SizedBox(width: AppSpacing.xs),
              Text(
                title,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: context.palette.ink,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          ...children,
        ],
      ),
    );
  }
}
