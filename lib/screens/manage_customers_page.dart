// lib/screens/manage_customers_page.dart
import 'package:flutter/material.dart';
import '../widgets/action_card.dart';
import './add_edit_customer_page.dart';
import './customer_list_page.dart';

class ManageCustomersPage extends StatelessWidget {
  const ManageCustomersPage({super.key});

  static const double _bottomNavBarSpaceEstimate = 88.0;

  @override
  Widget build(BuildContext context) {
    final double systemBottomPadding = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Carileri Yönet'),
        centerTitle: true,
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),
      backgroundColor: Colors.black,
      body: SafeArea(
        child: ListView(
          padding: EdgeInsets.only(
            top: 20.0,
            bottom: _bottomNavBarSpaceEstimate + systemBottomPadding + 10.0,
          ),
          children: <Widget>[
            ActionCard(
              icon: Icons.person_add_rounded, // Cari ekleme ikonu
              title: 'Cari Ekle',
              iconSize: 48.0,
              iconColor: Colors.blue,
              onTap: () {
                Navigator.of(context, rootNavigator: true).push(
                  MaterialPageRoute(
                      builder: (ctx) => const AddEditCustomerPage()),
                );
              },
            ),
            ActionCard(
              icon: Icons.list_alt_rounded, // Liste ikonu
              title: 'Cari Listesi',
              iconSize: 48.0,
              iconColor: Colors.green,
              onTap: () {
                Navigator.of(context, rootNavigator: true).push(
                  MaterialPageRoute(builder: (ctx) => const CustomerListPage()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
