import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/route_paths.dart';
import '../../../core/theme/app_palette.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/buttons/secondary_button.dart';
import '../../../core/widgets/feedback/status_chip.dart';
import '../../../core/widgets/layout/app_header_bar.dart';
import '../../../core/widgets/layout/document_preview.dart';
import '../../../core/widgets/layout/screen_title.dart';
import '../domain/models/diagnostic_result.dart';

/// One test result (screen pack 061): the verified report and the
/// clinician's interpretation, exactly as shared.
class DiagnosticResultScreen extends StatelessWidget {
  const DiagnosticResultScreen({super.key, required this.result});

  final DiagnosticResult result;

  @override
  Widget build(BuildContext context) {
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
              title: result.title,
              subtitle:
                  'Reviewed by ${result.reviewedBy} · '
                  '${Formatters.longDate(result.date)}',
            ),
            const SizedBox(height: 12),
            const StatusBadge('Reviewed'),
            DocumentPreview(title: 'Result report', body: result.report),
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
