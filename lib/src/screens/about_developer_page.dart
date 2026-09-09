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
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Skills',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 10),
                        const _TagWrap(values: AppContent.developerSkills),
                        const SizedBox(height: 20),
                        Text(
                          'Technologies',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 10),
                        const _TagWrap(
                          values: AppContent.developerTechnologies,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                  InfoCard(
                    title: 'Experience',
                    icon: Icons.work_outline_rounded,
                    child: Column(
                      children: [
                        for (var index = 0;
                            index < AppContent.developerExperience.length;
                            index++) ...[
                          _ExperienceTile(
                            experience: AppContent.developerExperience[index],
                          ),
                          if (index < AppContent.developerExperience.length - 1)
                            const Divider(height: 28),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                  InfoCard(
                    title: 'Let’s Connect',
                    icon: Icons.alternate_email_rounded,
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
            child: const Icon(
              Icons.person_rounded,
              size: 49,
              color: AppColors.royalBlue,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            AppContent.developerRole,
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

class _ExperienceTile extends StatelessWidget {
  const _ExperienceTile({required this.experience});

  final DeveloperExperience experience;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: const Color(0xFFF1F5FD),
            border: Border.all(color: AppColors.gold),
          ),
          child: const Icon(
            Icons.code_rounded,
            size: 20,
            color: AppColors.royalBlue,
          ),
        ),
        const SizedBox(width: 13),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                experience.title,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 3),
              Text(
                [
                  experience.organization,
                  experience.period,
                ].where((part) => part.isNotEmpty).join(' · '),
                style: const TextStyle(
                  color: AppColors.royalBlue,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Text(experience.description),
            ],
          ),
        ),
      ],
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
