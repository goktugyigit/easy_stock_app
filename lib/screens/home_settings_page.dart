// lib/screens/home_settings_page.dart
import 'package:flutter/material.dart';
import '../widgets/action_card.dart'; // ActionCard'ı kullanacağız
import './settings_page.dart';     // Stok Eşik Ayarları bu sayfaya gidecek

class HomeSettingsPage extends StatelessWidget {
  const HomeSettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ayarlar Ana Sayfası'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(vertical: 20.0),
          children: [
            ActionCard(
              // Uygun bir ikon yolu belirlemelisin,
              // örneğin: 'assets/images/threshold_settings_icon.png'
              // Resimdeki ikonu kullanmak için doğru yolu girin.
              // Eğer resimdeki ikonun adı "stock_threshold_icon.png" ise:
              imagePath: 'assets/images/stock_threshold_icon.png', // GÖRSELDEKİ İKONUN YOLU
              title: 'Stok Eşik Ayarları',
              iconSize: 48.0, // DEĞİŞİKLİK: İkon boyutunu büyüttük (örneğin 64)
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const SettingsPage(),
                  ),
                );
              },
            ),
            // Diğer ActionCard'lar eklenebilir...
          ],
        ),
      ),
    );
  }
}