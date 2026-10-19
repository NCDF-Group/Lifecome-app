import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/route_paths.dart';
import '../../../core/theme/app_palette.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/buttons/secondary_button.dart';
import '../../../core/widgets/layout/app_header_bar.dart';
import '../../../core/widgets/layout/detail_list.dart';
import '../../../core/widgets/layout/document_preview.dart';
import '../../../core/widgets/layout/screen_title.dart';
import '../domain/models/prescription.dart';

/// One prescription (screen pack 057): its reference, status and pharmacy,
/// and the clinician's directions as written.
class PrescriptionDetailScreen extends StatelessWidget {
  const PrescriptionDetailScreen({super.key, required this.prescription});

  final Prescription prescription;

  @override
  Widget build(BuildContext context) {
    final rx = prescription;
    return Scaffold(
      backgroundColor: context.palette.background,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 25),
          children: [
            const AppHeaderBar(
              showBack: true,
              backFallback: RoutePaths.healthRecords,
            ),
            const SizedBox(height: 4),
            ScreenTitle(
              title: 'Prescription record',
              subtitle: 'Issued ${Formatters.longDate(rx.issuedOn)}',
            ),
            const SizedBox(height: 10),
            DetailList(
              rows: [
                ('Reference', rx.reference),
                ('Clinician', rx.clinician),
                ('Status', rx.status),
                ('Medicine', rx.medicine ?? 'Not recorded'),
                ('Pharmacy', rx.pharmacy ?? 'Not selected'),
              ],
            ),
            if (rx.instructions != null)
              DocumentPreview(title: 'Directions', body: rx.instructions!),
            const SizedBox(height: 8),
            SecondaryButton(
              label: 'Ask your care team',
              onPressed: () => context.go(RoutePaths.messages),
            ),
          ],
        ),
      ),
    );
  }
}
