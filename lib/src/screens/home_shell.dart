import 'package:flutter/material.dart';

import '../services/dictionary_repository.dart';
import 'about_book_page.dart';
import 'about_developer_page.dart';
import 'search_page.dart';

class HomeShell extends StatefulWidget {
  const HomeShell({
    required this.repository,
    required this.entryCount,
    super.key,
  });

  final DictionaryRepository repository;
  final int entryCount;

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  var _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final pages = [
      SearchPage(
        repository: widget.repository,
        entryCount: widget.entryCount,
      ),
      AboutBookPage(entryCount: widget.entryCount),
      const AboutDeveloperPage(),
    ];

    return Scaffold(
      body: IndexedStack(index: _selectedIndex, children: pages),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) =>
            setState(() => _selectedIndex = index),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.search_rounded),
            selectedIcon: Icon(Icons.search_rounded),
            label: 'Dictionary',
          ),
          NavigationDestination(
            icon: Icon(Icons.auto_stories_outlined),
            selectedIcon: Icon(Icons.auto_stories_rounded),
            label: 'Book',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline_rounded),
            selectedIcon: Icon(Icons.person_rounded),
            label: 'Developer',
          ),
        ],
      ),
    );
  }
}
