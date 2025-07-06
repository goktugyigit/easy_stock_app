// lib/widgets/fanus_widget.dart
import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:flutter/scheduler.dart' show Ticker;

// --- Konfigürasyon Sınıfları (Bunlarda değişiklik yok) ---
class LayerConfig {
  final double amp;
  final double len;
  final double speed;
  final double phase;
  const LayerConfig({required this.amp, required this.len, required this.speed, required this.phase});
}

class FanusPainterConfig {
  final List<LayerConfig> layers;
  final double jitterAmp;
  final double jitterLen;
  final double ringThicknessRatio;
  final Color baseRingColor;
  final bool clockwiseFill;

  const FanusPainterConfig({
    required this.layers,
    required this.jitterAmp,
    required this.jitterLen,
    this.ringThicknessRatio = 14.0 / 300.0,
    this.baseRingColor = const Color(0xffdbe1e8),
    this.clockwiseFill = true,
  });

  Color getRingColor(double levelPercentage) {
    if (levelPercentage <= 1) return Colors.grey.shade500; // Yüzde 1'in altı gri
    final h = levelPercentage * 1.2;
    final l = 45.0 - levelPercentage * 0.18;
    return HSLColor.fromAHSL(1.0, h.clamp(0, 360), 0.80, l.clamp(0, 100) / 100.0).toColor();
  }

  static const FanusPainterConfig defaultConfig = FanusPainterConfig(
    layers: [
      LayerConfig(amp: 5, len: 25, speed: 1.0, phase: 0),          
      LayerConfig(amp: 7, len: 35, speed: 0.75, phase: math.pi / 2), 
      LayerConfig(amp: 3, len: 20, speed: 1.3, phase: math.pi),      
    ],
    jitterAmp: 0.15,
    jitterLen: 0.2,
  );
}

// --- Widget (GÜNCELLENDİ) ---
class FanusWidget extends StatefulWidget {
  // ESKİ parametreler
  // final int currentStock;
  // final int maxStock;

  // YENİ parametreler
  final double stockPercentage; // 0-100 arası bir değer
  final String stockValueText; // Gösterilecek metin (örn: "87")
  final String? unit; // Opsiyonel birim (örn: "ADET")

  final double size;

  const FanusWidget({
    super.key,
    required this.stockPercentage,
    required this.stockValueText,
    this.unit, // Opsiyonel
    this.size = 65.0,
  });

  @override
  State<FanusWidget> createState() => _FanusWidgetState();
}

class _FanusWidgetState extends State<FanusWidget> with SingleTickerProviderStateMixin {
  late final Ticker _ticker;
  double _targetLevelPercentage = 0.0;
  double _displayLevelPercentage = 0.0;
  double _animationTime = 0.0;

  static const _easeFactor = 0.07;
  static const _timeIncrement = 0.014;

  @override
  void initState() {
    super.initState();
    _updateTargetLevel();
    _displayLevelPercentage = _targetLevelPercentage;

    _ticker = createTicker((_) {
      if (mounted) {
        setState(() {
          _animationTime += _timeIncrement;
          _displayLevelPercentage += (_targetLevelPercentage - _displayLevelPercentage) * _easeFactor;
        });
      }
    })..start();
  }

  @override
  void didUpdateWidget(covariant FanusWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Artık stockPercentage'deki değişikliği dinliyoruz
    if (oldWidget.stockPercentage != widget.stockPercentage) {
      _updateTargetLevel();
    }
  }

  void _updateTargetLevel() {
    // Yüzde değeri doğrudan ve sınırlı olarak alınıyor
    _targetLevelPercentage = widget.stockPercentage.clamp(0.0, 100.0);
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: CustomPaint(
        painter: _FanusPainter(
          displayLevelPercentage: _displayLevelPercentage,
          actualStockText: widget.stockValueText, // Gösterilecek metni al
          unitText: widget.unit, // Birimi al
          animationTime: _animationTime,
          config: FanusPainterConfig.defaultConfig,
        ),
      ),
    );
  }
}

