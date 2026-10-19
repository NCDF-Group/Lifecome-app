import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/route_paths.dart';
import '../../../core/theme/app_palette.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/buttons/secondary_button.dart';
import '../../../core/widgets/layout/app_header_bar.dart';
import '../../../core/widgets/layout/document_preview.dart';
import '../../../core/widgets/layout/screen_title.dart';
import '../domain/models/clinical_note.dart';

/// A consultation record (screen pack 055), shown as the clinician wrote it.
class RecordDetailScreen extends StatelessWidget {
  const RecordDetailScreen({super.key, required this.note});

  final ClinicalNote note;

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
              title: 'Consultation record',
              subtitle: '${note.clinician} · ${Formatters.longDate(note.date)}',
            ),
            DocumentPreview(title: note.title, body: note.summary),
            SecondaryButton(
              label: 'Message your GP team',
              onPressed: () => context.go(RoutePaths.messages),
            ),
          ],
        ),
      ),
    );
  }
}
