// lib/widgets/action_card.dart
import 'package:flutter/material.dart';
import 'dart:ui' as ui; // BackdropFilter için
import '../utils/app_theme.dart'; // Renkler için

class ActionCard extends StatelessWidget {
  final String? imagePath; // Opsiyonel hale getirildi
  final IconData? icon; // Yeni eklendi
  final String title;
  final VoidCallback onTap;
  final double cardRadius;
  final Color cardBackgroundColor;
  final Color cardBorderColor;
  final double iconSize;
  final Color iconColor;

  const ActionCard({
    super.key,
    this.imagePath,
    this.icon,
    required this.title,
    required this.onTap,
    this.cardRadius = 29.0, // StockItemCard ile aynı
    this.cardBackgroundColor =
        const Color(0x3300AFFF), // Açık mavi, yarı saydam
    this.cardBorderColor =
        const Color(0x4D00AFFF), // Biraz daha belirgin border
    this.iconSize = 48.0, // Resim/İkon boyutu
    this.iconColor = Colors.white, // İkon rengi
  }) : assert(imagePath != null || icon != null,
            'Either imagePath or icon must be provided');

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(cardRadius),
        child: BackdropFilter(
          filter: ui.ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
          child: Container(
            decoration: BoxDecoration(
              color: cardBackgroundColor,
              borderRadius: BorderRadius.circular(cardRadius),
              border: Border.all(
                color: cardBorderColor,
                width: 1.0,
              ),
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: onTap,
                borderRadius: BorderRadius.circular(cardRadius),
                highlightColor: AppTheme.primaryTextColor.withAlpha(30),
                splashColor: AppTheme.primaryTextColor.withAlpha(20),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16.0, vertical: 20.0),
                  child: Row(
                    children: <Widget>[
                      // İkon veya resim gösterimi
                      if (icon != null)
                        Icon(
                          icon,
                          size: iconSize,
                          color: iconColor,
                        )
                      else if (imagePath != null)
                        Image.asset(
                          imagePath!,
                          width: iconSize,
                          height: iconSize,
                        ),
                      const SizedBox(width: 16.0),
                      Expanded(
                        child: Text(
                          title,
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.primaryTextColor,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Icon(
                        Icons.arrow_forward_ios_rounded,
                        color: AppTheme.secondaryTextColor,
                        size: 18,
                      )
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