// --- PAINTER SINIFI (GÜNCELLENDİ) ---
class _FanusPainter extends CustomPainter {
  final double displayLevelPercentage;
  final String actualStockText;
  final String? unitText; // Opsiyonel birim metni
  final double animationTime;
  final FanusPainterConfig config;

  _FanusPainter({
    required this.displayLevelPercentage,
    required this.actualStockText,
    this.unitText,
    required this.animationTime,
    required this.config,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // ... (paint metodunun üst kısmı aynı, su ve halka çizimi) ...
    // Sadece metin çizim kısmı değişecek

    final r = size.width / 2;
    final ringW = size.width * config.ringThicknessRatio;
    final centerOffset = Offset(r, r);
    final innerR = r - ringW / 2;

    canvas.drawCircle(centerOffset, innerR, Paint()..color = Colors.white);
    
    final clip = Path()..addOval(Rect.fromCircle(center: centerOffset, radius: innerR));
    canvas.save();
    canvas.clipPath(clip);

    final radialGradient = RadialGradient(
      colors: [Colors.white.withAlpha((0.45 * 255).round()), Colors.transparent],
      stops: const [0.0, 1.0],
      center: const Alignment(0.2, -0.2),
      radius: 1.0,
    );
    canvas.drawRect(
      Offset.zero & size,
      Paint()..shader = radialGradient.createShader(Rect.fromCircle(center: Offset(r * 0.7, r * 0.7), radius: innerR)),
    );
    canvas.drawColor(Colors.white.withAlpha((0.6 * 255).round()), BlendMode.srcOver);

    final maxAmp = config.layers.map((l) => l.amp).reduce(math.max);
    final topClearance = maxAmp * 1.1;
    final bottomClearance = maxAmp * 0.9;
    final rawY = size.width * (1 - displayLevelPercentage / 100.0);
    final baseY = displayLevelPercentage <= 1 // Yüzde 1'in altı
        ? size.width + maxAmp
        : math.min(size.width - bottomClearance, math.max(topClearance, rawY));

    if (displayLevelPercentage > 1) { // Yüzde 1'in üstü
      for (var i = 0; i < config.layers.length; i++) {
        final layer = config.layers[i];
        final t = animationTime * layer.speed;
        final amp = layer.amp * (1 - config.jitterAmp / 2 + config.jitterAmp * 0.5 * (1 + math.sin(t + layer.phase)));
        final len = layer.len * (1 - config.jitterLen / 2 + config.jitterLen * 0.5 * (1 + math.cos(t * 0.7 - layer.phase)));

        final path = Path()..moveTo(0, size.height);
        for (double x = 0; x <= size.width + 1; x += 1) {
          final k = x / len;
          final y = baseY +
              .6 * amp * math.sin(k + t + layer.phase) +
              .4 * amp * math.sin(1.7 * k + t * 0.7 + layer.phase);
          path.lineTo(x, y.clamp(0, size.height));
        }
        path..lineTo(size.width, size.height)..close();

        canvas.drawPath(
          path,
          Paint()
            ..shader = LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  stops: const [0.0, 0.4, 0.8, 1.0],
                  colors: [
                    Color.fromRGBO(130, 200, 255, 0.5 + 0.05 * i),
                    Color.fromRGBO(80, 160, 240, 0.65 + 0.05 * i),
                    Color.fromRGBO(40, 110, 210, 0.8 + 0.05 * i),
                    Color.fromRGBO(20, 70, 160, 0.9 + 0.06 * i),
                  ],
                ).createShader(
                  Rect.fromLTWH(0, baseY - amp*1.5, size.width, (centerOffset.dy + innerR) - (baseY - amp*1.5) ),
                ),
        );
      }
    }
    canvas.restore();

    final ringColorValue = config.getRingColor(displayLevelPercentage);
    final baseRingPaint = Paint()
      ..style = PaintingStyle.stroke..strokeWidth = ringW
      ..strokeCap = StrokeCap.round..color = config.baseRingColor;
    final fillRingPaint = Paint()
      ..style = PaintingStyle.stroke..strokeWidth = ringW
      ..strokeCap = StrokeCap.round..color = ringColorValue;
    final arcRect = Rect.fromCircle(center: centerOffset, radius: innerR);
    canvas
      ..drawArc(arcRect, -math.pi / 2, 2 * math.pi, false, baseRingPaint)
      ..drawArc(
        arcRect, -math.pi / 2, 
        (config.clockwiseFill ? 1 : -1) * 2 * math.pi * displayLevelPercentage / 100, 
        false, fillRingPaint,
      );


    // METİN ÇİZİM KISMI GÜNCELLENDİ
    // Eğer birim (unit) belirtilmemişse, metin ortada büyük olur
    if (unitText == null || unitText!.isEmpty) {
      final textStyleStroke = TextStyle(
        fontSize: size.width * .28,
        fontWeight: FontWeight.w700,
        fontFamily: 'Poppins',
        foreground: Paint()..style = PaintingStyle.stroke..strokeWidth = size.width * 0.018..color = Colors.black.withAlpha(230),
      );
      final textStyleFill = TextStyle(color: ringColorValue, fontWeight: FontWeight.w700, fontSize: size.width * .28, fontFamily: 'Poppins');
      final textPainter = TextPainter(text: TextSpan(text: actualStockText, style: textStyleFill), textAlign: TextAlign.center, textDirection: TextDirection.ltr)..layout(maxWidth: size.width);
      final textPainterStroke = TextPainter(text: TextSpan(text: actualStockText, style: textStyleStroke), textAlign: TextAlign.center, textDirection: TextDirection.ltr)..layout(maxWidth: size.width);
      final textOffset = Offset(r - textPainter.width / 2, r - textPainter.height / 2);
      textPainterStroke.paint(canvas, textOffset);
      textPainter.paint(canvas, textOffset);
    } else { // Eğer birim belirtilmişse, miktar üstte, birim altta küçük olur
      // Miktar için stiller
      final valueTextStyleStroke = TextStyle(
        fontSize: size.width * .25,
        fontWeight: FontWeight.w700,
        fontFamily: 'Poppins',
        foreground: Paint()..style = PaintingStyle.stroke..strokeWidth = size.width * 0.018..color = Colors.black.withAlpha(230),
      );
      final valueTextStyleFill = TextStyle(color: ringColorValue, fontWeight: FontWeight.w700, fontSize: size.width * .25, fontFamily: 'Poppins');
      
      // Birim için stil
      final unitTextStyle = TextStyle(color: Colors.grey.shade600, fontWeight: FontWeight.w500, fontSize: size.width * .12, fontFamily: 'Poppins');
      
      // Miktar için painter'lar
      final valuePainter = TextPainter(text: TextSpan(text: actualStockText, style: valueTextStyleFill), textAlign: TextAlign.center, textDirection: TextDirection.ltr)..layout(maxWidth: size.width);
      final valuePainterStroke = TextPainter(text: TextSpan(text: actualStockText, style: valueTextStyleStroke), textAlign: TextAlign.center, textDirection: TextDirection.ltr)..layout(maxWidth: size.width);
      
      // Birim için painter
      final unitPainter = TextPainter(text: TextSpan(text: unitText, style: unitTextStyle), textAlign: TextAlign.center, textDirection: TextDirection.ltr)..layout(maxWidth: size.width);
      
      final totalHeight = valuePainter.height + unitPainter.height * 0.8;
      final valueOffset = Offset(r - valuePainter.width / 2, r - totalHeight / 2);
      final unitOffset = Offset(r - unitPainter.width / 2, valueOffset.dy + valuePainter.height * 0.9);

      valuePainterStroke.paint(canvas, valueOffset);
      valuePainter.paint(canvas, valueOffset);
      unitPainter.paint(canvas, unitOffset);
    }
  }

  @override
  bool shouldRepaint(covariant _FanusPainter oldDelegate) => 
    oldDelegate.displayLevelPercentage != displayLevelPercentage ||
    oldDelegate.actualStockText != actualStockText || 
    oldDelegate.unitText != unitText ||
    oldDelegate.animationTime != animationTime;
}