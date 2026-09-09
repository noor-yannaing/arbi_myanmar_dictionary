class DictionaryEntry {
  const DictionaryEntry({
    required this.id,
    required this.section,
    required this.arabic,
    required this.arabicVocalized,
    required this.myanmar,
    required this.page,
    required this.needsReview,
  });

  factory DictionaryEntry.fromJson(
    Map<String, dynamic> json, {
    required String section,
  }) {
    final arabic = (json['arabic'] as String? ?? '').trim();
    final vocalized = (json['arabic_vocalized'] as String? ?? '').trim();
    return DictionaryEntry(
      id: json['id'] as int? ?? 0,
      section: section,
      arabic: arabic,
      arabicVocalized: vocalized.isEmpty ? arabic : vocalized,
      myanmar: (json['myanmar'] as String? ?? '').trim(),
      page: json['page'] as int?,
      needsReview:
          json['needs_review'] == true || json['harakat_needs_review'] == true,
    );
  }

  final int id;
  final String section;
  final String arabic;
  final String arabicVocalized;
  final String myanmar;
  final int? page;
  final bool needsReview;

  String get stableId => '$section-$id';
}
