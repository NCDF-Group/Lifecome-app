import 'package:flutter/material.dart';

import '../../network/api_exception.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_palette.dart';
import '../../theme/app_radius.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_typography.dart';

/// The app's one way of telling the user something: a centred, animated
/// popup card. Used in place of SnackBars everywhere, so every message —
/// coming soon, success, an error, no network, notifications, photo upload,
/// a destructive confirmation — looks and behaves the same.
enum AppPopupKind { info, success, error, offline }

class _KindStyle {
  const _KindStyle(this.icon, this.color);
  final IconData icon;
  final Color color;
}

const _styles = {
  AppPopupKind.info: _KindStyle(Icons.auto_awesome_rounded, AppColors.blue),
  AppPopupKind.success: _KindStyle(
    Icons.check_circle_rounded,
    AppColors.greenStrong,
  ),
  AppPopupKind.error: _KindStyle(Icons.error_rounded, AppColors.error),
  AppPopupKind.offline: _KindStyle(Icons.wifi_off_rounded, AppColors.gold),
};

/// Shows a popup and resolves to the value the tapped action popped with
/// (`true` for the primary action, `false`/`null` for dismiss).
Future<T?> showAppPopup<T>(
  BuildContext context, {
  required AppPopupKind kind,
  required String title,
  required String message,
  String primaryLabel = 'Got it',
  String? secondaryLabel,
  bool destructive = false,
  Widget? body,
}) {
  return showGeneralDialog<T>(
    context: context,
    barrierDismissible: true,
    barrierLabel: title,
    barrierColor: AppColors.ink.withValues(alpha: 0.45),
    transitionDuration: const Duration(milliseconds: 260),
    pageBuilder: (context, _, _) => _AppPopupCard(
      kind: kind,
      title: title,
      message: message,
      primaryLabel: primaryLabel,
      secondaryLabel: secondaryLabel,
      destructive: destructive,
      body: body,
    ),
    transitionBuilder: (context, animation, _, child) {
      final curved = CurvedAnimation(
        parent: animation,
        curve: Curves.easeOutBack,
        reverseCurve: Curves.easeIn,
      );
      return FadeTransition(
        opacity: animation,
        child: ScaleTransition(
          scale: Tween(begin: 0.88, end: 1.0).animate(curved),
          child: child,
        ),
      );
    },
  );
}

Future<void> showComingSoonPopup(BuildContext context, {String? feature}) {
  return showAppPopup<void>(
    context,
    kind: AppPopupKind.info,
    title: 'Coming soon',
    message: feature == null
        ? "We're still building this. It'll be ready in a future update."
        : "$feature isn't available yet. It'll be ready in a future update.",
  );
}

Future<void> showSuccessPopup(
  BuildContext context, {
  required String title,
  required String message,
}) {
  return showAppPopup<void>(
    context,
    kind: AppPopupKind.success,
    title: title,
    message: message,
    primaryLabel: 'Done',
  );
}

/// Shows an error. A failed connection gets the dedicated "no network"
/// popup rather than a generic error.
Future<void> showErrorPopup(BuildContext context, String message) {
  if (message == ApiException.networkMessage) {
    return showAppPopup<void>(
      context,
      kind: AppPopupKind.offline,
      title: "You're offline",
      message:
          "We couldn't reach LifeCome Live. Check your Wi-Fi or mobile data, "
          'then try again.',
      primaryLabel: 'OK',
    );
  }
  return showAppPopup<void>(
    context,
    kind: AppPopupKind.error,
    title: 'Something went wrong',
    message: message,
    primaryLabel: 'Try again',
  );
}

/// Asks the user to confirm an action; resolves `true` only if confirmed.
Future<bool> showConfirmPopup(
  BuildContext context, {
  required String title,
  required String message,
  required String confirmLabel,
  bool destructive = false,
}) async {
  final confirmed = await showAppPopup<bool>(
    context,
    kind: destructive ? AppPopupKind.error : AppPopupKind.info,
    title: title,
    message: message,
    primaryLabel: confirmLabel,
    secondaryLabel: 'Cancel',
    destructive: destructive,
  );
  return confirmed ?? false;
}

enum PhotoSource { camera, library }

/// Lets the user pick where a photo comes from; resolves `null` if dismissed.
Future<PhotoSource?> showUploadPhotoPopup(BuildContext context) {
  return showAppPopup<PhotoSource>(
    context,
    kind: AppPopupKind.info,
    title: 'Upload a photo',
    message: 'Choose a clear, well-lit photo of your face.',
    primaryLabel: 'Cancel',
    body: Column(
      children: [
        _OptionTile(
          value: PhotoSource.camera,
          leading: Icon(
            Icons.photo_camera_rounded,
            color: context.palette.accent,
            size: 22,
          ),
          label: 'Take a photo',
        ),
        SizedBox(height: AppSpacing.xs),
        _OptionTile(
          value: PhotoSource.library,
          leading: Icon(
            Icons.photo_library_rounded,
            color: context.palette.accent,
            size: 22,
          ),
          label: 'Choose from library',
        ),
      ],
    ),
  );
}

