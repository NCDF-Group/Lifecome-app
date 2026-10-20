import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/core_providers.dart';
import '../domain/insurance_models.dart';

/// Insurance enquiries, claim enquiries and support requests.
///
/// None of these has a backend yet, so they are preview data kept in memory
/// for the session (cleared on sign out): no provider or insurer receives
/// them. Linking a health plan and checking its cover are real and live in
/// the payer feature.
class InsuranceState {
  const InsuranceState({
    this.enquiries = const [],
    this.claims = const [],
    this.support = const [],
  });

  final List<InsuranceEnquiry> enquiries;

  /// Newest first.
  final List<ClaimEnquiry> claims;
  final List<InsuranceSupportEnquiry> support;
}

class InsuranceController extends Notifier<InsuranceState> {
  final _random = Random();

  @override
  InsuranceState build() {
    ref.watch(sessionEpochProvider);
    return const InsuranceState();
  }

  String _ref(String prefix) => '$prefix-${1000 + _random.nextInt(9000)}';

  InsuranceEnquiry enquire({
    required InsuranceCategory category,
    required String forWhom,
    required String name,
    required String email,
    required String phone,
  }) {
    final enquiry = InsuranceEnquiry(
      reference: _ref('LC-ENQ'),
      category: category,
      forWhom: forWhom,
      name: name,
      email: email,
      phone: phone,
    );
    state = InsuranceState(
      enquiries: [...state.enquiries, enquiry],
      claims: state.claims,
      support: state.support,
    );
    return enquiry;
  }

  ClaimEnquiry startClaim({
    required String policy,
    required String type,
    required String detail,
  }) {
    final claim = ClaimEnquiry(
      reference: _ref('LC-CLM'),
      policy: policy,
      type: type,
      detail: detail,
      createdAt: DateTime.now(),
    );
    state = InsuranceState(
      enquiries: state.enquiries,
      claims: [claim, ...state.claims],
      support: state.support,
    );
    return claim;
  }

  InsuranceSupportEnquiry askSupport({
    required String topic,
    required String message,
    String? policyReference,
  }) {
    final enquiry = InsuranceSupportEnquiry(
      reference: _ref('LC-INS'),
      topic: topic,
      message: message,
      policyReference: policyReference,
    );
    state = InsuranceState(
      enquiries: state.enquiries,
      claims: state.claims,
      support: [...state.support, enquiry],
    );
    return enquiry;
  }
}

final insuranceProvider = NotifierProvider<InsuranceController, InsuranceState>(
  InsuranceController.new,
);
