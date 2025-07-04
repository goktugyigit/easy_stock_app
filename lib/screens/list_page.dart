// lib/screens/list_page.dart
import 'package:flutter/material.dart';
import '../widgets/action_card.dart';
import './stok_yonet_page.dart'; // StokYonetPage'e buradan gidilecek

class ListPage extends StatelessWidget {
  const ListPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Bu Scaffold, ListPage'in iç Navigator'ı tarafından yönetilecek
    // ana ekranı temsil eder.
    return Scaffold(
      appBar: AppBar(
        title: const Text('İşlemler'),
        centerTitle: true,
        // ÖNEMLİ: Eğer bu AppBar'ın geri butonu göstermesini istemiyorsan
        // (çünkü bu zaten bir sekmenin ana sayfası),
        // automaticallyImplyLeading: false ekleyebilirsin.
        // Ancak iç navigasyonda bir sonraki sayfaya gidildiğinde
        // oradaki AppBar'da geri butonu görünecektir.
        // automaticallyImplyLeading: false, 
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