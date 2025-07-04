// lib/screens/manage_warehouses_page.dart
import 'package:flutter/material.dart';
import '../widgets/action_card.dart';
import './add_edit_warehouse_page.dart';
import './warehouse_list_page.dart'; // YENİ

class ManageWarehousesPage extends StatelessWidget {
  const ManageWarehousesPage({super.key});

  static const double _bottomNavBarSpaceEstimate = 88.0;

  @override
  Widget build(BuildContext context) {
    final double systemBottomPadding = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Depoları Yönet'),
      ),
      body: SafeArea(
        child: ListView(
          padding: EdgeInsets.only(
            top: 10.0,
            bottom: _bottomNavBarSpaceEstimate + systemBottomPadding + 10.0,
          ),
          children: <Widget>[
            ActionCard(
              imagePath: 'assets/images/add_icon_placeholder.png',
              title: 'Depo Ekle',
              iconSize: 48.0,
              onTap: () {
                Navigator.of(context, rootNavigator: true).push(
                  MaterialPageRoute(builder: (ctx) => const AddEditWarehousePage()),
                );
              },
            ),
            ActionCard(
              imagePath: 'assets/images/list_icon_placeholder.png',
              title: 'Depolarım',
              iconSize: 48.0,
              onTap: () {
                // WarehouseListPage'i KÖK NAVIGATOR'a push et
                Navigator.of(context, rootNavigator: true).push(
                  MaterialPageRoute(builder: (ctx) => const WarehouseListPage()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}