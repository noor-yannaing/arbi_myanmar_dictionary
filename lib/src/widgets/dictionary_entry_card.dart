import 'package:flutter/material.dart';

import '../models/dictionary_entry.dart';
import '../theme/app_theme.dart';

class DictionaryEntryCard extends StatelessWidget {
  const DictionaryEntryCard({
    required this.entry,
    required this.onTap,
    super.key,
  });

  final DictionaryEntry entry;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(22),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(18, 16, 14, 16),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      entry.arabicVocalized,
                      textAlign: TextAlign.right,
                      textDirection: TextDirection.rtl,
                      style: const TextStyle(
                        color: AppColors.navy,
                        fontSize: 25,
                        fontWeight: FontWeight.w700,
                        height: 1.55,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      entry.myanmar,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              const Icon(Icons.chevron_right_rounded, color: AppColors.gold),
            ],
          ),
        ),
      ),
    );
  }
}
