/// A doctor available for consultation. Static sample data for now — no
/// provider-directory backend exists yet (blueprint §11, Clinical Records
/// and Provider-Network Model).
class Doctor {
  const Doctor({
    required this.id,
    required this.name,
    required this.specialty,
    required this.credentials,
    required this.yearsExperience,
    required this.rating,
    required this.reviewCount,
    required this.languages,
    required this.about,
  });

  final String id;
  final String name;
  final String specialty;
  final String credentials;
  final int yearsExperience;
  final double rating;
  final int reviewCount;
  final List<String> languages;
  final String about;
}

const sampleDoctors = [
  Doctor(
    id: 'dr-adaeze-okafor',
    name: 'Dr Adaeze Okafor',
    specialty: 'General Practitioner',
    credentials: 'MBBS, MRCGP',
    yearsExperience: 10,
    rating: 4.9,
    reviewCount: 328,
    languages: ['English', 'French'],
    about:
        'A compassionate and experienced General Practitioner with a special interest in '
        'preventive care, chronic disease management and family health. Provides '
        'high-quality virtual consultations to patients across the UK.',
  ),
  Doctor(
    id: 'dr-musa-bello',
    name: 'Dr Musa Bello',
    specialty: 'General Practitioner',
    credentials: 'MBBS, MRCGP',
    yearsExperience: 7,
    rating: 4.8,
    reviewCount: 201,
    languages: ['English', 'Urdu'],
    about:
        'Focuses on general health concerns, follow-up care and results review, with '
        'particular experience supporting patients managing hypertension and diabetes.',
  ),
  Doctor(
    id: 'dr-ngozi-eze',
    name: 'Dr Ngozi Eze',
    specialty: "Women's Health",
    credentials: 'MBBS, MRCOG',
    yearsExperience: 12,
    rating: 4.9,
    reviewCount: 412,
    languages: ['English', 'Polish'],
    about:
        "Specialises in women's health and family planning, with a warm, unhurried "
        'approach to virtual consultations.',
  ),
];
