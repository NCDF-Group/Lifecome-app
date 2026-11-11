import 'package:flutter/material.dart';
import 'package:lifecome_mobile/core/theme/app_icons.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/route_paths.dart';
import '../../../core/theme/app_palette.dart';
import '../../../core/widgets/buttons/primary_button.dart';
import '../../../core/widgets/feedback/info_banner.dart';
import '../../../core/widgets/inputs/choice_card.dart';
import '../../../core/widgets/layout/app_header_bar.dart';
import '../../../core/widgets/layout/screen_title.dart';
import '../../../core/widgets/layout/section_header.dart';
import '../../../core/widgets/lists/row_card.dart';
import '../../../core/widgets/media/lc_icons.dart';

/// Content in this catalogue is illustrative until test booking is connected
/// to a clinical service and payment provider.
class TestService {
  const TestService({
    required this.id,
    required this.title,
    required this.summary,
    required this.description,
    required this.icon,
    this.price = 'Price confirmed after clinical review',
    this.adultOnly = false,
  });

  final String id;
  final String title;
  final String summary;
  final String description;
  final String icon;
  final String price;
  final bool adultOnly;
}

const testServices = <TestService>[
  TestService(
    id: 'general-health',
    title: 'General Health Checks',
    summary: 'A broad picture of key health markers',
    description:
        'A clinician can help choose checks based on your health history, '
        'needs and the questions you want answered.',
    icon: LcIcons.heart,
  ),
  TestService(
    id: 'diabetes-cholesterol',
    title: 'Diabetes & Cholesterol',
    summary: 'Checks that may help assess metabolic health',
    description:
        'A clinician will explain which measurements are useful for you and '
        'whether a blood sample or another assessment is appropriate.',
    icon: LcIcons.check,
  ),
  TestService(
    id: 'sexual-health',
    title: 'Sexual Health Check',
    summary: 'Discreet options for adults aged 18 and over',
    description:
        'Depending on your history, a clinician may recommend urine, swab or '
        'blood tests for infections such as chlamydia, gonorrhoea, HIV or '
        'syphilis. The right tests depend on your circumstances.',
    icon: LcIcons.lock,
    price: 'Illustrative price from £35',
    adultOnly: true,
  ),
  TestService(
    id: 'blood-urine',
    title: 'Blood & Urine Tests',
    summary: 'Explore common sample-based tests',
    description:
        'A clinician will discuss the reason for testing, sample type, '
        'preparation and where your sample can be collected.',
    icon: LcIcons.plus,
  ),
  TestService(
    id: 'heart-breathing',
    title: 'Heart & Breathing',
    summary: 'Discuss checks for cardiovascular and respiratory health',
    description:
        'A clinician can help decide whether a test or an appointment is the '
        'best next step for your symptoms and health history.',
    icon: LcIcons.heart,
  ),
];

TestService testServiceFor(String? id) => testServices.firstWhere(
  (service) => service.id == id,
  orElse: () => testServices.first,
);

String _servicePath(String path, String id) =>
    '$path?service=${Uri.encodeComponent(id)}';

/// A test overview and route into clinical suitability questions.
class TestServiceScreen extends StatelessWidget {
  const TestServiceScreen({super.key, required this.serviceId});

  final String serviceId;

  @override
  Widget build(BuildContext context) {
    final service = testServiceFor(serviceId);
    return _TestPage(
      backFallback: RoutePaths.tests,
      children: [
        ScreenTitle(
          eyebrow: 'Tests & Health Checks',
          title: service.title,
          subtitle: service.summary,
        ),
        const SizedBox(height: 10),
        InfoBanner(message: service.description),
        const SectionHeader(title: 'Before you continue'),
        const _Bullet(
          text: 'A clinician reviews your answers and confirms suitability.',
        ),
        const _Bullet(
          text: 'The sample type and preparation depend on the test.',
        ),
        const _Bullet(
          text: 'You will see any confirmed fee before making a decision.',
        ),
        if (service.adultOnly) ...[
          const SizedBox(height: 8),
          const InfoBanner(
            tone: BannerTone.warning,
            message:
                'This example service is for adults aged 18 and over. '
                'Symptoms or a recent exposure should be reviewed by a clinician.',
          ),
        ],
        const SizedBox(height: 14),
        PrimaryButton(
          label: 'Check if this may be suitable',
          onPressed: () => context.push(
            _servicePath(RoutePaths.testSuitability, service.id),
          ),
        ),
        const SizedBox(height: 8),
        Center(
          child: Text(
            service.price,
            style: TextStyle(fontSize: 12.5, color: context.palette.inkMuted),
          ),
        ),
      ],
    );
  }
}

