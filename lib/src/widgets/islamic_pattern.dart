import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

class PatternBackground extends StatelessWidget {
  const PatternBackground({required this.child, super.key, this.dark = false});

  final Widget child;
  final bool dark;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: dark
              ? const [Color(0xFF071D5A), AppColors.navy, Color(0xFF1453AA)]
              : const [Colors.white, Color(0xFFF4F7FF)],
        ),
      ),
      child: CustomPaint(
        painter: IslamicPatternPainter(
          color: dark
              ? Colors.white.withValues(alpha: 0.12)
              : AppColors.royalBlue.withValues(alpha: 0.055),
        ),
        child: child,
      ),
    );
  }
}

class IslamicPatternPainter extends CustomPainter {
  const IslamicPatternPainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    const spacing = 44.0;
    for (double y = -spacing; y < size.height + spacing; y += spacing) {
      for (double x = -spacing; x < size.width + spacing; x += spacing) {
        final offsetX = ((y / spacing).round().isEven) ? 0.0 : spacing / 2;
        _drawStar(canvas, Offset(x + offsetX, y), 12, 5, paint);
        canvas.drawCircle(Offset(x + offsetX, y), 17, paint);
      }
    }
  }

  void _drawStar(
    Canvas canvas,
    Offset center,
    double outerRadius,
    double innerRadius,
    Paint paint,
  ) {
    final path = Path();
    for (var i = 0; i < 16; i++) {
      final radius = i.isEven ? outerRadius : innerRadius;
      final angle = -math.pi / 2 + i * math.pi / 8;
      final point = Offset(
        center.dx + math.cos(angle) * radius,
        center.dy + math.sin(angle) * radius,
      );
      if (i == 0) {
        path.moveTo(point.dx, point.dy);
      } else {
        path.lineTo(point.dx, point.dy);
      }
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant IslamicPatternPainter oldDelegate) {
    return oldDelegate.color != color;
  }
}

class GoldDivider extends StatelessWidget {
  const GoldDivider({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(width: 46, height: 1, color: AppColors.gold),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 9),
          child: Icon(Icons.diamond_outlined, size: 13, color: AppColors.gold),
        ),
        Container(width: 46, height: 1, color: AppColors.gold),
      ],
    );
  }
}
