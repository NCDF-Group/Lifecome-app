import 'dart:io';

import 'package:flutter/services.dart';

/// Registers the bundled Manrope weights so a widget test lays text out with
/// real glyph widths. Without it Flutter's test environment falls back to a
/// fixed-width placeholder font whose glyphs are far wider than Manrope's,
/// which makes ordinary rows report layout overflows that don't exist.
Future<void> loadManrope() async {
  final loader = FontLoader('Manrope');
  for (final weight in ['Regular', 'Medium', 'SemiBold', 'Bold', 'ExtraBold']) {
    final bytes = File('assets/fonts/Manrope/Manrope-$weight.ttf')
        .readAsBytesSync();
    loader.addFont(Future.value(ByteData.sublistView(bytes)));
  }
  await loader.load();
}
