// lib/main.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import './providers/stock_provider.dart';
import './providers/warehouse_provider.dart';
import './providers/shop_provider.dart';
import './providers/sale_provider.dart'; // YENİ IMPORT: SaleProvider eklendi
import './widgets/main_screen_with_bottom_nav.dart';
import './utils/app_theme.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          // DEĞİŞİKLİK: ..fetchAndSetItems() kaldırıldı
          create: (ctx) => StockProvider(),
        ),
        ChangeNotifierProvider(
          // DEĞİŞİKLİK: ..fetchAndSetItems(forceFetch: true) kaldırıldı
          create: (ctx) => WarehouseProvider(),
        ),
        ChangeNotifierProvider(
          // DEĞİŞİKLİK: ..fetchAndSetItems(forceFetch: true) kaldırıldı
          create: (ctx) => ShopProvider(),
        ),
        ChangeNotifierProvider(
          // YENİ: SaleProvider eklendi
          create: (ctx) => SaleProvider(),
        ),
      ],
      child: MaterialApp(
        title: 'Easy Stock App',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.darkTheme,
        home: const MainScreenWithBottomNav(),
      ),
    );
  }
}
