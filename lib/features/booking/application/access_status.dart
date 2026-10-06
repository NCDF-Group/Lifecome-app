import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Where the user's funded-access (HMO / benefits / workplace) check stands.
/// Home shows an "approval pending" banner while it is [pending]; otherwise
/// the "membership optional" one.
enum AccessStatus { none, pending }

class AccessStatusController extends Notifier<AccessStatus> {
  @override
  AccessStatus build() => AccessStatus.none;

  void markPending() => state = AccessStatus.pending;
}

final accessStatusProvider =
    NotifierProvider<AccessStatusController, AccessStatus>(
      AccessStatusController.new,
    );
