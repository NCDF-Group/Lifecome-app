import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_palette.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/feedback/app_popup.dart';
import '../../../core/widgets/layout/app_header_bar.dart';

/// "Find a Smart GP clinic" — search for an in-person clinic and book an
/// appointment there. No clinic directory backend exists yet, so this
/// shows a single sample London clinic rather than a real search result.
class FindSmartGpClinicScreen extends StatefulWidget {
  const FindSmartGpClinicScreen({super.key});

  @override
  State<FindSmartGpClinicScreen> createState() =>
      _FindSmartGpClinicScreenState();
}

class _FindSmartGpClinicScreenState extends State<FindSmartGpClinicScreen> {
  final _searchController = TextEditingController();
  String _location = 'London';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _changeLocation() async {
    final controller = TextEditingController(text: _location);
    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Your location'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(hintText: 'City or postcode'),
        ),
        actions: [
          TextButton(
            onPressed: () => context.pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => context.pop(controller.text.trim()),
            child: const Text('Save'),
          ),
        ],
      ),
    );
    if (result != null && result.isNotEmpty && mounted) {
      setState(() => _location = result);
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
            AppHeaderBar(showBack: true, onBack: () => context.pop()),
            const SizedBox(height: 20),
            Text(
              'Find a Smart GP clinic',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w600,
                color: context.palette.ink,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Search for a clinic near you and book an appointment in '
              'person.',
              style: TextStyle(
                fontSize: 14,
                color: context.palette.inkMuted,
                height: 1.4,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: context.palette.tintBlue,
                  child: Icon(
                    Icons.location_on_outlined,
                    color: context.palette.accent,
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Your location',
                        style: TextStyle(
                          fontSize: 13,
                          color: context.palette.inkMuted,
                        ),
                      ),
                      Text(
                        _location,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: context.palette.ink,
                        ),
                      ),
                    ],
                  ),
                ),
                TextButton(
                  onPressed: _changeLocation,
                  style: TextButton.styleFrom(
                    backgroundColor: context.palette.tintBlue,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppRadius.pill),
                    ),
                  ),
                  child: Text(
                    'Change',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: context.palette.accent,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            Container(
              decoration: BoxDecoration(
                color: context.palette.surface,
                borderRadius: BorderRadius.circular(AppRadius.control),
              ),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search area or postcode',
                  prefixIcon: Icon(
                    Icons.search,
                    color: context.palette.inkMuted,
                  ),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(vertical: AppSpacing.sm),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: context.palette.tintGreen,
                borderRadius: BorderRadius.circular(AppRadius.card),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 20,
                        backgroundColor: context.palette.elevated,
                        child: Icon(
                          Icons.apartment_outlined,
                          color: context.palette.positive,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'London clinic',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: context.palette.ink,
                              ),
                            ),
                            Text(
                              'Smart GP clinic',
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
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: AppSpacing.sm),
                    child: Divider(
                      height: 1,
                      color: context.palette.tintGreenLine,
                    ),
                  ),
                  _ClinicLinkRow(
                    icon: Icons.location_on_outlined,
                    label: 'View address and accessibility',
                    onTap: () => showComingSoonPopup(
                      context,
                      feature: 'Address and accessibility',
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  _ClinicLinkRow(
                    icon: Icons.calendar_month_outlined,
                    label: 'GP appointments',
                    subtitle: 'View available times.',
                    onTap: () => showComingSoonPopup(
                      context,
                      feature: 'GP appointments',
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Material(
              color: context.palette.tintBlue,
              borderRadius: BorderRadius.circular(AppRadius.card),
              child: InkWell(
                borderRadius: BorderRadius.circular(AppRadius.card),
                onTap: () => showComingSoonPopup(
                  context,
                  feature: 'Contacting patient support',
                ),
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 20,
                        backgroundColor: context.palette.elevated,
                        child: Icon(
                          Icons.chat_bubble_outline,
                          color: context.palette.accent,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Need help choosing?',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: context.palette.ink,
                              ),
                            ),
                            Text(
                              'Contact patient support.',
                              style: TextStyle(
                                fontSize: 12.5,
                                color: context.palette.inkMuted,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Icon(Icons.chevron_right, color: context.palette.accent),
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

class _ClinicLinkRow extends StatelessWidget {
  const _ClinicLinkRow({
    required this.icon,
    required this.label,
    required this.onTap,
    this.subtitle,
  });

  final IconData icon;
  final String label;
  final String? subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Row(
          children: [
            Icon(icon, size: 18, color: context.palette.positive),
            const SizedBox(width: AppSpacing.xs),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 14.5,
                      fontWeight: FontWeight.w600,
                      color: context.palette.ink,
                    ),
                  ),
                  if (subtitle != null)
                    Text(
                      subtitle!,
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
              size: 18,
              color: context.palette.positive,
            ),
          ],
        ),
      ),
    );
  }
}
