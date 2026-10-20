import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lifecome_mobile/core/router/route_paths.dart';
import 'package:lifecome_mobile/features/shop/presentation/shop_checkout_screens.dart';
import 'package:lifecome_mobile/features/shop/presentation/shop_order_screens.dart';
import 'package:lifecome_mobile/features/shop/presentation/shop_screens.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../helpers/pump_app.dart';
import '../helpers/test_backend.dart';
import '../helpers/test_fonts.dart';

void main() {
  setUpAll(loadManrope);

  late TestBackend backend;

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    backend = TestBackend();
  });

  Finder field(int index) => find.byType(TextField).at(index);

  testWidgets('Wellbeing opens the shop, and filters work', (tester) async {
    await pumpAppAt(tester, RoutePaths.wellbeing, overrides: backend.overrides);
    await tapText(tester, 'Wellbeing Shop');
    expect(find.byType(ShopScreen), findsOneWidget);
    expect(find.text('Wellbeing journal'), findsOneWidget);

    await tapText(tester, 'Supplements');
    expect(find.text('Vitamin D3'), findsOneWidget);
    expect(find.text('Wellbeing journal'), findsNothing);

    await disposeApp(tester);
  });

  testWidgets('buy, track and return an order', (tester) async {
    await pumpAppAt(tester, RoutePaths.shop, overrides: backend.overrides);
    expect(find.text('View basket (0)'), findsOneWidget);

    await tapText(tester, 'Vitamin D3');
    await tapText(tester, 'Add to basket');
    await tapText(tester, 'Done');
    await tapText(tester, 'View basket (1)');
    expect(find.byType(ShopBasketScreen), findsOneWidget);

    // Two of them: £16.00 plus £3.95 delivery.
    await tester.tap(find.byTooltip('Add one Vitamin D3'));
    await tester.pump();
    expect(find.text('£19.95'), findsOneWidget);

    await tapText(tester, 'Continue to delivery');
    await tester.enterText(field(1), '12 Example Road');
    await tester.enterText(field(2), 'Leeds');
    await tester.enterText(field(3), 'LS1 4AB');
    await tapText(tester, 'Continue to payment');
    expect(find.byType(ShopPaymentScreen), findsOneWidget);
    await tapText(tester, 'Review order');

    await tapText(tester, 'Place order');
    expect(find.text('Please confirm to continue.'), findsOneWidget);
    await tester.tap(find.byType(Checkbox));
    await tester.pump();
    await tapText(tester, 'Place order');
    expect(find.byType(ShopConfirmedScreen), findsOneWidget);
    expect(find.textContaining('LC-SHOP-'), findsOneWidget);

    await tapText(tester, 'View your order');
    expect(find.byType(ShopOrderScreen), findsOneWidget);
    expect(find.text('Vitamin D3 × 2'), findsOneWidget);

    await tapText(tester, 'Track delivery');
    expect(find.text('On its way to you'), findsOneWidget);
    await tapBack(tester);

    await tapText(tester, 'Request a return');
    await tapText(tester, 'Send return request');
    expect(find.text('Please confirm to continue.'), findsOneWidget);
    await tester.tap(find.byType(Checkbox));
    await tester.pump();
    await tapText(tester, 'Send return request');
    expect(find.byType(ShopReturnSentScreen), findsOneWidget);
    expect(find.textContaining('LC-RET-'), findsOneWidget);

    await disposeApp(tester);
  });

  testWidgets('an empty basket says so', (tester) async {
    await pumpAppAt(
      tester,
      RoutePaths.shopBasket,
      overrides: backend.overrides,
    );
    expect(find.text('Your basket is empty'), findsOneWidget);

    await disposeApp(tester);
  });
}
