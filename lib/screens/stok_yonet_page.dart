// lib/screens/stok_yonet_page.dart
import 'package:flutter/material.dart';
import '../widgets/action_card.dart';
import './add_edit_stock_page.dart';
import './stock_list_page.dart';

class StokYonetPage extends StatelessWidget {
  const StokYonetPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Stok Yönetimi'),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 16.0),
        children: <Widget>[
          ActionCard(
            imagePath: 'assets/images/add_stock_icon.png', // KENDİ RESİM YOLUNU GİR
            title: 'Stok Kartı Oluştur',
            onTap: () {
              // AddEditStockPage'i kök navigator'a push et (BottomNav gizlenecek)
              Navigator.of(context, rootNavigator: true).push(
                MaterialPageRoute(
                    builder: (context) =>
                        const AddEditStockPage(showQuantityField: false)),
              ).then((_) {
                // Geri dönüldüğünde bir işlem yapmak istersen
              });
            },
          ),
          const SizedBox(height: 10), // Kartlar arası boşluk
          ActionCard(
            imagePath: 'assets/images/list_stocks_icon.png', // KENDİ RESİM YOLUNU GİR
            title: 'Stok Listesi',
            onTap: () {
              // StockListPage'i İÇ NAVIGATOR'a push et (BottomNav görünür kalacak)
              Navigator.of(context).push( // DEĞİŞİKLİK: rootNavigator: true KALDIRILDI
                MaterialPageRoute(builder: (context) => const StockListPage()),
              );
            },
          ),
        ],
      ),
    );
  }
}