// lib/main.dart - BEYAZ EKRAN SORUNU İÇİN GÜNCELLENDİ

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import './providers/stock_provider.dart';
import './providers/warehouse_provider.dart';
import './providers/shop_provider.dart';
import './providers/sale_provider.dart';
import './providers/customer_provider.dart';
import './widgets/main_screen_with_bottom_nav.dart';
import './utils/app_theme.dart';
import './utils/text_scale_fix.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => StockProvider()),
        ChangeNotifierProvider(create: (_) => WarehouseProvider()),
        ChangeNotifierProvider(create: (_) => ShopProvider()),
        ChangeNotifierProvider(create: (_) => SaleProvider()),
        ChangeNotifierProvider(create: (_) => CustomerProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  // Veri yükleme durumunu takip etmek için bir Future
  Future<void>? _dataLoaderFuture;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Veri yükleme işlemini sadece bir kez başlat
    _dataLoaderFuture ??= _loadInitialData();
  }

  // Bütün provider'ların verilerini tek bir yerden yükleyen fonksiyon
  Future<void> _loadInitialData() async {
    try {
      // Widget tree tamamen inşa edildikten sonra çalıştırmak için post-frame callback kullan
      await Future.delayed(Duration.zero);

      // Mounted check ile context kullanımını güvenli hale getir
      if (!mounted) return;

      // `context.read<T>()` kullanarak provider'lara erişiyoruz.
      // Bu, `listen: false` ile Provider.of kullanmaya denktir.
      await Future.wait([
        context.read<StockProvider>().fetchAndSetItems(forceFetch: true),
        context.read<WarehouseProvider>().fetchAndSetItems(forceFetch: true),
        context.read<ShopProvider>().fetchAndSetItems(forceFetch: true),
        context.read<SaleProvider>().fetchAndSetItems(forceFetch: true),
        context.read<CustomerProvider>().fetchAndSetCustomers(forceFetch: true),
      ]);
    } catch (error) {
      debugPrint('Veri yükleme hatası: $error');
      // Hata durumunda bile devam et
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Easy Stock App',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      builder: (context, child) {
        return UnscaledTextWrapper(child: child!);
      },
      home: FutureBuilder(
        // Veri yükleme Future'ımızı dinliyoruz
        future: _dataLoaderFuture,
        builder: (context, snapshot) {
          // 1. Future henüz başlatılmadıysa veya veriler hala yükleniyorsa, bir yükleme ekranı göster
          if (_dataLoaderFuture == null ||
              snapshot.connectionState == ConnectionState.waiting) {
            return const SplashScreen(); // Yükleme ekranı
          }
          // 2. Bir hata oluştuysa, bir hata ekranı göster
          if (snapshot.hasError) {
            return ErrorScreen(error: snapshot.error.toString()); // Hata ekranı
          }
          // 3. Veriler başarıyla yüklendiyse, ana ekranı göster
          return const MainScreenWithBottomNav();
        },
      ),
    );
  }
}

// YÜKLEME EKRANI WIDGET'I (aynı dosyada)
class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: Colors.white),
            SizedBox(height: 20),
            Text('Veriler Yükleniyor...',
                style: TextStyle(color: Colors.white70)),
          ],
        ),
      ),
    );
  }
}

// HATA EKRANI WIDGET'I (aynı dosyada)
class ErrorScreen extends StatelessWidget {
  final String error;
  const ErrorScreen({super.key, required this.error});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, color: Colors.red, size: 50),
              const SizedBox(height: 20),
              const Text('Bir Hata Oluştu',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              Text(error,
                  style: const TextStyle(color: Colors.white70),
                  textAlign: TextAlign.center),
            ],
          ),
        ),
      ),
    );
  }
}
