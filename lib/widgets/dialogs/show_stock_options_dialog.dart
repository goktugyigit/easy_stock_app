import 'package:flutter/material.dart';
import 'dart:ui';
// DÜZELTME: Yeni paket import edildi.
import 'package:another_flushbar/flushbar.dart';
import '../../models/stock_item.dart';
import '../../screens/add_edit_stock_page.dart';
import '../../screens/create_sale_page.dart';
import '../../utils/flushbar_helper.dart';

Future<void> showStockOptionsDialog(BuildContext context, StockItem stockItem) {
  return showDialog(
    context: context,
    barrierColor: Colors.black.withAlpha(1),
    builder: (BuildContext dialogContext) {
      return BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
        child: _StockOptionsDialog(
          stockItem: stockItem,
        ),
      );
    },
  );
}

class _StockOptionsDialog extends StatelessWidget {
  final StockItem stockItem;

  const _StockOptionsDialog({required this.stockItem});

  // DÜZELTME: SnackBar yerine Flushbar kullanan yeni fonksiyon.
  void _showStyledFlushbar(BuildContext context, String message) {
    // Navbar yüksekliğini ve boşluk hesaplaması - home_page_with_search.dart ile aynı
    const double navBarHeight = 70.0; // Modern navbar yüksekliği - güncel
    const double navBarBottomMargin = 25.0; // Modern navbar alt boşluğu
    const double navBarGap =
        10.0; // Flushbar'ın navbar üzerinde bırakacağı boşluk - home_page ile aynı
    final double bottomSafeArea = MediaQuery.of(context).padding.bottom;
    final double totalBottomSpace =
        navBarHeight + navBarBottomMargin + navBarGap + bottomSafeArea;

    FlushbarHelper.showOptimizedFlushbar(context, message, type: FlushbarType.info);
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24.0),
        child: Container(
          width: MediaQuery.of(context).size.width * 0.8,
          decoration: BoxDecoration(
            color: Colors.grey[900]?.withAlpha(217),
            border: Border.all(color: Colors.white.withAlpha(51)),
            borderRadius: BorderRadius.circular(24.0),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildOptionTile(
                context: context,
                icon: Icons.point_of_sale_outlined,
                text: 'Satış Oluştur',
                onTap: () {
                  Navigator.of(context).pop();
                  Navigator.of(context, rootNavigator: true).push(
                    MaterialPageRoute(
                        builder: (_) => CreateSalePage(stockItem: stockItem)),
                  );
                },
              ),
              const Divider(height: 1, color: Colors.white24),
              _buildOptionTile(
                context: context,
                icon: Icons.swap_horiz_rounded,
                text: 'Stok Transfer Et',
                onTap: () {
                  Navigator.of(context).pop();
                  _showStyledFlushbar(
                      context, "Stok Transfer özelliği geliştirilecek.");
                },
              ),
              const Divider(height: 1, color: Colors.white24),
              _buildOptionTile(
                context: context,
                icon: Icons.edit_outlined,
                text: 'Düzenle',
                onTap: () {
                  Navigator.of(context).pop();
                  Navigator.of(context, rootNavigator: true).push(
                    MaterialPageRoute(
                        builder: (_) =>
                            AddEditStockPage(existingItemId: stockItem.id)),
                  );
                },
              ),
              const Divider(height: 1, color: Colors.white24),
              _buildOptionTile(
                context: context,
                icon: Icons.delete_outline_rounded,
                text: 'Sil',
                textColor: Colors.redAccent.shade100,
                onTap: () {
                  Navigator.of(context).pop();
                  _showStyledFlushbar(
                      context, "Silme işlemi için kartı sola kaydırın.");
                },
              ),
              const Divider(height: 1, color: Colors.white24),
              _buildOptionTile(
                context: context,
                icon: Icons.arrow_back_ios_new_rounded,
                text: 'Geri',
                textColor: Colors.grey[400],
                onTap: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOptionTile({
    required BuildContext context,
    required IconData icon,
    required String text,
    required VoidCallback onTap,
    Color? textColor,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: const BorderRadius.vertical(
            top: Radius.circular(24), bottom: Radius.circular(24)),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
          child: Row(
            children: [
              Icon(icon, color: textColor ?? Colors.white.withAlpha(230)),
              const SizedBox(width: 16),
              Text(
                text,
                style: TextStyle(
                  color: textColor ?? Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
