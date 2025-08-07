// lib/widgets/stock_item_card.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:provider/provider.dart';
import 'dart:ui' as ui;
import '../models/stock_item.dart';
import '../providers/unit_provider.dart';
import '../providers/customer_provider.dart';
import 'fanus_widget.dart'; // Güncellenmiş FanusWidget
import '../utils/app_theme.dart';

class StockItemCard extends StatelessWidget {
  final StockItem stockItem;
  final VoidCallback? onTap;
  final int globalMaxStockThreshold;

  const StockItemCard({
    super.key,
    required this.stockItem,
    this.onTap,
    required this.globalMaxStockThreshold,
  });

  static const double cardRadius = 29.0;

  Widget _buildStockImage() {
    const double imageSize = 80.0;
    const double imageBorderRadius = 12.0;
    Widget imageWidget;

    if (stockItem.localImagePath != null &&
        stockItem.localImagePath!.isNotEmpty) {
      imageWidget = kIsWeb
          ? Image.network(
              stockItem.localImagePath!,
              width: imageSize,
              height: imageSize,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) =>
                  _buildPlaceholderImage(imageSize, imageBorderRadius),
            )
          : Image.file(
              File(stockItem.localImagePath!),
              width: imageSize,
              height: imageSize,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) =>
                  _buildPlaceholderImage(imageSize, imageBorderRadius),
            );
    } else {
      imageWidget = _buildPlaceholderImage(imageSize, imageBorderRadius);
    }

    return SizedBox(
      width: imageSize,
      height: imageSize,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(imageBorderRadius),
        child: imageWidget,
      ),
    );
  }

  Widget _buildPlaceholderImage(double size, double borderRadius) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(25), // withOpacity(0.1)
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      child: Icon(
        Icons.image_not_supported_outlined,
        size: size * 0.5,
        color: Colors.white.withAlpha(128), // withOpacity(0.5)
      ),
    );
  }

  Widget _buildInfoRow(String label, String? value,
      {bool isBoldValue = false}) {
    if (value == null || value.isEmpty) {
      return const SizedBox.shrink();
    }
    return Padding(
      padding: const EdgeInsets.only(top: 1.5, bottom: 1.5),
      child: RichText(
        text: TextSpan(
            style: TextStyle(
                fontSize: 11.5,
                color: AppTheme.secondaryTextColor.withAlpha(220),
                height: 1.35),
            children: [
              TextSpan(
                  text: "$label ",
                  style: TextStyle(
                      color: AppTheme.secondaryTextColor.withAlpha(180),
                      fontWeight: FontWeight.w500)),
              TextSpan(
                  text: value,
                  style: TextStyle(
                      fontWeight:
                          isBoldValue ? FontWeight.w600 : FontWeight.normal,
                      color: AppTheme.primaryTextColor.withAlpha(240))),
            ]),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final int maxStokForIndicator =
        stockItem.maxStockThreshold ?? globalMaxStockThreshold;
    final cardBgColor = AppTheme.glassCardBackgroundColor;
    // Navbar'daki gibi mavi border kullan
    final cardBorderColor = AppTheme.primaryColor.withValues(alpha: 0.2);

    // Yüzdeyi hesapla, maxStok'un sıfır olma durumunu kontrol et
    final double stockPercentage = (maxStokForIndicator > 0)
        ? (stockItem.quantity / maxStokForIndicator) * 100.0
        : (stockItem.quantity > 0
            ? 100.0
            : 0.0); // Eğer max stok 0 ise ve stok varsa dolu göster

    return ClipRRect(
      borderRadius: BorderRadius.circular(cardRadius),
      child: BackdropFilter(
        filter: ui.ImageFilter.blur(sigmaX: 18.0, sigmaY: 18.0),
        child: Container(
          decoration: BoxDecoration(
            color: cardBgColor,
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
              highlightColor: Colors.white.withAlpha(20), // withOpacity(0.08)
              splashColor: Colors.white.withAlpha(10), // withOpacity(0.04)
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    _buildStockImage(),
                    const SizedBox(width: 12.0),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          Text(
                            stockItem.name,
                            style: TextStyle(
                              fontSize: 15.5,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.primaryTextColor,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          _buildInfoRow("Ürün Kodu:", stockItem.stockCode),
                          _buildInfoRow("Kategori:", stockItem.category),
                          _buildInfoRow("Marka:", stockItem.brand),
                          _buildInfoRow("Raf Loks.:", stockItem.shelfLocation),
                          Consumer<CustomerProvider>(
                            builder: (context, customerProvider, child) {
                              String supplierName = stockItem.supplier ??
                                  ""; // Eski alan için fallback

                              if (stockItem.supplierId != null) {
                                final supplier = customerProvider
                                    .findById(stockItem.supplierId!);
                                if (supplier != null) {
                                  supplierName = supplier.name;
                                }
                              }

                              return _buildInfoRow("Tedarikçi:", supplierName);
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 10.0),
                    // DÜZELTME: FanusWidget yeni parametrelerle çağrılıyor
                    Consumer2<UnitProvider, CustomerProvider>(
                      builder:
                          (context, unitProvider, customerProvider, child) {
                        String unitText = "ADET"; // Varsayılan

                        if (stockItem.unitId != null) {
                          final unit = unitProvider.findById(stockItem.unitId!);
                          if (unit != null) {
                            unitText = unit.shortName.toUpperCase();
                          }
                        }

                        return FanusWidget(
                          stockPercentage: stockPercentage,
                          stockValueText: stockItem.quantity.toString(),
                          unit: unitText,
                          size: 75.0,
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
