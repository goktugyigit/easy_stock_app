// lib/screens/warehouses_shops_page.dart
import 'package:flutter/material.dart';
import '../widgets/action_card.dart';
import '../widgets/shimmer_title_header.dart';
import './manage_warehouses_page.dart';
import './manage_shops_page.dart';

class WarehousesShopsPage extends StatelessWidget {
  const WarehousesShopsPage({super.key});

  // BottomNavigationBar için yaklaşık boşluk
  static const double _bottomNavBarSpaceEstimate = 88.0;

  @override
  Widget build(BuildContext context) {
    final double systemBottomPadding = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      appBar: const ShimmerTitleHeader(
        title: 'Depoları & Dükkanları Yönet',
      ),
      body: SafeArea(
        child: ListView(
          // DEĞİŞİKLİK: ListView'ın horizontal padding'i kaldırıldı veya 0 yapıldı.
          // ActionCard kendi horizontal padding'ini (20.0) zaten sağlıyor.
          padding: EdgeInsets.only(
            // left: 20.0, // KALDIRILDI
            // right: 20.0, // KALDIRILDI
            top:
                10.0, // Üst padding (veya ActionCard'ın vertical padding'ine güveniyorsak bu da azaltılabilir/kaldırılabilir)
            bottom: _bottomNavBarSpaceEstimate + systemBottomPadding + 10.0,
          ),
          children: <Widget>[
            ActionCard(
              // Bu kart kendi içinde horizontal: 20.0 padding'e sahip
              imagePath: 'assets/images/warehouse_icon_placeholder.png',
              title: 'Depoları Yönet',
              iconSize: 48.0,
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                      builder: (context) => const ManageWarehousesPage()),
                );
              },
            ),
            // SizedBox(height: 16.0), // ActionCard'ın kendi vertical: 8.0 padding'i var, bu yeterli olabilir
            // veya aradaki boşluğu artırmak için SizedBox kalabilir.
            // ActionCard'ın vertical padding'i 8 olduğu için, iki kart arasında 16 birim boşluk olur.
            // Eğer SizedBox(height:16) da kalırsa toplam 32 olur. Şimdilik kaldırıyorum.
            ActionCard(
              // Bu kart da kendi içinde horizontal: 20.0 padding'e sahip
              imagePath: 'assets/images/shop_icon_placeholder.png',
              title: 'Dükkanları Yönet',
              iconSize: 48.0,
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                      builder: (context) => const ManageShopsPage()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
