import 'package:flutter/material.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';
import 'package:lifecome_mobile/core/network/api_exception.dart';
import 'package:lifecome_mobile/core/providers/core_providers.dart';
import 'package:lifecome_mobile/core/router/route_paths.dart';
import 'package:lifecome_mobile/core/storage/secure_storage.dart';
import 'package:lifecome_mobile/features/booking/presentation/my_visits_screen.dart';
import 'package:lifecome_mobile/features/notifications/application/notifications_controller.dart';
import 'package:lifecome_mobile/features/notifications/presentation/notifications_screen.dart';
import 'package:lifecome_mobile/features/profile/application/profile_controller.dart';
import 'package:lifecome_mobile/features/notifications/presentation/widgets/notifications_bell.dart';
import 'package:lifecome_mobile/features/wellbeing/presentation/wellbeing_screens.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../helpers/fake_auth_repository.dart';
import '../helpers/fake_notifications_repository.dart';
import '../helpers/fake_profile_repository.dart';
import '../helpers/pump_app.dart';
import '../helpers/test_fonts.dart';

void main() {
  setUpAll(loadManrope);

  late FakeNotificationsRepository feed;
  late List<Override> overrides;

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    feed = FakeNotificationsRepository();
    overrides = [
      authRepositoryProvider.overrideWithValue(FakeAuthRepository()),
      tokenStoreProvider.overrideWithValue(MemoryTokenStore()),
      profileRepositoryProvider.overrideWithValue(FakeProfileRepository()),
      notificationsRepositoryProvider.overrideWithValue(feed),
    ];
  });

  final bell = find.byType(NotificationsBell);
  final dot = find.byKey(const ValueKey('unread-dot'));

  Future<void> openBell(WidgetTester tester) async {
    await tester.tap(bell);
    await settle(tester);
  }

  testWidgets('the bell has no dot when there is nothing unread', (
    tester,
  ) async {
    feed.items = [testBookingNotification(read: true)];
    await pumpAppAt(tester, RoutePaths.wellbeing, overrides: overrides);

    expect(find.byType(WellbeingHubScreen), findsOneWidget);
    expect(bell, findsOneWidget);
    expect(dot, findsNothing);

    await disposeApp(tester);
  });

  testWidgets('shows what the backend says is unread, and reading clears it', (
    tester,
  ) async {
    feed.items = [testBookingNotification(), testMessageNotification()];
    await pumpAppAt(tester, RoutePaths.wellbeing, overrides: overrides);
    expect(dot, findsOneWidget);

    await openBell(tester);
    expect(find.byType(NotificationsScreen), findsOneWidget);
    expect(
      find.textContaining(
        'Your booking with Dr Sam Okoro has been confirmed',
        findRichText: true,
      ),
      findsOneWidget,
    );
    expect(find.text('View Booking'), findsOneWidget);
    expect(find.text('Sent you a Message'), findsOneWidget);
    expect(
      find.text('Thanks for getting in touch. We have updated your plan.'),
      findsOneWidget,
    );
    expect(find.text('5 minutes ago'), findsOneWidget);
    expect(find.text('Mark all read'), findsOneWidget);

    // Opening the booking marks it read and goes to My Visits.
    await tester.tap(find.text('View Booking'));
    await settle(tester);
    expect(feed.calls, contains('markRead:n-booking'));
    expect(find.byType(MyVisitsScreen), findsOneWidget);

    await disposeApp(tester);
  });

  testWidgets('mark all read tells the backend and clears the dot', (
    tester,
  ) async {
    feed.items = [testBookingNotification(), testMessageNotification()];
    await pumpAppAt(tester, RoutePaths.wellbeing, overrides: overrides);

    await openBell(tester);
    await tester.tap(find.text('Mark all read'));
    await settle(tester);

    expect(feed.calls, contains('markAllRead'));
    expect(find.text('Mark all read'), findsNothing);

    await tapBack(tester);
    expect(find.byType(WellbeingHubScreen), findsOneWidget);
    expect(dot, findsNothing);

    await disposeApp(tester);
  });

  testWidgets('an empty feed says so honestly', (tester) async {
    await pumpAppAt(tester, RoutePaths.wellbeing, overrides: overrides);

    await openBell(tester);
    expect(find.text("You're all caught up"), findsOneWidget);
    expect(find.text('Mark all read'), findsNothing);

    await disposeApp(tester);
  });

  testWidgets('a feed that cannot load shows an error with a retry', (
    tester,
  ) async {
    feed.loadFailure = const ApiException(ApiException.networkMessage);
    await pumpAppAt(tester, RoutePaths.wellbeing, overrides: overrides);
    expect(dot, findsNothing);

    await openBell(tester);
    expect(find.text("You're offline"), findsOneWidget);

    feed.loadFailure = null;
    feed.items = [testMessageNotification()];
    await tapText(tester, 'Try again');
    expect(find.text('Sent you a Message'), findsOneWidget);

    await disposeApp(tester);
  });

  testWidgets('has a back button, even when opened with nothing behind it', (
    tester,
  ) async {
    await pumpAppAt(tester, RoutePaths.notifications, overrides: overrides);
    expect(find.byType(NotificationsScreen), findsOneWidget);

    await tapBack(tester);
    expect(find.byType(NotificationsScreen), findsNothing);

    await disposeApp(tester);
  });
}
