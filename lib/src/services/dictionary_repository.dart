import 'dart:convert';

import 'package:flutter/services.dart';

import '../models/dictionary_entry.dart';

class DictionaryRepository {
  DictionaryRepository({AssetBundle? bundle}) : _bundle = bundle ?? rootBundle;

  final AssetBundle _bundle;
  List<DictionaryEntry>? _entries;
  List<_SearchableEntry>? _searchIndex;

  static const sectionFiles = <String>[
    'AMDText_Alif_Arabic_Myanmar_with_Harakat.json',
    'AMDText_Ba_Arabic_Myanmar_with_Harakat.json',
    'AMDText_Ta_Arabic_Myanmar_with_Harakat.json',
    'AMDText_Tha_Arabic_Myanmar_with_Harakat.json',
    'AMDText_Jim_Arabic_Myanmar_with_Harakat.json',
    'AMDText_Ha_Arabic_Myanmar_with_Harakat.json',
    'AMDText_Kha_Arabic_Myanmar_with_Harakat.json',
    'AMDText_Dal_Arabic_Myanmar_with_Harakat.json',
    'AMDText_Dhal_Arabic_Myanmar_with_Harakat.json',
    'AMDText_Ra_Arabic_Myanmar_with_Harakat.json',
    'AMDText_Zay_Arabic_Myanmar_with_Harakat.json',
    'AMDText_Sin_Arabic_Myanmar_with_Harakat.json',
    'AMDText_Shin_Arabic_Myanmar_with_Harakat.json',
    'AMDText_Sad_Arabic_Myanmar_with_Harakat.json',
    'AMDText_Dad_Arabic_Myanmar_with_Harakat.json',
    'AMDText_TaEmphatic_Arabic_Myanmar_with_Harakat.json',
    'AMDText_Zha_Arabic_Myanmar_with_Harakat.json',
    'AMDText_Ayn_Arabic_Myanmar_with_Harakat.json',
    'AMDText_Ghayn_Arabic_Myanmar_with_Harakat.json',
    'AMDText_Fa_Arabic_Myanmar_with_Harakat.json',
    'AMDText_Qaf_Arabic_Myanmar_with_Harakat.json',
    'AMDText_Kaf_Arabic_Myanmar_with_Harakat.json',
    'AMDText_Lam_Arabic_Myanmar_with_Harakat.json',
    'AMDText_Mim_Arabic_Myanmar_with_Harakat.json',
    'AMDText_Nun_Arabic_Myanmar_with_Harakat.json',
    'AMDText_HaFinal_Arabic_Myanmar_with_Harakat.json',
    'AMDText_Waw_Arabic_Myanmar_with_Harakat.json',
    'AMDText_Ya_Arabic_Myanmar_with_Harakat.json',
  ];

  Future<List<DictionaryEntry>> load() async {
    if (_entries case final cached?) return cached;

    final documents = await Future.wait(sectionFiles.map(_bundle.loadString));
    final entries = <DictionaryEntry>[];
    for (final document in documents) {
      final json = jsonDecode(document) as Map<String, dynamic>;
      final section = json['section'] as String? ?? '';
      final rawEntries = json['entries'] as List<dynamic>? ?? const [];
      entries.addAll(
        rawEntries.map(
          (entry) => DictionaryEntry.fromJson(
            entry as Map<String, dynamic>,
            section: section,
          ),
        ),
      );
    }
    _entries = List.unmodifiable(entries);
    _searchIndex = List.unmodifiable(
      entries.map(
        (entry) => _SearchableEntry(
          entry: entry,
          arabic: normalizeForSearch(entry.arabic),
          vocalized: normalizeForSearch(entry.arabicVocalized),
          myanmar: normalizeForSearch(entry.myanmar),
        ),
      ),
    );
    return _entries!;
  }

  List<DictionaryEntry> search(String query, {int limit = 100}) {
    final index = _searchIndex;
    if (index == null) return const [];

    final rawQuery = query.trim();
    if (rawQuery.isEmpty) return const [];
    final normalizedQuery = normalizeForSearch(rawQuery);
    if (normalizedQuery.isEmpty) return const [];

    final ranked = <({DictionaryEntry entry, int score})>[];
    for (final item in index) {
      final score = _score(
        normalizedQuery,
        item.arabic,
        item.vocalized,
        item.myanmar,
      );
      if (score != null) ranked.add((entry: item.entry, score: score));
    }
    ranked.sort((a, b) {
      final byScore = a.score.compareTo(b.score);
      if (byScore != 0) return byScore;
      return a.entry.arabic.length.compareTo(b.entry.arabic.length);
    });
    return ranked.take(limit).map((result) => result.entry).toList();
  }

  List<DictionaryEntry> entriesForLetter(String letter, {int limit = 120}) {
    final entries = _entries;
    if (entries == null) return const [];
    final normalizedLetter = normalizeForSearch(letter);
    return entries
        .where(
          (entry) =>
              normalizeForSearch(entry.arabic).startsWith(normalizedLetter),
        )
        .take(limit)
        .toList();
  }

  static int? _score(
    String query,
    String arabic,
    String vocalized,
    String myanmar,
  ) {
    final fields = [arabic, vocalized, myanmar];
    if (fields.any((field) => field == query)) return 0;
    if (fields.any((field) => field.startsWith(query))) return 1;
    if (fields.any((field) => _startsWithWord(field, query))) return 2;
    if (fields.any((field) => field.contains(query))) return 3;
    return null;
  }

  static bool _startsWithWord(String value, String query) {
    return value.split(RegExp(r'[\s،؛,.()\-–—]+')).any(
          (word) => word.startsWith(query),
        );
  }

  static String normalizeForSearch(String value) {
    return value
        .toLowerCase()
        .replaceAll(RegExp(r'[\u064B-\u065F\u0670\u06D6-\u06ED]'), '')
        .replaceAll('\u0640', '')
        .replaceAll(RegExp('[أإآٱ]'), 'ا')
        .replaceAll('ى', 'ي')
        .replaceAll('ؤ', 'و')
        .replaceAll('ئ', 'ي')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  }
}

class _SearchableEntry {
  const _SearchableEntry({
    required this.entry,
    required this.arabic,
    required this.vocalized,
    required this.myanmar,
  });

  final DictionaryEntry entry;
  final String arabic;
  final String vocalized;
  final String myanmar;
}
