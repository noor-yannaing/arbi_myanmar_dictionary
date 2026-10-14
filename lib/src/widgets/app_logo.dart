import 'package:flutter/material.dart';

/// The selected Language Bridge mark, displayed beside the app's name.
class AppLogo extends StatelessWidget {
  const AppLogo({required this.size, super.key});

  final double size;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(size * 0.22),
      child: Image.asset(
        'assets/branding/nur-language-bridge.png',
        width: size,
        height: size,
        fit: BoxFit.contain,
        filterQuality: FilterQuality.medium,
        excludeFromSemantics: true,
      ),
    );
  }
}
