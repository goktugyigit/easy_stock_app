// lib/widgets/dialogs/show_stock_options_dialog.dart
import 'package:flutter/material.dart';
import 'dart:ui';
import '../../models/stock_item.dart';
import '../../screens/add_edit_stock_page.dart';
import '../../screens/create_sale_page.dart';

Future<void> showStockOptionsDialog(BuildContext context, StockItem stockItem) {
  return showDialog(
    context: context,
    barrierColor: Colors.black.withAlpha(77),
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

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      // DEĞİŞİKLİK: Stack widget'ı kaldırıldı, doğrudan Center ile devam ediyoruz.
      child: Center(
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
                      MaterialPageRoute(builder: (_) => CreateSalePage(stockItem: stockItem)),
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
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Stok Transfer özelliği geliştirilecek.")));
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
                      MaterialPageRoute(builder: (_) => AddEditStockPage(existingItemId: stockItem.id)),
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
                    // TODO: Silme işlemi için ana sayfaya callback veya provider ile bildirim yapılmalı.
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Silme işlemi tetiklenecek.")));
                  },
                ),
                const Divider(height: 1, color: Colors.white24),
                _buildOptionTile(
                  context: context,
                  icon: Icons.arrow_back_ios_new_rounded,
                  text: 'Geri',
                  textColor: Colors.grey[400],
                  onTap: () {
                    Navigator.of(context).pop(); // Sadece diyaloğu kapat
                  },
                ),
              ],
            ),
          ),
        ),
      ),
      // DEĞİŞİKLİK: Stack'in children listesi kaldırıldı.
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
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24), bottom: Radius.circular(24)),
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