/// Short safety and suitability check before the sample booking preview.
class TestSuitabilityScreen extends StatefulWidget {
  const TestSuitabilityScreen({super.key, required this.serviceId});

  final String serviceId;

  @override
  State<TestSuitabilityScreen> createState() => _TestSuitabilityScreenState();
}

class _TestSuitabilityScreenState extends State<TestSuitabilityScreen> {
  bool _understandsReview = false;
  bool _adultConfirmed = false;

  @override
  Widget build(BuildContext context) {
    final service = testServiceFor(widget.serviceId);
    final canContinue =
        _understandsReview && (!service.adultOnly || _adultConfirmed);
    return _TestPage(
      backFallback: RoutePaths.testService.replaceFirst(
        ':serviceId',
        service.id,
      ),
      children: [
        const ScreenTitle(
          eyebrow: 'Suitability',
          title: 'A few things to check',
          subtitle: 'This helps a clinician understand what support you need.',
        ),
        const SizedBox(height: 8),
        InfoBanner(
          tone: BannerTone.warning,
          title: 'Need urgent help?',
          message:
              'This service is not for emergencies. Call 999 for an emergency '
              'or use NHS 111 for urgent medical advice.',
          actionLabel: 'Urgent help options',
          onAction: () => context.push(RoutePaths.emergency),
        ),
        if (service.adultOnly)
          CheckRow(
            value: _adultConfirmed,
            onChanged: (value) => setState(() => _adultConfirmed = value),
            label: 'I confirm that I am aged 18 or over.',
          ),
        CheckRow(
          value: _understandsReview,
          onChanged: (value) => setState(() => _understandsReview = value),
          label:
              'I understand that a clinician must review my answers and may '
              'recommend a different next step.',
        ),
        const SizedBox(height: 14),
        PrimaryButton(
          label: 'Continue',
          onPressed: canContinue
              ? () => context.push(
                  _servicePath(RoutePaths.testContact, service.id),
                )
              : null,
        ),
      ],
    );
  }
}

enum TestJourneyStep { contact, appointment, payment, review, confirmation }

/// A locally held, non-submitting preview of the remaining booking steps.
class TestJourneyScreen extends StatefulWidget {
  const TestJourneyScreen({
    super.key,
    required this.serviceId,
    required this.step,
    this.selection = '',
    this.contactSelection = '',
    this.appointmentSelection = '',
    this.paymentSelection = '',
  });

  final String serviceId;
  final TestJourneyStep step;
  final String selection;
  final String contactSelection;
  final String appointmentSelection;
  final String paymentSelection;

  @override
  State<TestJourneyScreen> createState() => _TestJourneyScreenState();
}

class _TestJourneyScreenState extends State<TestJourneyScreen> {
  String _selection = '';

  String _nextPath(TestJourneyStep next) {
    final path = switch (next) {
      TestJourneyStep.contact => RoutePaths.testContact,
      TestJourneyStep.appointment => RoutePaths.testAppointment,
      TestJourneyStep.payment => RoutePaths.testPayment,
      TestJourneyStep.review => RoutePaths.testReview,
      TestJourneyStep.confirmation => RoutePaths.testConfirmation,
    };
    final contact = widget.step == TestJourneyStep.contact
        ? _selection
        : widget.contactSelection;
    final appointment = widget.step == TestJourneyStep.appointment
        ? _selection
        : widget.appointmentSelection;
    final payment = widget.step == TestJourneyStep.payment
        ? _selection
        : widget.paymentSelection;
    return Uri(
      path: path,
      queryParameters: {
        'service': widget.serviceId,
        if (contact.isNotEmpty) 'contact': contact,
        if (appointment.isNotEmpty) 'appointment': appointment,
        if (payment.isNotEmpty) 'payment': payment,
      },
    ).toString();
  }

