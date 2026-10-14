/// How an appointment takes place. The backend's `consultation_mode`.
enum ConsultationMode {
  video('video', 'Video', 'Video consultation'),
  audio('audio', 'Telephone', 'Telephone consultation'),
  inPerson('in_person', 'In person', 'In-person consultation');

  const ConsultationMode(this.apiValue, this.label, this.consultationLabel);

  /// What the backend calls it.
  final String apiValue;

  /// Short, for a button or chip.
  final String label;

  /// Longer, for a summary ("Video consultation").
  final String consultationLabel;

  /// Seen through a screen or phone rather than at a clinic.
  bool get isOnline => this != inPerson;

  static ConsultationMode? parse(Object? value) {
    for (final mode in values) {
      if (mode.apiValue == value) return mode;
    }
    return null;
  }
}
