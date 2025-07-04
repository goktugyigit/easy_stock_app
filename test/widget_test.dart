// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

// import 'package:flutter/material.dart'; // Bu satır zaten yorumda veya silinmişti, doğru.
import 'package:flutter_test/flutter_test.dart';

// lib/main.dart dosyasını import ettiğimizde içindeki MyApp sınıfına erişebilmeliyiz.
// Paket adının 'easy_stock_app' olduğundan emin olun (projenizin pubspec.yaml'daki name alanı)
import 'package:easy_stock_app/main.dart';

void main() {
  testWidgets('App bar title smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    // EasyStockApp() yerine MyApp() kullanın
    await tester.pumpWidget(const MyApp()); // <--- DÜZELTME BURADA

    // Verify that our app bar title is correct.
    // Uygulamanızın başlığı '40px İkon Testi' olarak güncellenmişti.
    expect(find.text('40px İkon Testi'), findsOneWidget); // <--- TEST EDİLEN METNİ DE GÜNCELLEYİN
  });
}