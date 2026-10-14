import 'dart:convert';
import 'dart:io';

import 'package:arabic_myanmar_dictionary/src/services/dictionary_repository.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('every bundled Arabic field is free of Latin and unresolved glyph codes',
      () async {
    final latin = RegExp(r'[A-Za-z\u00C0-\u024F]');
    final invalid = <String>[];
    final identifiers = <String>{};
    var count = 0;
    for (final file in DictionaryRepository.sectionFiles) {
      final document =
          jsonDecode(await rootBundle.loadString(file)) as Map<String, dynamic>;
      final entries = document['entries'] as List<dynamic>;
      expect(entries.length, document['entry_count'], reason: file);
      for (final raw in entries) {
        final entry = raw as Map<String, dynamic>;
        final id = '${document['section']}-${entry['id']}';
        expect(identifiers.add(id), isTrue, reason: 'Duplicate entry $id');
        for (final field in ['arabic', 'arabic_vocalized']) {
          final text = entry[field] as String;
          if (latin.hasMatch(text) ||
              text.contains('⟦') ||
              text.contains('\uFFFD')) {
            invalid.add('$file #${entry['id']} $field: $text');
          }
        }
        count++;
      }
    }
    expect(count, 17020);
    expect(invalid, isEmpty, reason: invalid.take(20).join('\n'));
  });

  test('corrected words can be found using their actual Arabic spelling',
      () async {
    final repository = DictionaryRepository();
    await repository.load();
    for (final word in ['كهرباء', 'مصطفى', 'برطم', 'تزنر', 'برثن', 'كابوس']) {
      expect(repository.search(word), isNotEmpty, reason: word);
    }
    expect(repository.search('كهرHء'), isEmpty);
    expect(repository.search('⟦g1966⟧'), isEmpty);
  });

  test('every source-backed correction remains in the bundled data', () async {
    final ledger = jsonDecode(
      File('docs/data/character-corrections.json').readAsStringSync(),
    ) as Map<String, dynamic>;
    final documents = <String, Map<int, Map<String, dynamic>>>{};
    for (final change in ledger['changes'] as List<dynamic>) {
      final file = change['file'] as String;
      if (!documents.containsKey(file)) {
        final document = jsonDecode(await rootBundle.loadString(file))
            as Map<String, dynamic>;
        documents[file] = {
          for (final entry in document['entries'] as List<dynamic>)
            entry['id'] as int: entry as Map<String, dynamic>,
        };
      }
      final entry = documents[file]![change['id']]!;
      expect(entry[change['field']], change['after'],
          reason: '$file #${change['id']} ${change['field']}');
      expect(entry['arabic_source'], isNotNull);
      expect(change['evidence'], isNotEmpty);
    }
    expect(ledger['changed_entries'], 412);
    expect(ledger['unresolved'], isEmpty);
  });
}
