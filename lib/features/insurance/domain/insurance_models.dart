import '../../../core/widgets/media/lc_icons.dart';

/// A kind of cover to explore (screen pack 118-121).
class InsuranceCategory {
  const InsuranceCategory({
    required this.id,
    required this.title,
    required this.summary,
    required this.description,
    required this.icon,
    required this.explains,
  });

  final String id;
  final String title;
  final String summary;
  final String description;
  final String icon;

  /// What the provider will explain before any purchase.
  final List<String> explains;

  static const all = [
    InsuranceCategory(
      id: 'health',
      title: 'Health insurance',
      summary: 'Cover for eligible healthcare needs',
      description:
          'Cover that can help pay for eligible private healthcare, depending '
          'on the policy you choose.',
      icon: LcIcons.shield,
      explains: [
        'Eligible services and limits',
        'Exclusions and waiting periods',
        'Excess and authorisation requirements',
      ],
    ),
    InsuranceCategory(
      id: 'care',
      title: 'Care-related cover',
      summary: 'Products relevant to care needs',
      description:
          'Products related to care needs. Whether any care service is '
          'covered depends entirely on the policy and the provider.',
      icon: LcIcons.care,
      explains: [
        'Who may be eligible',
        'What events or services may be covered',
        'Policy limits and assessment requirements',
      ],
    ),
    InsuranceCategory(
      id: 'protection',
      title: 'Personal protection',
      summary: 'Support for life’s uncertainties',
      description:
          'Protection products. Any recommendation or quotation comes from an '
          'appropriately authorised provider.',
      icon: LcIcons.people,
      explains: [
        'Product purpose and eligibility',
        'Benefits, limits and exclusions',
        'Premiums and policy terms',
      ],
    ),
  ];
}

/// An enquiry to explore a product with a provider (screen pack 122-125).
class InsuranceEnquiry {
  const InsuranceEnquiry({
    required this.reference,
    required this.category,
    required this.forWhom,
    required this.name,
    required this.email,
    required this.phone,
  });

  final String reference;
  final InsuranceCategory category;
  final String forWhom;
  final String name;
  final String email;
  final String phone;
}

/// A claim enquiry (screen pack 136-139). Claims are decided by the
/// insurer, never by LifeCome.
class ClaimEnquiry {
  const ClaimEnquiry({
    required this.reference,
    required this.policy,
    required this.type,
    required this.detail,
    required this.createdAt,
  });

  final String reference;
  final String policy;
  final String type;
  final String detail;
  final DateTime createdAt;

  static const types = [
    'GP consultation',
    'Professional care',
    'Other covered event',
  ];
}

/// An insurance support enquiry (screen pack 140-141).
class InsuranceSupportEnquiry {
  const InsuranceSupportEnquiry({
    required this.reference,
    required this.topic,
    required this.message,
    this.policyReference,
  });

  final String reference;
  final String topic;
  final String message;
  final String? policyReference;

  static const topics = [
    'Policy question',
    'Service cover',
    'Claim update',
    'Policy change or cancellation',
    'Complaint',
  ];
}

/// A policy document, explained (screen pack 131-133). The insurer's own
/// documents are not available in the app yet.
class InsuranceDocument {
  const InsuranceDocument({
    required this.title,
    required this.summary,
    required this.explanation,
  });

  final String title;
  final String summary;
  final String explanation;

  static const all = [
    InsuranceDocument(
      title: 'Policy schedule',
      summary: 'Policyholder, cover and period',
      explanation:
          'Your schedule names the policyholder and anyone else covered, the '
          'policy reference, the cover you chose and the policy period.',
    ),
    InsuranceDocument(
      title: 'Policy wording',
      summary: 'Terms, benefits and exclusions',
      explanation:
          'The wording is the contract: eligibility, benefits, exclusions, '
          'how to claim, cancellation rights and how to complain.',
    ),
    InsuranceDocument(
      title: 'Product information',
      summary: 'Key features at a glance',
      explanation:
          'A short summary of what the product covers and excludes, your '
          'obligations, the policy period and how payment and cancellation '
          'work.',
    ),
  ];
}
