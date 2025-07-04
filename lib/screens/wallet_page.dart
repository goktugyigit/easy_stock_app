import 'package:flutter/material.dart';

class WalletPage extends StatelessWidget {
  const WalletPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      // appBar: AppBar(title: const Text('Cüzdan/Satışlar')), // İsteğe bağlı AppBar
      body: Center(
        child: Text(
          'Satışlar Sayfası (Geliştirilecek)',
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}