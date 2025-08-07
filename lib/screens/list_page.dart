// lib/screens/list_page.dart
import 'package:flutter/material.dart';
import '../widgets/action_card.dart';
import '../widgets/shimmer_title_header.dart';
import './stok_yonet_page.dart'; // StokYonetPage'e buradan gidilecek
import './manage_customers_page.dart'; // Yeni eklenen sayfa

class ListPage extends StatelessWidget {
  const ListPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Bu Scaffold, ListPage'in iç Navigator'ı tarafından yönetilecek
    // ana ekranı temsil eder.
    return Scaffold(
      appBar: const ShimmerTitleHeader(
        title: 'İşlemler',
      ),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 20),
            ActionCard(
              imagePath: 'assets/images/manage_stocks_icon.png',
              title: 'Stokları Yönet',
              onTap: () {
                // Bu Navigator.push, ListPage'in iç Navigator'ını kullanacak
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const StokYonetPage(),
                  ),
                );
              },
            ),
            ActionCard(
              icon: Icons.account_balance_wallet_rounded, // Cari yönetimi ikonu
              title: 'Carileri Yönet',
              iconSize: 48.0,
              iconColor: Colors.teal,
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const ManageCustomersPage(),
                  ),
                );
              },
            ),
            // Buraya başka ActionCard'lar eklenebilir, örneğin doğrudan Stok Listesi'ne
            // gitmek için bir kart:
            // const SizedBox(height: 10),
            // ActionCard(
            //   imagePath: 'assets/images/list_stocks_icon.png',
            //   title: 'Stok Listesi',
            //   onTap: () {
            //     Navigator.of(context).push(
            //       MaterialPageRoute(
            //         builder: (_) => const StockListPage(),
            //       ),
            //     );
            //   },
            // ),
          ],
        ),
      ),
    );
  }
}
