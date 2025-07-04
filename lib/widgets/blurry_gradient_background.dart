// lib/widgets/blurry_gradient_background.dart
import 'package:flutter/material.dart';
import 'dart:ui' as ui;

class BlurryGradientBackground extends StatelessWidget {
  const BlurryGradientBackground({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(
          child: CustomPaint(
            painter: _GradientPainter(),
          ),
        ),
        Positioned.fill(
          child: BackdropFilter(
            filter: ui.ImageFilter.blur(sigmaX: 20.0, sigmaY: 20.0),
            child: Container(
              color: Colors.transparent,
            ),
          ),
        ),
      ],
    );
  }
}

class _GradientPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final linearPaint = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFF111111), Color(0xFF222222), Color(0xFF000000)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), linearPaint);

    final radialPaint1 = Paint()
      ..shader = RadialGradient(
        center: Alignment(size.width * 0.3 / size.width * 2 - 1, size.height * 0.4 / size.height * 2 - 1),
        radius: 0.4 * 2,
        colors: [const Color(0xFF646464).withAlpha((0.15 * 255).round()), Colors.transparent], // DÜZELTME
        stops: const [0.0, 1.0],
      ).createShader(Rect.fromCircle(
          center: Offset(size.width * 0.3, size.height * 0.4),
          radius: size.width * 0.4
      ));
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), radialPaint1);

    final radialPaint2 = Paint()
      ..shader = RadialGradient(
        center: Alignment(size.width * 0.7 / size.width * 2 - 1, size.height * 0.6 / size.height * 2 - 1),
        radius: 0.6 * 2,
        colors: [const Color(0xFF969696).withAlpha((0.1 * 255).round()), Colors.transparent], // DÜZELTME
        stops: const [0.0, 1.0],
      ).createShader(Rect.fromCircle(
          center: Offset(size.width * 0.7, size.height * 0.6),
          radius: size.width * 0.6
      ));
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), radialPaint2);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}