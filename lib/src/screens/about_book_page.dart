import 'package:flutter/material.dart';

import '../config/app_content.dart';
import '../theme/app_theme.dart';
import '../widgets/info_page_widgets.dart';
import '../widgets/islamic_pattern.dart';

class AboutBookPage extends StatelessWidget {
  const AboutBookPage({required this.entryCount, super.key});

  final int entryCount;

  @override
  Widget build(BuildContext context) {
    return PatternBackground(
      child: SafeArea(
        bottom: false,
        child: CustomScrollView(
          slivers: [
            const SliverToBoxAdapter(
              child: InfoPageHero(
                icon: Icons.auto_stories_rounded,
                eyebrow: 'The story behind the words',
                title: 'About the Book',
                subtitle: 'Preserving language and meaning for every reader.',
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(18, 22, 18, 32),
              sliver: SliverList.list(
                children: [
                  InfoCard(
                    title: AppContent.bookTitle,
                    icon: Icons.menu_book_rounded,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(AppContent.bookDescription),
                        const SizedBox(height: 20),
                        Row(
                          children: [
                            const Expanded(
                              child: _BookStat(
                                icon: Icons.translate_rounded,
                                value: '2',
                                label: 'Languages',
                              ),
                            ),
                            Expanded(
                              child: _BookStat(
                                icon: Icons.library_books_outlined,
                                value: _formatCount(entryCount),
                                label: 'Entries',
                              ),
                            ),
                            const Expanded(
                              child: _BookStat(
                                icon: Icons.offline_bolt_outlined,
                                value: '100%',
                                label: 'Offline',
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                  const InfoCard(
                    title: 'This digital edition',
                    icon: Icons.phone_android_rounded,
                    child: Column(
                      children: [
                        FeatureTile(
                          icon: Icons.format_size_rounded,
                          title: 'Arabic vowel marks preserved',
                          subtitle:
                              'Read the vocalized headword while searching with or without harakat.',
                        ),
                        SizedBox(height: 18),
                        FeatureTile(
                          icon: Icons.manage_search_rounded,
                          title: 'Search in either language',
                          subtitle:
                              'Find an Arabic headword or discover entries through their Myanmar meaning.',
                        ),
                        SizedBox(height: 18),
                        FeatureTile(
                          icon: Icons.shield_outlined,
                          title: 'Private and dependable',
                          subtitle:
                              'No account, internet connection, or remote service is required.',
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                  InfoCard(
                    title: 'About the Author',
                    icon: Icons.person_outline_rounded,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 62,
                          height: 62,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: Color(0xFFF0F4FC),
                          ),
                          child: const Icon(
                            Icons.person_rounded,
                            size: 34,
                            color: AppColors.royalBlue,
                          ),
                        ),
                        const SizedBox(width: 15),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                AppContent.authorName,
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                              const SizedBox(height: 6),
                              Text(AppContent.authorDescription),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatCount(int value) {
    final digits = value.toString();
    return digits.replaceFirstMapped(
      RegExp(r'^(\d+)(\d{3})$'),
      (match) => '${match[1]},${match[2]}',
    );
  }
}

class _BookStat extends StatelessWidget {
  const _BookStat({
    required this.icon,
    required this.value,
    required this.label,
  });

  final IconData icon;
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, size: 22, color: AppColors.gold),
        const SizedBox(height: 6),
        Text(
          value,
          style: const TextStyle(
            color: AppColors.navy,
            fontSize: 17,
            fontWeight: FontWeight.w700,
          ),
        ),
        Text(label, style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }
}
