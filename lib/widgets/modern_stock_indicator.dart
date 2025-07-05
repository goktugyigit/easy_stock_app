import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'dart:ui' as ui;

class StockIndicator extends StatefulWidget {
  final double stockPercentage;
  final String unit;
  final double size;

  const StockIndicator({
    super.key,
    required this.stockPercentage,
    this.unit = 'ADET',
    this.size = 250.0,
  });

  @override
  State<StockIndicator> createState() => _StockIndicatorState();
}

class _StockIndicatorState extends State<StockIndicator> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _animation = Tween<double>(begin: 0, end: widget.stockPercentage).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOutCubic),
    );
    _controller.forward();
  }

  @override
  void didUpdateWidget(covariant StockIndicator oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.stockPercentage != widget.stockPercentage) {
      _animation = Tween<double>(
        begin: _animation.value,
        end: widget.stockPercentage,
      ).animate(
        CurvedAnimation(parent: _controller, curve: Curves.easeInOutCubic),
      );
      _controller
        ..value = 0
        ..forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return SizedBox(
          width: widget.size,
          height: widget.size,
          child: CustomPaint(
            painter: _StockIndicatorPainter(
              percentage: _animation.value,
              unit: widget.unit,
            ),
          ),
        );
      },
    );
  }
}

class _StockIndicatorPainter extends CustomPainter {
  final double percentage;
  final String unit;

  _StockIndicatorPainter({required this.percentage, required this.unit});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    const ringThickness = 22.0;

    _drawBackground(canvas, center, radius);
    _drawRing(canvas, center, radius, ringThickness);
    _drawTexts(canvas, size, center);
  }

  void _drawBackground(Canvas canvas, Offset center, double radius) {
    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..shader = ui.Gradient.radial(
          center,
          radius,
          [
            const Color(0xFFC8D0DC),
            const Color(0xFFF0F5FC),
          ],
          [0.85, 1.0],
        ),
    );
  }

  void _drawRing(Canvas canvas, Offset center, double radius, double thickness) {
    final ringRadius = radius - thickness / 2;
    final ringColor = _getRingColor(percentage);

    final shadowPath = Path()..addOval(Rect.fromCircle(center: center, radius: radius));
    canvas.drawShadow(shadowPath, Colors.black.withAlpha(50), 10, false);

    final baseRingPaint = Paint()
      ..color = const Color(0xFFD1D9E6)
      ..strokeWidth = thickness
      ..style = PaintingStyle.stroke;
    canvas.drawCircle(center, ringRadius, baseRingPaint);

    final fillRingPaint = Paint()
      ..shader = ui.Gradient.sweep(
        center,
        [ringColor.withAlpha(76), ringColor],
        [0.0, 1.0],
        TileMode.clamp,
        -math.pi / 2,
        -math.pi / 2 + (2 * math.pi * (percentage / 100)),
      )
      ..strokeWidth = thickness
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: ringRadius),
      -math.pi / 2,
      2 * math.pi * (percentage / 100),
      false,
      fillRingPaint,
    );
  }

  void _drawTexts(Canvas canvas, Size size, Offset center) {
    final ringColor = _getRingColor(percentage);

    final numberStyle = TextStyle(
      fontFamily: 'Inter',
      fontSize: size.width * 0.35,
      fontWeight: FontWeight.w900,
      color: ringColor.withBrightness(0.8),
    );
    _drawCenteredText(canvas, size, percentage.toStringAsFixed(0), numberStyle, center);

    final percentStyle = TextStyle(
      fontFamily: 'Inter',
      fontSize: size.width * 0.1,
      fontWeight: FontWeight.w700,
      color: ringColor.withBrightness(0.8).withAlpha((255 * 0.7).round()),
    );
    final numberSize = _getTextSize(percentage.toStringAsFixed(0), numberStyle, size.width);
    final percentOffset = Offset(center.dx + numberSize.width / 2 + 5, center.dy - numberSize.height * 0.1);
    _drawCenteredText(canvas, size, '%', percentStyle, percentOffset);

    final unitStyle = TextStyle(
      fontFamily: 'Poppins',
      fontSize: size.width * 0.09,
      fontWeight: FontWeight.w700,
      color: const Color(0xFF7E8EAA),
      letterSpacing: 1.5,
    );
    final unitOffset = Offset(center.dx, center.dy + size.height * 0.2);
    _drawCenteredText(canvas, size, unit.toUpperCase(), unitStyle, unitOffset);
  }

  Color _getRingColor(double percentage) {
    if (percentage <= 20) {
      return Color.lerp(const Color(0xFFF27878), const Color(0xFFFFB74D), percentage / 20.0)!;
    }
    if (percentage <= 60) {
      return Color.lerp(const Color(0xFFFFB74D), const Color(0xFF81C784), (percentage - 20) / 40.0)!;
    }
    return const Color(0xFF81C784);
  }

  Size _getTextSize(String text, TextStyle style, double maxWidth) {
    return (TextPainter(
      text: TextSpan(text: text, style: style),
      textDirection: TextDirection.ltr,
    )..layout(maxWidth: maxWidth))
        .size;
  }

  void _drawCenteredText(Canvas canvas, Size size, String text, TextStyle style, Offset center) {
    final textPainter = TextPainter(
      text: TextSpan(text: text, style: style),
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
    )..layout(maxWidth: size.width);
    final textOffset = Offset(center.dx - textPainter.width / 2, center.dy - textPainter.height / 2);
    textPainter.paint(canvas, textOffset);
  }

  @override
  bool shouldRepaint(covariant _StockIndicatorPainter oldDelegate) => 
      oldDelegate.percentage != percentage || oldDelegate.unit != unit;
}

extension ColorBrightness on Color {
  Color withBrightness(double factor) {
    final hsl = HSLColor.fromColor(this);
    return hsl.withLightness((hsl.lightness * factor).clamp(0.0, 1.0)).toColor();
  }
}
