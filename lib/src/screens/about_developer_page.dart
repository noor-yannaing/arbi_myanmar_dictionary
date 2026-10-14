import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../config/app_content.dart';
import '../theme/app_theme.dart';
import '../widgets/info_page_widgets.dart';
import '../widgets/islamic_pattern.dart';

class AboutDeveloperPage extends StatelessWidget {
  const AboutDeveloperPage({super.key});

  @override
  Widget build(BuildContext context) {
    return PatternBackground(
      child: SafeArea(
        bottom: false,
        child: CustomScrollView(
          slivers: [
            const SliverToBoxAdapter(
              child: InfoPageHero(
                icon: Icons.code_rounded,
                eyebrow: 'People behind the app',
                title: 'About the Developer',
                subtitle:
                    'Building a thoughtful bridge between words and people.',
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(18, 22, 18, 32),
              sliver: SliverList.list(
                children: [
                  _buildProfileCard(context),
                  const SizedBox(height: 14),
                  InfoCard(
                    title: 'Skills & Technologies',
                    icon: Icons.workspace_premium_outlined,
                    centerHeader: true,
                    child: SizedBox(
                      width: double.infinity,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            'Skills',
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: 10),
                          const _TagWrap(values: AppContent.developerSkills),
                          const SizedBox(height: 20),
                          Text(
                            'Technologies',
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: 10),
                          const _TagWrap(
                            values: AppContent.developerTechnologies,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  InfoCard(
                    title: 'Let’s Connect',
                    icon: Icons.alternate_email_rounded,
                    centerHeader: true,
                    child: _ConnectSection(
                      onCopy: (label, value) =>
                          _copyContact(context, label, value),
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

  Widget _buildProfileCard(BuildContext context) {
    return InfoCard(
      title: AppContent.developerName,
      centerHeader: true,
      child: Column(
        children: [
          Container(
            width: 92,
            height: 92,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFFF0F4FC),
              border: Border.all(color: AppColors.gold, width: 1.5),
            ),
            clipBehavior: Clip.antiAlias,
            child: ClipOval(
              child: Image.asset(
                AppContent.developerImage,
                width: 92,
                height: 92,
                fit: BoxFit.cover,
                semanticLabel: 'Photo of ${AppContent.developerName}',
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            AppContent.developerRole,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AppColors.royalBlue,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            AppContent.developerDescription,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Future<void> _copyContact(
    BuildContext context,
    String label,
    String value,
  ) async {
    await Clipboard.setData(ClipboardData(text: value));
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$label copied')),
    );
  }
}

class _TagWrap extends StatelessWidget {
  const _TagWrap({required this.values});

  final List<String> values;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 8,
      runSpacing: 8,
      children: values
          .map(
            (value) => Container(
              padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5FD),
                borderRadius: BorderRadius.circular(30),
                border: Border.all(color: const Color(0xFFDCE5F7)),
              ),
              child: Text(
                value,
                style: const TextStyle(
                  color: AppColors.navy,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          )
          .toList(),
    );
  }
}

class _ConnectSection extends StatelessWidget {
  const _ConnectSection({required this.onCopy});

  final void Function(String label, String value) onCopy;

  @override
  Widget build(BuildContext context) {
    final contacts = <({IconData icon, String label, String value})>[
      if (AppContent.developerEmail.isNotEmpty)
        (
          icon: Icons.email_outlined,
          label: 'Email',
          value: AppContent.developerEmail,
        ),
      if (AppContent.developerWebsite.isNotEmpty)
        (
          icon: Icons.language_rounded,
          label: 'Website',
          value: AppContent.developerWebsite,
        ),
      if (AppContent.developerLinkedIn.isNotEmpty)
        (
          icon: Icons.work_outline_rounded,
          label: 'LinkedIn',
          value: AppContent.developerLinkedIn,
        ),
      if (AppContent.developerGitHub.isNotEmpty)
        (
          icon: Icons.code_rounded,
          label: 'GitHub',
          value: AppContent.developerGitHub,
        ),
    ];

    if (contacts.isEmpty) {
      return const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.info_outline_rounded, color: AppColors.gold),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              'Add email and social links in app_content.dart before publishing.',
            ),
          ),
        ],
      );
    }

    return Column(
      children: [
        for (var index = 0; index < contacts.length; index++) ...[
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: CircleAvatar(
              backgroundColor: AppColors.navy,
              foregroundColor: Colors.white,
              child: Icon(contacts[index].icon, size: 20),
            ),
            title: Text(contacts[index].label),
            subtitle: Text(
              contacts[index].value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            trailing: const Icon(Icons.copy_rounded, size: 19),
            onTap: () => onCopy(
              contacts[index].label,
              contacts[index].value,
            ),
          ),
          if (index < contacts.length - 1) const Divider(height: 1),
        ],
      ],
    );
  }
}
