// lib/widgets/action_card.dart
import 'package:flutter/material.dart';
import 'dart:ui' as ui; // BackdropFilter için
import '../utils/app_theme.dart'; // Renkler için

class ActionCard extends StatelessWidget {
  final String imagePath;
  final String title;
  final VoidCallback onTap;
  final double cardRadius;
  final Color cardBackgroundColor;
  final Color cardBorderColor;
  final double iconSize;
  final Color iconColor; // Bu parametre şu anda Image.asset için doğrudan kullanılmıyor

  const ActionCard({
    super.key,
    required this.imagePath,
    required this.title,
    required this.onTap,
    this.cardRadius = 29.0, // StockItemCard ile aynı
    this.cardBackgroundColor = const Color(0x3300AFFF), // Açık mavi, yarı saydam
    this.cardBorderColor = const Color(0x4D00AFFF), // Biraz daha belirgin border
    this.iconSize = 48.0, // Resim/İkon boyutu
    this.iconColor = Colors.white, // Eğer Icon widget kullansaydık varsayılan renk
  });

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
                highlightColor: AppTheme.primaryTextColor.withAlpha(30), // AppTheme'den alabiliriz
                splashColor: AppTheme.primaryTextColor.withAlpha(20),  // AppTheme'den alabiliriz
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
                  child: Row(
                    children: <Widget>[
                      Image.asset(
                        imagePath,
                        width: iconSize,
                        height: iconSize,
                        // color: iconColor, // Eğer PNG'nin rengini değiştirmek istersen ve PNG tek renkliyse
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
                      // DÜZELTME: Icon widget'ından const kaldırıldı
                      Icon(
                        Icons.arrow_forward_ios_rounded,
                        color: AppTheme.secondaryTextColor, // Bu static bir renk, const değil
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