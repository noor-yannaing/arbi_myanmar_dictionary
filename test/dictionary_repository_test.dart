import 'package:arabic_myanmar_dictionary/src/models/dictionary_entry.dart';
import 'package:arabic_myanmar_dictionary/src/services/dictionary_repository.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Arabic search normalization', () {
    test('removes harakat', () {
      expect(
        DictionaryRepository.normalizeForSearch('اِئْتِلَافٌ'),
        'ايتلاف',
      );
    });

    test('normalizes alef variants and tatweel', () {
      expect(DictionaryRepository.normalizeForSearch('إِسْــلَام'), 'اسلام');
    });

    test('normalizes whitespace without changing Myanmar', () {
      expect(
        DictionaryRepository.normalizeForSearch('  စုစည်းမှု   ညီညွတ်မှု  '),
        'စုစည်းမှု ညီညွတ်မှု',
      );
    });
  });

  test('entry falls back to unvocalized Arabic', () {
    final entry = DictionaryEntry.fromJson(
      const {
        'id': 1,
        'arabic': 'كتاب',
        'myanmar': 'စာအုပ်',
        'page': 1,
      },
      section: 'ك',
    );

    expect(entry.arabicVocalized, 'كتاب');
    expect(entry.myanmar, 'စာအုပ်');
    expect(entry.stableId, 'ك-1');
  });

  test('all offline assets load and can be searched in both languages',
      () async {
    final repository = DictionaryRepository();
    final entries = await repository.load();

    expect(entries, hasLength(17020));
    expect(repository.search('ائتلاف').first.arabic, 'ائتلاف');
    expect(repository.search('စုစည်းမှု'), isNotEmpty);
  });
}