  String get _backPath => switch (widget.step) {
    TestJourneyStep.contact => RoutePaths.testService.replaceFirst(
      ':serviceId',
      widget.serviceId,
    ),
    TestJourneyStep.appointment => _nextPath(TestJourneyStep.contact),
    TestJourneyStep.payment => _nextPath(TestJourneyStep.appointment),
    TestJourneyStep.review => _nextPath(TestJourneyStep.payment),
    TestJourneyStep.confirmation => _nextPath(TestJourneyStep.review),
  };

  @override
  void initState() {
    super.initState();
    _selection = widget.selection;
  }

  @override
  Widget build(BuildContext context) {
    final service = testServiceFor(widget.serviceId);
    switch (widget.step) {
      case TestJourneyStep.contact:
        return _optionsPage(
          service: service,
          title: 'How should we contact you?',
          subtitle: 'Your choice is used for this preview only.',
          options: const [
            ('Email', 'Send updates to the email on your account'),
            ('Text message', 'Use the mobile number on your account'),
            ('Phone call', 'A care team member can call you'),
          ],
          next: TestJourneyStep.appointment,
          nextLabel: 'Choose an appointment',
        );
      case TestJourneyStep.appointment:
        return _optionsPage(
          service: service,
          title: 'Choose a sample appointment',
          subtitle: 'Availability is illustrative and not live.',
          options: const [
            ('Tuesday, 10:30 am', 'Local sample collection · 20 minutes'),
            ('Wednesday, 2:00 pm', 'Local sample collection · 20 minutes'),
            ('Friday, 9:15 am', 'Local sample collection · 20 minutes'),
          ],
          next: TestJourneyStep.payment,
          nextLabel: 'Continue to payment options',
        );
      case TestJourneyStep.payment:
        return _optionsPage(
          service: service,
          title: 'How will you access this service?',
          subtitle: 'The final price and cover need to be confirmed first.',
          options: const [
            ('Self-pay', 'Illustrative fee from £35'),
            (
              'Membership or employer benefits',
              'Check your available benefits',
            ),
            ('Existing insurance', 'Check cover with your insurer'),
          ],
          next: TestJourneyStep.review,
          nextLabel: 'Review request',
        );
      case TestJourneyStep.review:
        return _reviewPage(service);
      case TestJourneyStep.confirmation:
        return _confirmationPage(service);
    }
  }

  Widget _optionsPage({
    required TestService service,
    required String title,
    required String subtitle,
    required List<(String, String)> options,
    required TestJourneyStep next,
    required String nextLabel,
  }) {
    final canContinue = _selection.isNotEmpty;
    return _TestPage(
      backFallback: _backPath,
      children: [
        ScreenTitle(eyebrow: service.title, title: title, subtitle: subtitle),
        const SizedBox(height: 8),
        for (final (option, detail) in options)
          ChoiceCard(
            title: option,
            subtitle: detail,
            selected: _selection == option,
            onTap: () => setState(() => _selection = option),
          ),
        const SizedBox(height: 14),
        PrimaryButton(
          label: nextLabel,
          onPressed: canContinue ? () => context.push(_nextPath(next)) : null,
        ),
      ],
    );
  }

