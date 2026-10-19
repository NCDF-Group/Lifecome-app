import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/router/route_paths.dart';
import '../../../core/router/safe_back.dart';
import '../../../core/theme/app_palette.dart';
import '../../../core/utils/validators.dart';
import '../../../core/widgets/buttons/primary_button.dart';
import '../../../core/widgets/feedback/app_popup.dart';
import '../../../core/widgets/feedback/info_banner.dart';
import '../../../core/widgets/inputs/form_fields.dart';
import '../../../core/widgets/layout/app_header_bar.dart';
import '../../../core/widgets/layout/max_content_width.dart';
import '../../../core/widgets/layout/screen_title.dart';
import '../application/profile_controller.dart';
import '../data/health_profile_store.dart';

/// "Your health profile" (screen pack 021): conditions, medicines and
/// allergies the person chooses to note. Kept encrypted on this phone and
/// offered on the "Help your GP prepare" form when they book.
class HealthProfileScreen extends ConsumerStatefulWidget {
  const HealthProfileScreen({super.key});

  @override
  ConsumerState<HealthProfileScreen> createState() =>
      _HealthProfileScreenState();
}

class _HealthProfileScreenState extends ConsumerState<HealthProfileScreen> {
  final _conditions = TextEditingController();
  final _medicines = TextEditingController();
  final _allergies = TextEditingController();
  final _errors = <String, String?>{};
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    ref.listenManual(healthProfileProvider, (_, next) {
      final profile = next.value;
      if (profile == null) return;
      if (_conditions.text.isEmpty) _conditions.text = profile.conditions ?? '';
      if (_medicines.text.isEmpty) _medicines.text = profile.medicines ?? '';
      if (_allergies.text.isEmpty) _allergies.text = profile.allergies ?? '';
    }, fireImmediately: true);
  }

  @override
  void dispose() {
    _conditions.dispose();
    _medicines.dispose();
    _allergies.dispose();
    super.dispose();
  }

  String? _value(TextEditingController c) {
    final text = c.text.trim();
    return text.isEmpty ? null : text;
  }

  Future<void> _save() async {
    setState(() {
      for (final (key, c) in [
        ('conditions', _conditions),
        ('medicines', _medicines),
        ('allergies', _allergies),
      ]) {
        _errors[key] = Validators.text(c.text, label: key, maxLength: 1000);
      }
    });
    if (_errors.values.any((e) => e != null)) return;
    final accountId = ref.read(meProvider).value?.account.id;
    if (accountId == null) return;

    setState(() => _saving = true);
    try {
      await ref
          .read(healthProfileStoreProvider)
          .save(
            accountId,
            HealthProfile(
              conditions: _value(_conditions),
              medicines: _value(_medicines),
              allergies: _value(_allergies),
            ),
          );
      ref.invalidate(healthProfileProvider);
      if (!mounted) return;
      await showSuccessPopup(
        context,
        title: 'Health profile saved',
        message: 'We will offer it when you book an appointment.',
      );
      if (mounted) context.goBack(fallback: RoutePaths.profile);
    } catch (_) {
      if (mounted) {
        await showErrorPopup(
          context,
          "We couldn't save that. Please try again.",
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.palette.background,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 25),
          children: [
            MaxContentWidth(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const AppHeaderBar(
                    showBack: true,
                    backFallback: RoutePaths.profile,
                  ),
                  const SizedBox(height: 4),
                  const ScreenTitle(
                    title: 'Your health profile',
                    subtitle:
                        'Information you choose to share with your care team.',
                  ),
                  const SizedBox(height: 14),
                  const InfoBanner(
                    message:
                        'Saved securely on this phone. It is shared with a '
                        'clinician only when you add it to a booking.',
                  ),
                  const SizedBox(height: 6),
                  TextAreaField(
                    label: 'Medical conditions',
                    controller: _conditions,
                    optional: true,
                    errorText: _errors['conditions'],
                  ),
                  TextAreaField(
                    label: 'Current medicines',
                    controller: _medicines,
                    optional: true,
                    errorText: _errors['medicines'],
                  ),
                  TextAreaField(
                    label: 'Allergies',
                    controller: _allergies,
                    optional: true,
                    errorText: _errors['allergies'],
                  ),
                  const SizedBox(height: 16),
                  PrimaryButton(
                    label: 'Save health profile',
                    loading: _saving,
                    onPressed: _save,
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
