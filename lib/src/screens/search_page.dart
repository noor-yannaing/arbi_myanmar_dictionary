import 'dart:async';

import 'package:flutter/material.dart';

import '../config/app_content.dart';
import '../models/dictionary_entry.dart';
import '../services/dictionary_repository.dart';
import '../theme/app_theme.dart';
import '../widgets/app_logo.dart';
import '../widgets/dictionary_entry_card.dart';
import '../widgets/islamic_pattern.dart';
import 'entry_details_page.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({
    required this.repository,
    required this.entryCount,
    super.key,
  });

  final DictionaryRepository repository;
  final int entryCount;

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage>
    with AutomaticKeepAliveClientMixin {
  static const _letters = [
    'ا',
    'ب',
    'ت',
    'ث',
    'ج',
    'ح',
    'خ',
    'د',
    'ذ',
    'ر',
    'ز',
    'س',
    'ش',
    'ص',
    'ض',
    'ط',
    'ظ',
    'ع',
    'غ',
    'ف',
    'ق',
    'ك',
    'ل',
    'م',
    'ن',
    'ه',
    'و',
    'ي',
  ];

  final _controller = TextEditingController();
  final _focusNode = FocusNode();
  Timer? _debounce;
  List<DictionaryEntry> _results = const [];
  String _activeQuery = '';
  String? _selectedLetter;

  @override
  bool get wantKeepAlive => true;

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onQueryChanged(String query) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 170), () {
      if (!mounted) return;
      setState(() {
        _activeQuery = query.trim();
        _selectedLetter = null;
        _results = widget.repository.search(query);
      });
    });
  }

  void _browseLetter(String letter) {
    _debounce?.cancel();
    _focusNode.unfocus();
    _controller.clear();
    setState(() {
      _activeQuery = '';
      _selectedLetter = letter;
      _results = widget.repository.entriesForLetter(letter);
    });
  }

  void _clearSearch() {
    _debounce?.cancel();
    _controller.clear();
    setState(() {
      _activeQuery = '';
      _selectedLetter = null;
      _results = const [];
    });
  }

  void _openEntry(DictionaryEntry entry) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => EntryDetailsPage(entry: entry),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final hasSelection = _activeQuery.isNotEmpty || _selectedLetter != null;
    return PatternBackground(
      child: SafeArea(
        bottom: false,
        child: CustomScrollView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          slivers: [
            SliverToBoxAdapter(child: _buildHero(context)),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(18, 22, 18, 12),
              sliver: SliverToBoxAdapter(
                child: TextField(
                  controller: _controller,
                  focusNode: _focusNode,
                  onChanged: _onQueryChanged,
                  textInputAction: TextInputAction.search,
                  textDirection: _isArabic(_controller.text)
                      ? TextDirection.rtl
                      : TextDirection.ltr,
                  decoration: InputDecoration(
                    hintText: 'Search Arabic or Myanmar…',
                    prefixIcon: const Icon(Icons.search_rounded),
                    suffixIcon: hasSelection
                        ? IconButton(
                            tooltip: 'Clear search',
                            onPressed: _clearSearch,
                            icon: const Icon(Icons.close_rounded),
                          )
                        : null,
                  ),
                ),
              ),
            ),
            if (!hasSelection) ...[
              SliverToBoxAdapter(child: _buildAlphabet(context)),
              SliverToBoxAdapter(child: _buildSearchHint(context)),
            ] else ...[
              SliverToBoxAdapter(child: _buildResultsHeader(context)),
              if (_results.isEmpty)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: _buildEmptyState(context),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(18, 0, 18, 28),
                  sliver: SliverList.separated(
                    itemCount: _results.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      final entry = _results[index];
                      return DictionaryEntryCard(
                        entry: entry,
                        onTap: () => _openEntry(entry),
                      );
                    },
                  ),
                ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildHero(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 28, 24, 30),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF071D5A), AppColors.navy, Color(0xFF1859AF)],
        ),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(34)),
      ),
      child: Stack(
        children: [
          const Positioned(
            right: -12,
            top: -8,
            child: Icon(
              Icons.auto_stories_outlined,
              size: 112,
              color: Color(0x14FFFFFF),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const AppLogo(size: 56),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      AppContent.shortName,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: Colors.white,
                          ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 28),
              Text(
                'اِبْحَثْ  •  ရှာဖွေပါ',
                style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                      color: Colors.white,
                      fontSize: 32,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                '${widget.entryCount.toString()} offline entries · Arabic with vowel marks',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.white70,
                    ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAlphabet(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 6, 18, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Browse the Arabic alphabet',
              style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            textDirection: TextDirection.rtl,
            children: _letters
                .map(
                  (letter) => ActionChip(
                    onPressed: () => _browseLetter(letter),
                    label: Text(
                      letter,
                      style: const TextStyle(
                        fontSize: 20,
                        color: AppColors.navy,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    backgroundColor: Colors.white,
                    side: const BorderSide(color: Color(0xFFE1E6F1)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchHint(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 24, 18, 30),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.offline_bolt_outlined, color: AppColors.gold),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Designed for offline use',
                        style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 5),
                    const Text(
                      'Type an Arabic headword—with or without vowel marks—or any Myanmar word from its meaning.',
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildResultsHeader(BuildContext context) {
    final label = _selectedLetter == null
        ? 'Results for “$_activeQuery”'
        : 'Words beginning with $_selectedLetter';
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
      child: Row(
        children: [
          Expanded(
            child: Text(label, style: Theme.of(context).textTheme.titleMedium),
          ),
          Text(
            _results.length == 100 || _results.length == 120
                ? '${_results.length}+'
                : '${_results.length}',
            style: const TextStyle(
              color: AppColors.royalBlue,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.search_off_rounded,
              size: 54, color: AppColors.skyBlue),
          const SizedBox(height: 14),
          Text('No matching words',
              style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 6),
          const Text(
            'Try a shorter word, or search Arabic without vowel marks.',
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  bool _isArabic(String value) => RegExp(r'[\u0600-\u06FF]').hasMatch(value);
}