  Widget _reviewPage(TestService service) => _TestPage(
    backFallback: _backPath,
    children: [
      ScreenTitle(
        eyebrow: 'Review',
        title: 'Check your request',
        subtitle: 'Confirm the details before you continue.',
      ),
      const SizedBox(height: 8),
      _SummaryCard(title: 'Service', value: service.title),
      _SummaryCard(
        title: 'Contact preference',
        value: widget.contactSelection.isEmpty
            ? 'Not selected'
            : widget.contactSelection,
      ),
      _SummaryCard(
        title: 'Sample appointment',
        value: widget.appointmentSelection.isEmpty
            ? 'Not selected'
            : widget.appointmentSelection,
      ),
      _SummaryCard(
        title: 'Payment route',
        value: widget.paymentSelection.isEmpty
            ? 'Not selected'
            : widget.paymentSelection,
      ),
      const SizedBox(height: 8),
      const InfoBanner(
        tone: BannerTone.warning,
        message:
            'This is a preview. No appointment will be booked, no payment '
            'will be taken and no information will be sent.',
      ),
      const SizedBox(height: 14),
      PrimaryButton(
        label: 'Confirm preview request',
        onPressed: () => context.push(_nextPath(TestJourneyStep.confirmation)),
      ),
    ],
  );

  Widget _confirmationPage(TestService service) => _TestPage(
    backFallback: _backPath,
    children: [
      const ScreenTitle(
        eyebrow: 'Preview only',
        title: 'Your request is ready to review',
        subtitle: 'This app is not connected to test booking yet.',
      ),
      const SizedBox(height: 8),
      const InfoBanner(
        tone: BannerTone.success,
        message:
            'Nothing has been booked or paid for. A live service would show '
            'your confirmed appointment, preparation steps and contact details here.',
      ),
      _SummaryCard(title: 'Test request preview', value: service.title),
      const SectionHeader(title: 'What happens next in a live service'),
      const _Bullet(text: 'A clinician reviews suitability and your answers.'),
      const _Bullet(
        text: 'You receive sample instructions and appointment details.',
      ),
      const _Bullet(text: 'Results are shared securely when they are ready.'),
      const SizedBox(height: 14),
      PrimaryButton(
        label: 'Back to Tests & Health Checks',
        onPressed: () => context.go(RoutePaths.tests),
      ),
    ],
  );
}

/// Honest empty state: this app has not yet saved test bookings or results.
class TestResultsScreen extends StatelessWidget {
  const TestResultsScreen({super.key});

  @override
  Widget build(BuildContext context) => _TestPage(
    backFallback: RoutePaths.tests,
    children: [
      const ScreenTitle(
        eyebrow: 'Tests & Health Checks',
        title: 'My tests & results',
        subtitle: 'Requests and results shared by your care team.',
      ),
      const SizedBox(height: 8),
      const InfoBanner(
        message:
            'There are no test requests saved in this app yet. Results from '
            'your clinician may appear in Health records when shared.',
      ),
      const SizedBox(height: 8),
      const InfoBanner(
        tone: BannerTone.info,
        title: 'If follow-up is needed',
        message:
            'A clinician will explain your result and any recommended next '
            'steps. Contact the care team if you have questions about a result.',
      ),
      const SizedBox(height: 8),
      RowCard(
        icon: LcIcons.file,
        title: 'Health records',
        subtitle: 'View results shared by your care team',
        onTap: () => context.push(RoutePaths.healthRecords),
      ),
      RowCard(
        icon: LcIcons.calendar,
        title: 'Explore tests',
        subtitle: 'Browse available health checks',
        onTap: () => context.go(RoutePaths.tests),
      ),
    ],
  );
}

class _TestPage extends StatelessWidget {
  const _TestPage({
    required this.children,
    this.backFallback = RoutePaths.tests,
  });

  final List<Widget> children;
  final String backFallback;

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: context.palette.background,
    body: SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 25),
        children: [
          AppHeaderBar(showBack: true, backFallback: backFallback),
          const SizedBox(height: 4),
          ...children,
        ],
      ),
    ),
  );
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({required this.title, required this.value});

  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: palette.elevated,
        border: Border.all(color: palette.line),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Text(title, style: TextStyle(color: palette.inkMuted)),
          ),
          const SizedBox(width: 12),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: TextStyle(color: palette.ink, fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }
}

class _Bullet extends StatelessWidget {
  const _Bullet({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 5),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(AppIcons.checkCircle, size: 18, color: context.palette.positive),
        const SizedBox(width: 9),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              color: context.palette.inkMuted,
              height: 1.5,
              fontSize: 13,
            ),
          ),
        ),
      ],
    ),
  );
}
