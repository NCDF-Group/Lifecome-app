import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/route_paths.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/buttons/primary_button.dart';
import '../../../core/widgets/feedback/app_popup.dart';
import '../../../core/widgets/inputs/app_text_field.dart';
import '../../../core/widgets/layout/max_content_width.dart';
import '../domain/models/appointment.dart';

/// Between choosing a service and finding a doctor: confirms where the
/// patient is, so [FindADoctorScreen] can show availability for their area.
/// City/postcode aren't sent anywhere yet — no booking backend exists to
/// use them (see `BookingSelection`'s own doc comment) — so this is a
/// presentational gate for now, same honesty the rest of the booking flow
/// keeps about what's actually wired up.
class BookingLocationScreen extends StatefulWidget {
  const BookingLocationScreen({super.key, required this.selection});

  final BookingSelection selection;

  @override
  State<BookingLocationScreen> createState() => _BookingLocationScreenState();
}

class _BookingLocationScreenState extends State<BookingLocationScreen> {
  final _cityController = TextEditingController(text: 'London');
  final _postcodeController = TextEditingController();

  @override
  void dispose() {
    _cityController.dispose();
    _postcodeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.lg,
            AppSpacing.sm,
            AppSpacing.lg,
            AppSpacing.lg,
          ),
          child: MaxContentWidth(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    IconButton(
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      onPressed: () => context.pop(),
                      icon: const Icon(
                        Icons.arrow_back_ios_new,
                        size: 18,
                        color: AppColors.ink,
                      ),
                    ),
                    const SizedBox(width: 8),
                    SvgPicture.asset(
                      'assets/images/logo/lifecome-live-logo.svg',
                      height: 24,
                      semanticsLabel: 'LifeCome Live',
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.lg),
                const Text(
                  'Enter your location',
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                    color: AppColors.ink,
                  ),
                ),
                const SizedBox(height: AppSpacing.xxs),
                const Text(
                  'Device location is unavailable.',
                  style: TextStyle(fontSize: 14, color: AppColors.inkMuted),
                ),
                const SizedBox(height: AppSpacing.lg),
                AppTextField(label: 'City', controller: _cityController),
                const SizedBox(height: AppSpacing.md),
                AppTextField(
                  label: 'Postcode',
                  controller: _postcodeController,
                  hintText: 'Enter your postcode',
                ),
                const SizedBox(height: AppSpacing.md),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE3EEFB),
                    borderRadius: BorderRadius.circular(AppRadius.control),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(
                            Icons.info_outline,
                            size: 18,
                            color: AppColors.blue,
                          ),
                          const SizedBox(width: AppSpacing.xs),
                          const Expanded(
                            child: Text(
                              'Availability depends on your location.\nIf care is unavailable, choose another location or contact support.',
                              style: TextStyle(
                                fontSize: 12.5,
                                color: AppColors.ink,
                                height: 1.4,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      InkWell(
                        onTap: () => showComingSoonPopup(
                          context,
                          feature: 'Device location',
                        ),
                        child: const Row(
                          children: [
                            Icon(
                              Icons.my_location,
                              size: 15,
                              color: AppColors.blue,
                            ),
                            SizedBox(width: 6),
                            Text(
                              'Try device location again',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: AppColors.blue,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                PrimaryButton(
                  label: 'Check availability',
                  icon: Icons.arrow_forward,
                  onPressed: () => context.push(
                    RoutePaths.doctorsFindADoctor,
                    extra: widget.selection,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
