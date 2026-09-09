import 'package:flutter/material.dart';

import '../models/dictionary_entry.dart';
import '../theme/app_theme.dart';
import '../widgets/islamic_pattern.dart';

class EntryDetailsPage extends StatelessWidget {
  const EntryDetailsPage({required this.entry, super.key});

  final DictionaryEntry entry;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PatternBackground(
        child: CustomScrollView(
          slivers: [
            SliverAppBar.large(
              pinned: true,
              foregroundColor: Colors.white,
              backgroundColor: AppColors.navy,
              surfaceTintColor: AppColors.navy,
              title: const Text('Word details'),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(18, 24, 18, 36),
              sliver: SliverList.list(
                children: [
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(22, 30, 22, 26),
                      child: Column(
                        children: [
                          Text(
                            entry.arabicVocalized,
                            textAlign: TextAlign.center,
                            textDirection: TextDirection.rtl,
                            style: const TextStyle(
                              color: AppColors.navy,
                              fontSize: 39,
                              height: 1.6,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          if (entry.arabic != entry.arabicVocalized) ...[
                            const SizedBox(height: 2),
                            Text(
                              entry.arabic,
                              textDirection: TextDirection.rtl,
                              style: const TextStyle(
                                color: Color(0xFF6C7896),
                                fontSize: 18,
                              ),
                            ),
                          ],
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 22),
                            child: GoldDivider(),
                          ),
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              'Myanmar meaning',
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Align(
                            alignment: Alignment.centerLeft,
                            child: SelectableText(
                              entry.myanmar,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyLarge
                                  ?.copyWith(
                                    fontSize: 18,
                                  ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(18),
                      child: Column(
                        children: [
                          _MetadataRow(
                              label: 'Alphabet section', value: entry.section),
                          if (entry.page != null) ...[
                            const Divider(height: 24),
                            _MetadataRow(
                              label: 'Source page',
                              value: entry.page.toString(),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                  if (entry.needsReview) ...[
                    const SizedBox(height: 14),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFF8E4),
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: const Color(0xFFE7D28E)),
                      ),
                      child: const Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(Icons.info_outline, color: Color(0xFF927A27)),
                          SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'This entry was flagged during extraction and may need comparison with the printed book.',
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MetadataRow extends StatelessWidget {
  const _MetadataRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: Text(label)),
        Text(
          value,
          textDirection: TextDirection.rtl,
          style: const TextStyle(
            color: AppColors.navy,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}
