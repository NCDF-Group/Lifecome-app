import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lifecome_mobile/core/network/api_exception.dart';
import 'package:lifecome_mobile/core/router/route_paths.dart';
import 'package:lifecome_mobile/core/utils/formatters.dart';
import 'package:lifecome_mobile/features/emergency/presentation/emergency_guidance_screen.dart';
import 'package:lifecome_mobile/features/notifications/presentation/widgets/notifications_bell.dart';
import 'package:lifecome_mobile/features/messaging/domain/models/message_thread.dart';
import 'package:lifecome_mobile/features/messaging/presentation/message_threads_screen.dart';
import 'package:lifecome_mobile/features/messaging/presentation/new_message_screen.dart';
import 'package:lifecome_mobile/features/messaging/presentation/thread_detail_screen.dart';
import 'package:lifecome_mobile/features/profile/presentation/edit_profile_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../helpers/fake_messaging_repository.dart';
import '../helpers/fake_notifications_repository.dart';
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

  final sendButton = find.byIcon(Icons.arrow_upward_rounded);

  // Fixed instants, so the UK clock times and the day label are certain:
  // 9:00 and 9:30 UTC on 12 October 2026 are 10:00 and 10:30 BST.
  ThreadMessage mine() => ThreadMessage(
    id: 'm-1',
    threadId: 'thread-1',
    fromPatient: true,
    body: 'Can I move my appointment to Friday?',
    sentAt: DateTime.utc(2026, 10, 12, 9, 0),
  );
  ThreadMessage theirs() => ThreadMessage(
    id: 'm-2',
    threadId: 'thread-1',
    fromPatient: false,
    body: 'Yes, Friday morning works. We have moved it for you.',
    sentAt: DateTime.utc(2026, 10, 12, 9, 30),
  );

  void withConversation() {
    backend.messaging
      ..threads = [testThread()]
      ..messages = {
        'thread-1': [mine(), theirs()],
      };
  }

  group('Messages tab', () {
    testWidgets('says honestly that there are no messages yet', (tester) async {
      await pumpAppAt(
        tester,
        RoutePaths.messages,
        overrides: backend.overrides,
      );

      expect(find.byType(MessageThreadsScreen), findsOneWidget);
      expect(find.text('No messages yet'), findsOneWidget);
      expect(find.text('New message'), findsOneWidget);
      // Nothing is pre-filled or invented.
      expect(find.textContaining('Dr '), findsNothing);
      expect(find.byType(CircleAvatar), findsNothing);

      await disposeApp(tester);
    });

    testWidgets('lists the real conversations, most recent first', (
      tester,
    ) async {
      backend.messaging.threads = [
        testThread(
          id: 'old',
          topic: MessageTopic.clinicVisit,
          lastMessage: 'Where do I park?',
          age: const Duration(days: 5),
        ),
        testThread(
          id: 'new',
          topic: MessageTopic.bookingPayments,
          lastMessage: 'Can I move my appointment to Friday?',
          age: const Duration(minutes: 20),
        ),
      ];
      await pumpAppAt(
        tester,
        RoutePaths.messages,
        overrides: backend.overrides,
      );

      expect(find.text('No messages yet'), findsNothing);
      expect(find.text('Booking and payments'), findsOneWidget);
      expect(find.text('Clinic visit'), findsOneWidget);
      expect(find.text('Can I move my appointment to Friday?'), findsOneWidget);
      expect(find.text('20 minutes ago'), findsOneWidget);
      expect(
        tester.getTopLeft(find.text('Booking and payments')).dy,
        lessThan(tester.getTopLeft(find.text('Clinic visit')).dy),
      );

      await disposeApp(tester);
    });

    testWidgets('shows an error with a retry when they cannot load', (
      tester,
    ) async {
      backend.messaging.listFailure = const ApiException(
        ApiException.networkMessage,
      );
      await pumpAppAt(
        tester,
        RoutePaths.messages,
        overrides: backend.overrides,
      );
      expect(find.text("You're offline"), findsOneWidget);

      backend.messaging.listFailure = null;
      backend.messaging.threads = [testThread()];
      await tapText(tester, 'Try again');
      expect(find.text('Booking and payments'), findsOneWidget);

      await disposeApp(tester);
    });

    testWidgets('urgent help goes to the emergency guidance', (tester) async {
      await pumpAppAt(
        tester,
        RoutePaths.messages,
        overrides: backend.overrides,
      );
      await tapText(tester, 'Need urgent help?');
      expect(find.byType(EmergencyGuidanceScreen), findsOneWidget);

      await tapBack(tester);
      expect(find.byType(MessageThreadsScreen), findsOneWidget);

      await disposeApp(tester);
    });
  });

  group('a conversation', () {
    testWidgets('shows both sides of it, in UK time', (tester) async {
      withConversation();
      await pumpAppAt(
        tester,
        RoutePaths.messages,
        overrides: backend.overrides,
      );
      await tapText(tester, 'Booking and payments');

      expect(find.byType(ThreadDetailScreen), findsOneWidget);
      expect(find.text('Can I move my appointment to Friday?'), findsWidgets);
      expect(
        find.text('Yes, Friday morning works. We have moved it for you.'),
        findsOneWidget,
      );
      expect(find.text('Care team'), findsOneWidget);
      expect(find.text('10:00'), findsOneWidget);
      expect(find.text('10:30'), findsOneWidget);
      // One day label for the two messages on that day.
      expect(
        find.text(Formatters.dayLabel(DateTime(2026, 10, 12))),
        findsOneWidget,
      );

      await disposeApp(tester);
    });

    testWidgets('sending adds the message and tells the backend', (
      tester,
    ) async {
      withConversation();
      await pumpAppAt(
        tester,
        RoutePaths.messages,
        overrides: backend.overrides,
      );
      await tapText(tester, 'Booking and payments');

      await tester.enterText(find.byType(TextField), '  Thank you!  ');
      await tester.pump();
      await tester.tap(sendButton);
      await settle(tester);

      expect(backend.messaging.calls, contains('sendMessage:thread-1'));
      // The text is trimmed before it is sent.
      expect(backend.messaging.lastBody, 'Thank you!');
      expect(find.text('Thank you!'), findsOneWidget);
      expect(
        tester.widget<TextField>(find.byType(TextField)).controller!.text,
        isEmpty,
      );

      await disposeApp(tester);
    });

    testWidgets('an empty message cannot be sent', (tester) async {
      withConversation();
      await pumpAppAt(
        tester,
        RoutePaths.messages,
        overrides: backend.overrides,
      );
      await tapText(tester, 'Booking and payments');

      await tester.tap(sendButton);
      await settle(tester);
      await tester.enterText(find.byType(TextField), '   ');
      await tester.pump();
      await tester.tap(sendButton);
      await settle(tester);

      expect(
        backend.messaging.calls.where((call) => call.startsWith('sendMessage')),
        isEmpty,
      );

      await disposeApp(tester);
    });

    testWidgets('a message over the limit says so and is not sent', (
      tester,
    ) async {
      withConversation();
      await pumpAppAt(
        tester,
        RoutePaths.messages,
        overrides: backend.overrides,
      );
      await tapText(tester, 'Booking and payments');

      await tester.enterText(find.byType(TextField), 'a' * 4001);
      await tester.pump();
      expect(
        find.text('Keep this to 4000 characters or fewer (it is 4001 now).'),
        findsOneWidget,
      );
      await tester.tap(sendButton);
      await settle(tester);
      expect(
        backend.messaging.calls.where((call) => call.startsWith('sendMessage')),
        isEmpty,
      );

      await disposeApp(tester);
    });

    testWidgets('a message that cannot be sent keeps what was typed', (
      tester,
    ) async {
      withConversation();
      backend.messaging.sendFailure = const ApiException(
        ApiException.networkMessage,
      );
      await pumpAppAt(
        tester,
        RoutePaths.messages,
        overrides: backend.overrides,
      );
      await tapText(tester, 'Booking and payments');

      await tester.enterText(find.byType(TextField), 'Are you there?');
      await tester.pump();
      await tester.tap(sendButton);
      await settle(tester);

      expect(find.text("You're offline"), findsOneWidget);
      await tapText(tester, 'OK');
      expect(
        tester.widget<TextField>(find.byType(TextField)).controller!.text,
        'Are you there?',
      );

      await disposeApp(tester);
    });

    testWidgets("picks up the care team's reply while it is open", (
      tester,
    ) async {
      withConversation();
      await pumpAppAt(
        tester,
        RoutePaths.messages,
        overrides: backend.overrides,
      );
      await tapText(tester, 'Booking and payments');

      backend.messaging.reply('thread-1', 'One more thing: bring your card.');
      await tester.pump(const Duration(seconds: 11));
      await settle(tester);

      expect(find.text('One more thing: bring your card.'), findsOneWidget);

      await disposeApp(tester);
    });

    testWidgets('a conversation that cannot load has a retry', (tester) async {
      withConversation();
      backend.messaging.messagesFailure = const ApiException(
        ApiException.networkMessage,
      );
      await pumpAppAt(
        tester,
        RoutePaths.messages,
        overrides: backend.overrides,
      );
      await tapText(tester, 'Booking and payments');
      expect(find.byType(ThreadDetailScreen), findsOneWidget);
      expect(find.text("You're offline"), findsOneWidget);

      backend.messaging.messagesFailure = null;
      await tapText(tester, 'Try again');
      expect(
        find.text('Yes, Friday morning works. We have moved it for you.'),
        findsOneWidget,
      );

      await tapBack(tester);
      expect(find.byType(MessageThreadsScreen), findsOneWidget);

      await disposeApp(tester);
    });

    testWidgets('opened with nothing behind it, back goes to Messages', (
      tester,
    ) async {
      withConversation();
      await pumpAppAt(
        tester,
        '${RoutePaths.messageThread}/thread-1',
        overrides: backend.overrides,
      );
      expect(find.byType(ThreadDetailScreen), findsOneWidget);

      await tapBack(tester);
      expect(find.byType(MessageThreadsScreen), findsOneWidget);

      await disposeApp(tester);
    });
  });

  group('new message', () {
    testWidgets('needs a topic and a message before it is sent', (
      tester,
    ) async {
      await pumpAppAt(
        tester,
        RoutePaths.messages,
        overrides: backend.overrides,
      );
      await tapText(tester, 'New message');
      expect(find.byType(NewMessageScreen), findsOneWidget);

      await tapText(tester, 'Send message');
      expect(find.text('Choose what you need help with.'), findsOneWidget);
      expect(find.text('Enter a message.'), findsOneWidget);
      expect(backend.messaging.calls, isNot(contains('createThread')));

      // The errors clear as the form is filled in.
      await tapText(tester, 'Clinic visit');
      await tester.enterText(find.byType(TextField), 'Where do I park?');
      await tester.pump();
      expect(find.text('Choose what you need help with.'), findsNothing);
      expect(find.text('Enter a message.'), findsNothing);

      await disposeApp(tester);
    });

    testWidgets('sends the first message and opens the conversation', (
      tester,
    ) async {
      await pumpAppAt(
        tester,
        RoutePaths.messages,
        overrides: backend.overrides,
      );
      await tapText(tester, 'New message');

      await tapText(tester, 'Clinic visit');
      await tester.enterText(find.byType(TextField), '  Where do I park?  ');
      await tester.pump();
      await tapText(tester, 'Send message');

      expect(backend.messaging.lastTopic, MessageTopic.clinicVisit);
      expect(backend.messaging.lastBody, 'Where do I park?');
      expect(find.byType(ThreadDetailScreen), findsOneWidget);
      expect(find.text('Where do I park?'), findsWidgets);

      // Back lands on the Messages tab, which now lists it.
      await tapBack(tester);
      expect(find.byType(MessageThreadsScreen), findsOneWidget);
      expect(find.text('No messages yet'), findsNothing);

      await disposeApp(tester);
    });

    testWidgets('a person without a profile is sent to finish it', (
      tester,
    ) async {
      backend.messaging.createFailure = const ApiException(
        'Complete your profile before continuing.',
        code: 'PROFILE_REQUIRED',
        statusCode: 403,
      );
      await pumpAppAt(
        tester,
        RoutePaths.messages,
        overrides: backend.overrides,
      );
      await tapText(tester, 'New message');
      await tapText(tester, 'Follow-up');
      await tester.enterText(find.byType(TextField), 'About my last visit');
      await tester.pump();
      await tapText(tester, 'Send message');

      expect(find.text('Finish your profile first'), findsOneWidget);
      await tapText(tester, 'Complete profile');
      expect(find.byType(EditProfileScreen), findsOneWidget);

      await disposeApp(tester);
    });

    testWidgets('"not now" leaves the message where it was', (tester) async {
      backend.messaging.createFailure = const ApiException(
        'Complete your profile before continuing.',
        code: 'PROFILE_REQUIRED',
        statusCode: 403,
      );
      await pumpAppAt(
        tester,
        RoutePaths.messages,
        overrides: backend.overrides,
      );
      await tapText(tester, 'New message');
      await tapText(tester, 'Follow-up');
      await tester.enterText(find.byType(TextField), 'About my last visit');
      await tester.pump();
      await tapText(tester, 'Send message');

      await tapText(tester, 'Not now');
      expect(find.byType(NewMessageScreen), findsOneWidget);
      expect(find.byType(EditProfileScreen), findsNothing);
      expect(find.text('About my last visit'), findsOneWidget);

      await disposeApp(tester);
    });

    testWidgets('a failure keeps what was written', (tester) async {
      backend.messaging.createFailure = const ApiException(
        ApiException.networkMessage,
      );
      await pumpAppAt(
        tester,
        RoutePaths.messages,
        overrides: backend.overrides,
      );
      await tapText(tester, 'New message');
      await tapText(tester, 'Online appointment');
      await tester.enterText(find.byType(TextField), 'My link will not open');
      await tester.pump();
      await tapText(tester, 'Send message');

      expect(find.text("You're offline"), findsOneWidget);
      await tapText(tester, 'OK');
      expect(find.byType(NewMessageScreen), findsOneWidget);
      expect(find.text('My link will not open'), findsOneWidget);

      await disposeApp(tester);
    });

    testWidgets('has a back button, even when opened with nothing behind it', (
      tester,
    ) async {
      await pumpAppAt(
        tester,
        RoutePaths.newMessage,
        overrides: backend.overrides,
      );
      expect(find.byType(NewMessageScreen), findsOneWidget);

      await tapBack(tester);
      expect(find.byType(MessageThreadsScreen), findsOneWidget);

      await disposeApp(tester);
    });
  });

  group('from a notification', () {
    testWidgets('a reply notification opens that conversation', (tester) async {
      withConversation();
      backend.notifications.items = [testMessageNotification()];
      await pumpAppAt(
        tester,
        RoutePaths.services,
        overrides: backend.overrides,
      );

      await tester.tap(find.byType(NotificationsBell));
      await settle(tester);
      await tapText(tester, 'Sent you a Message');

      expect(backend.notifications.calls, contains('markRead:n-message'));
      expect(find.byType(ThreadDetailScreen), findsOneWidget);
      expect(
        find.text('Yes, Friday morning works. We have moved it for you.'),
        findsOneWidget,
      );

      await tapBack(tester);
      expect(find.byType(MessageThreadsScreen), findsOneWidget);

      await disposeApp(tester);
    });
  });
}
