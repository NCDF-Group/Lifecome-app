import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lifecome_mobile/app.dart';
import 'package:lifecome_mobile/core/router/app_router.dart';
import 'package:lifecome_mobile/core/router/route_paths.dart';
import 'package:lifecome_mobile/features/services/domain/models/wellbeing_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../helpers/test_fonts.dart';

void main() {
  setUpAll(loadManrope);
  setUp(() => SharedPreferences.setMockInitialValues({}));

  test('each wellbeing service has its own hero photo', () {
    final paths = wellbeingServices.map((s) => s.heroImage).toList();
    expect(paths.toSet().length, paths.length);
  });

  testWidgets('every hero photo is bundled with the app', (tester) async {
    // The test bundle only holds what pubspec.yaml declares, so this also
    // catches a photo that was added but never registered as an asset.
    await tester.runAsync(() async {
      for (final service in wellbeingServices) {
        final data = await rootBundle.load(service.heroImage);
        expect(
          data.lengthInBytes,
          greaterThan(1024),
          reason: service.heroImage,
        );
      }
    });
  });

  for (final service in wellbeingServices) {
    testWidgets('${service.title} shows its hero photo', (tester) async {
      tester.view.physicalSize = const Size(390 * 2, 1400 * 2);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(const ProviderScope(child: LifeComeLiveApp()));
      await tester.pump();
      ProviderScope.containerOf(tester.element(find.byType(LifeComeLiveApp)))
          .read(appRouterProvider)
          .go(RoutePaths.wellbeingService, extra: service);
      await tester.pump(const Duration(milliseconds: 400));
      await tester.pump(const Duration(milliseconds: 400));

      expect(
        find.byWidgetPredicate(
          (widget) =>
              widget is Image &&
              widget.image is AssetImage &&
              (widget.image as AssetImage).assetName == service.heroImage,
        ),
        findsOneWidget,
      );

      // Let the splash screen's hold timer run out before the test ends.
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump(const Duration(seconds: 3));
    });
  }
}