/// Lets the user choose how the app looks; resolves `null` if dismissed.
/// [current] gets the tick.
Future<ThemeMode?> showAppearancePopup(
  BuildContext context, {
  required ThemeMode current,
}) {
  Widget option(ThemeMode mode, IconData icon, String label) => _OptionTile(
    value: mode,
    leading: Icon(icon, color: context.palette.accent, size: 22),
    label: label,
    selected: current == mode,
  );

  return showAppPopup<ThemeMode>(
    context,
    kind: AppPopupKind.info,
    title: 'Appearance',
    message:
        'Choose how LifeCome Live looks. System default follows your '
        "phone's light or dark setting.",
    primaryLabel: 'Cancel',
    body: Column(
      children: [
        option(
          ThemeMode.system,
          Icons.brightness_auto_rounded,
          'System default',
        ),
        SizedBox(height: AppSpacing.xs),
        option(ThemeMode.light, Icons.light_mode_rounded, 'Light'),
        SizedBox(height: AppSpacing.xs),
        option(ThemeMode.dark, Icons.dark_mode_rounded, 'Dark'),
      ],
    ),
  );
}

class _AppPopupCard extends StatelessWidget {
  const _AppPopupCard({
    required this.kind,
    required this.title,
    required this.message,
    required this.primaryLabel,
    required this.secondaryLabel,
    required this.destructive,
    required this.body,
  });

  final AppPopupKind kind;
  final String title;
  final String message;
  final String primaryLabel;
  final String? secondaryLabel;
  final bool destructive;
  final Widget? body;

  @override
  Widget build(BuildContext context) {
    final style = _styles[kind]!;
    final kindColor = context.palette.adapt(style.color);
    final primaryColor = destructive ? AppColors.error : AppColors.blue;
    // Upload's primary action is "Cancel", so it pops null, not true.
    final primaryResult = body == null ? true : null;

    return SafeArea(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 380),
            child: Material(
              color: context.palette.elevated,
              borderRadius: BorderRadius.circular(28),
              elevation: 24,
              shadowColor: AppColors.ink.withValues(alpha: 0.25),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.lg,
                  AppSpacing.lg,
                  AppSpacing.lg,
                  AppSpacing.md,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 72,
                      height: 72,
                      decoration: BoxDecoration(
                        color: kindColor.withValues(alpha: 0.12),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: kindColor.withValues(alpha: 0.18),
                          width: 6,
                        ),
                      ),
                      child: Icon(style.icon, color: kindColor, size: 32),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Text(
                      title,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: context.palette.ink,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      message,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        height: 1.45,
                        color: context.palette.inkMuted,
                      ),
                    ),
                    if (body != null) ...[
                      const SizedBox(height: AppSpacing.md),
                      body!,
                    ],
                    const SizedBox(height: AppSpacing.lg),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: body == null
                          ? FilledButton(
                              onPressed: () =>
                                  Navigator.of(context).pop(primaryResult),
                              style: FilledButton.styleFrom(
                                backgroundColor: primaryColor,
                                shape: const StadiumBorder(),
                                textStyle: const TextStyle(
                                  fontFamily: appFontFamily,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              child: Text(primaryLabel),
                            )
                          : TextButton(
                              onPressed: () => Navigator.of(context).pop(),
                              style: TextButton.styleFrom(
                                foregroundColor: context.palette.inkMuted,
                                shape: const StadiumBorder(),
                              ),
                              child: Text(primaryLabel),
                            ),
                    ),
                    if (secondaryLabel != null) ...[
                      const SizedBox(height: AppSpacing.xxs),
                      SizedBox(
                        width: double.infinity,
                        height: 46,
                        child: TextButton(
                          onPressed: () => Navigator.of(context).pop(false),
                          style: TextButton.styleFrom(
                            foregroundColor: context.palette.inkMuted,
                            shape: const StadiumBorder(),
                          ),
                          child: Text(secondaryLabel!),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// One tappable choice in a popup; tapping it pops the popup with [value].
class _OptionTile<T> extends StatelessWidget {
  const _OptionTile({
    required this.value,
    required this.leading,
    required this.label,
    this.selected = false,
  });

  final T value;
  final Widget leading;
  final String label;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected
          ? AppColors.blue.withValues(alpha: 0.08)
          : context.palette.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.control),
        side: BorderSide(
          color: selected ? context.palette.accent : Colors.transparent,
          width: 1.5,
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadius.control),
        onTap: () => Navigator.of(context).pop(value),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm,
          ),
          child: Row(
            children: [
              leading,
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(fontSize: 15, color: context.palette.ink),
                ),
              ),
              Icon(
                selected
                    ? Icons.check_circle_rounded
                    : Icons.arrow_forward_ios_rounded,
                color: selected
                    ? context.palette.accent
                    : context.palette.inkMuted,
                size: selected ? 20 : 14,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
