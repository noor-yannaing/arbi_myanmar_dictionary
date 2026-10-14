import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import 'islamic_pattern.dart';

class InfoPageHero extends StatelessWidget {
  const InfoPageHero({
    required this.icon,
    required this.eyebrow,
    required this.title,
    required this.subtitle,
    super.key,
  });

  final IconData icon;
  final String eyebrow;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(24, 26, 24, 34),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF071D5A), AppColors.navy, Color(0xFF1756AA)],
        ),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(34)),
      ),
      child: Column(
        children: [
          Container(
            width: 66,
            height: 66,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withValues(alpha: 0.1),
              border: Border.all(color: AppColors.gold, width: 1.5),
            ),
            child: Icon(icon, size: 31, color: AppColors.gold),
          ),
          const SizedBox(height: 16),
          Text(
            eyebrow.toUpperCase(),
            style: const TextStyle(
              color: AppColors.gold,
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 2.1,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            title,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                  color: Colors.white,
                  fontSize: 31,
                ),
          ),
          const SizedBox(height: 11),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.white70,
                ),
          ),
        ],
      ),
    );
  }
}

class InfoCard extends StatelessWidget {
  const InfoCard({
    required this.title,
    required this.child,
    super.key,
    this.icon,
    this.centerHeader = true,
  });

  final String title;
  final IconData? icon;
  final bool centerHeader;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (centerHeader)
              SizedBox(
                width: double.infinity,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (icon != null) ...[
                      Icon(icon, size: 22, color: AppColors.gold),
                      const SizedBox(height: 8),
                    ],
                    Text(
                      title,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ],
                ),
              )
            else
              Row(
                children: [
                  if (icon != null) ...[
                    Icon(icon, size: 22, color: AppColors.gold),
                    const SizedBox(width: 10),
                  ],
                  Expanded(
                    child: Text(title,
                        style: Theme.of(context).textTheme.titleLarge),
                  ),
                ],
              ),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Center(child: GoldDivider()),
            ),
            child,
          ],
        ),
      ),
    );
  }
}

class FeatureTile extends StatelessWidget {
  const FeatureTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    super.key,
  });

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: const Color(0xFFF3F6FD),
              borderRadius: BorderRadius.circular(13),
            ),
            child: Icon(icon, size: 21, color: AppColors.royalBlue),
          ),
          const SizedBox(height: 10),
          Text(
            title,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 3),
          Text(subtitle, textAlign: TextAlign.center),
        ],
      ),
    );
  }
}
