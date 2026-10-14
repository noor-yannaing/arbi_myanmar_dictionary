import 'package:arabic_myanmar_dictionary/src/app.dart';
import 'package:arabic_myanmar_dictionary/src/screens/entry_details_page.dart';
import 'package:arabic_myanmar_dictionary/src/services/dictionary_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('loads the dictionary and navigates between the main pages', (
    tester,
  ) async {
    final repository = DictionaryRepository();
    await tester.runAsync(repository.load);
    await tester.pumpWidget(DictionaryApp(repository: repository));
    await tester.pumpAndSettle();

    expect(find.text('Nur Dictionary'), findsOneWidget);
    expect(find.byType(TextField), findsOneWidget);

    await tester.tap(find.text('Book'));
    await tester.pumpAndSettle();
    expect(find.text('About the Book'), findsOneWidget);

    await tester.tap(find.text('Developer'));
    await tester.pumpAndSettle();
    expect(find.text('About the Developer'), findsOneWidget);
  });

  testWidgets('returns an Arabic result without requiring harakat', (
    tester,
  ) async {
    final repository = DictionaryRepository();
    await tester.runAsync(repository.load);
    await tester.pumpWidget(DictionaryApp(repository: repository));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), 'ائتلاف');
    await tester.pump(const Duration(milliseconds: 250));

    expect(find.text('اِئْتِلَافٌ'), findsOneWidget);
    expect(find.textContaining('စုစည်းမှု'), findsWidgets);
  });

  testWidgets('repaired spelling appears in results and word details', (
    tester,
  ) async {
    final repository = DictionaryRepository();
    await tester.runAsync(repository.load);
    final entry = repository.search('كهرباء').first;
    await tester.pumpWidget(DictionaryApp(repository: repository));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), 'كهرباء');
    await tester.pump(const Duration(milliseconds: 250));
    expect(find.text(entry.arabicVocalized), findsOneWidget);
    expect(entry.arabicVocalized, isNot(matches(RegExp('[A-Za-z]'))));

    await tester.tap(find.text(entry.arabicVocalized));
    await tester.pumpAndSettle();
    expect(find.byType(EntryDetailsPage), findsOneWidget);
    expect(find.text('Word details'), findsWidgets);
    expect(find.text(entry.arabicVocalized), findsOneWidget);
    expect(find.text('كَهْرَHءُ'), findsNothing);
  });
}
