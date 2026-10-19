import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/core_providers.dart';
import '../domain/menopause_assessment.dart';

/// The person's menopause assessment and latest review note.
///
/// The backend has no menopause endpoints yet, so these are kept on the
/// device for this session only (sample data, per the screen pack). Signing
/// out clears them.
class MenopauseState {
  const MenopauseState({this.assessment, this.review});

  final MenopauseAssessment? assessment;
  final MenopauseReviewNote? review;
}

class MenopauseController extends Notifier<MenopauseState> {
  @override
  MenopauseState build() {
    ref.watch(sessionEpochProvider);
    return const MenopauseState();
  }

  void saveAssessment(MenopauseAssessment assessment) =>
      state = MenopauseState(assessment: assessment, review: state.review);

  void saveReview(MenopauseReviewNote review) =>
      state = MenopauseState(assessment: state.assessment, review: review);
}

final menopauseProvider = NotifierProvider<MenopauseController, MenopauseState>(
  MenopauseController.new,
);
