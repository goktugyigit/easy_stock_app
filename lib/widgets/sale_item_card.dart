// lib/widgets/sale_item_card.dart (YENİ DOSYA)
import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import 'package:intl/intl.dart';
import '../models/sale_item.dart';
import '../utils/app_theme.dart';

class SaleItemCard extends StatelessWidget {
  final SaleItem saleItem;

  const SaleItemCard({
    super.key,
    required this.saleItem,
  });

  static const double cardRadius = 29.0;

  Widget _buildInfoRow(String label, String? value) {
    if (value == null || value.isEmpty) {
      return const SizedBox.shrink();
    }
    return Padding(
      padding: const EdgeInsets.only(top: 2.0),
      child: RichText(
        text: TextSpan(
          style: TextStyle(fontSize: 12, color: AppTheme.secondaryTextColor, height: 1.4),
          children: [
            TextSpan(text: "$label: ", style: const TextStyle(fontWeight: FontWeight.w600)),
            TextSpan(text: value),
          ]
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cardBgColor = AppTheme.glassCardBackgroundColor.withAlpha(20); // Biraz daha şeffaf
    final cardBorderColor = AppTheme.glassCardBorderColor;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(cardRadius),
        child: BackdropFilter(
          filter: ui.ImageFilter.blur(sigmaX: 18.0, sigmaY: 18.0),
          child: Container(
            decoration: BoxDecoration(
              color: cardBgColor,
              borderRadius: BorderRadius.circular(cardRadius),
              border: Border.all(color: cardBorderColor, width: 1.0),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 28,
                    backgroundColor: AppTheme.primaryColor.withAlpha(200),
                    child: FittedBox(
                      child: Padding(
                        padding: const EdgeInsets.all(4.0),
                        child: Text(
                          '${saleItem.quantitySold}',
                          style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          saleItem.soldStockItem.name,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.primaryTextColor,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        _buildInfoRow("Müşteri", saleItem.customerName ?? "Belirtilmemiş"),
                        _buildInfoRow("Satış Tarihi", DateFormat('dd.MM.yyyy HH:mm').format(saleItem.saleDate)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}