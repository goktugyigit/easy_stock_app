// lib/screens/wallet_page.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
// import 'package:intl/intl.dart'; // BU SATIRI KALDIRIN VEYA YORUMA ALIN
import '../providers/sale_provider.dart';
import '../models/sale_item.dart';
import '../widgets/sale_item_card.dart';
import '../widgets/shimmer_title_header.dart';

class WalletPage extends StatefulWidget {
  const WalletPage({super.key});

  @override
  State<WalletPage> createState() => _WalletPageState();
}

class _WalletPageState extends State<WalletPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        Provider.of<SaleProvider>(context, listen: false)
            .fetchAndSetItems(forceFetch: true);
      }
    });
  }

  Future<void> _refreshSales() async {
    if (mounted) {
      await Provider.of<SaleProvider>(context, listen: false)
          .fetchAndSetItems(forceFetch: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const ShimmerTitleHeader(
        title: 'Yapılan Satışlar',
      ),
      body: Consumer<SaleProvider>(
        builder: (context, saleProvider, child) {
          final List<SaleItem> sales = List.from(saleProvider.sales);
          sales.sort((a, b) => b.saleDate.compareTo(a.saleDate));

          if (sales.isEmpty) {
            return const Center(
              child: Text(
                'Henüz hiç satış yapılmamış.',
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: _refreshSales,
            child: ListView.builder(
              padding: const EdgeInsets.only(top: 8, bottom: 100),
              itemCount: sales.length,
              itemBuilder: (ctx, i) {
                return SaleItemCard(saleItem: sales[i]);
              },
            ),
          );
        },
      ),
    );
  }
}
