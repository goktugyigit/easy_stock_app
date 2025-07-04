// lib/screens/manage_shops_page.dart
import 'package:flutter/material.dart';
import '../widgets/action_card.dart';
import './add_edit_shop_page.dart'; // YENİ
import './shop_list_page.dart';     // YENİ

class ManageShopsPage extends StatelessWidget {
  const ManageShopsPage({super.key});

  static const double _bottomNavBarSpaceEstimate = 88.0;


  @override
  Widget build(BuildContext context) {
    final double systemBottomPadding = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dükkanları Yönet'),
      ),
      body: SafeArea(
        child: ListView(
          padding: EdgeInsets.only( // Dikey padding'i ListView'a, yatay padding'i ActionCard'a
            top: 10.0,
            bottom: _bottomNavBarSpaceEstimate + systemBottomPadding + 10.0,
          ),
          children: <Widget>[
            ActionCard(
              imagePath: 'assets/images/add_icon_placeholder.png',
              title: 'Dükkan Ekle',
              iconSize: 48.0,
              onTap: () {
                // AddEditShopPage'i KÖK NAVIGATOR'a push et
                Navigator.of(context, rootNavigator: true).push(
                  MaterialPageRoute(builder: (ctx) => const AddEditShopPage()),
                );
              },
            ),
            ActionCard(
              imagePath: 'assets/images/list_icon_placeholder.png',
              title: 'Dükkanlarım',
              iconSize: 48.0,
              onTap: () {
                // ShopListPage'i KÖK NAVIGATOR'a push et
                Navigator.of(context, rootNavigator: true).push(
                  MaterialPageRoute(builder: (ctx) => const ShopListPage()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}