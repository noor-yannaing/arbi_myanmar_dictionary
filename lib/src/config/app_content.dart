/// Edit this file when the final book, author, and developer details are ready.
abstract final class AppContent {
  static const appName = 'Nur Arabic–Myanmar Dictionary';
  static const shortName = 'Nur Dictionary';

  static const bookTitle = 'Arabic–Myanmar Dictionary';
  static const bookDescription =
      'A practical offline reference connecting Arabic words with clear Myanmar '
      'meanings. This digital edition preserves the Arabic vowel marks found in '
      'the source and makes every entry searchable in both languages.';
  static const authorName = 'Author details to be added';
  static const authorDescription =
      'Add the author’s biography, notable work, and the story of the original '
      'dictionary here before publishing.';

  static const developerName = 'Developer details to be added';
  static const developerRole = 'Flutter application developer';
  static const developerDescription =
      'This offline edition was designed to make Arabic–Myanmar knowledge easy '
      'to search, read, and carry anywhere.';
  static const developerEmail = '';
  static const developerWebsite = '';
  static const developerLinkedIn = '';
  static const developerGitHub = '';

  static const developerSkills = <String>[
    'Flutter Development',
    'UI/UX Design',
    'Offline-first Apps',
    'Bilingual Search',
  ];

  static const developerTechnologies = <String>[
    'Flutter',
    'Dart',
    'Material 3',
    'JSON',
  ];

  static const developerExperience = <DeveloperExperience>[
    DeveloperExperience(
      title: 'Nur Arabic–Myanmar Dictionary',
      organization: 'Independent project',
      period: '2026',
      description:
          'Designed and developed an offline bilingual dictionary with '
          'Arabic vowel-aware search and Myanmar full-text search.',
    ),
  ];
}

class DeveloperExperience {
  const DeveloperExperience({
    required this.title,
    required this.organization,
    required this.period,
    required this.description,
  });

  final String title;
  final String organization;
  final String period;
  final String description;
}
