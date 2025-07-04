// lib/screens/settings_page.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // FilteringTextInputFormatter için
import 'package:shared_preferences/shared_preferences.dart';

// Anahtar sabitleri (key constants)
const String globalAlertThresholdKey = 'globalAlertThreshold';
const String globalMaxStockThresholdKey = 'globalMaxStockThreshold'; // Fanus için yeni anahtar

// Bu fonksiyonlar global olarak erişilebilir olmalı.
// Ayrı bir utility dosyasına (örn: lib/utils/settings_prefs.dart) taşımak daha iyi bir pratik olabilir.
Future<void> saveGlobalAlertThreshold(int threshold) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setInt(globalAlertThresholdKey, threshold);
}

Future<int> getGlobalAlertThreshold() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getInt(globalAlertThresholdKey) ?? 10; // Varsayılan düşük stok eşiği: 10
}

Future<void> saveGlobalMaxStockThreshold(int threshold) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setInt(globalMaxStockThresholdKey, threshold);
}

Future<int> getGlobalMaxStockThreshold() async {
  final prefs = await SharedPreferences.getInstance();
  // Fanus için varsayılan maksimum stok (eğer ayarlanmamışsa %100 doluluk için)
  return prefs.getInt(globalMaxStockThresholdKey) ?? 100; 
}


class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final _alertThresholdController = TextEditingController();
  final _maxStockThresholdController = TextEditingController(); // Fanus için yeni controller
  bool _isLoading = true;
  final _formKey = GlobalKey<FormState>(); // Form validasyonu için

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    setState(() { _isLoading = true; }); // Yükleme başladığında göstergeyi aktif et
    final alertThreshold = await getGlobalAlertThreshold();
    final maxStockThreshold = await getGlobalMaxStockThreshold();
    if (mounted) {
      setState(() {
        _alertThresholdController.text = alertThreshold.toString();
        _maxStockThresholdController.text = maxStockThreshold.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _saveSettings() async {
    if (_formKey.currentState!.validate()) { // Formu valide et
      final newAlertThreshold = int.tryParse(_alertThresholdController.text);
      final newMaxStockThreshold = int.tryParse(_maxStockThresholdController.text);

      if (newAlertThreshold != null) { // Zaten validator pozitif olmasını sağlıyor
        await saveGlobalAlertThreshold(newAlertThreshold);
      }
      if (newMaxStockThreshold != null) { // Zaten validator pozitif olmasını sağlıyor
        await saveGlobalMaxStockThreshold(newMaxStockThreshold);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Ayarlar başarıyla kaydedildi!')),
        );
        // Ayarlar kaydedildikten sonra sayfayı yeniden yüklemeye gerek yok,
        // değerler zaten controller'larda ve SharedPreferences'ta güncel.
        // Ancak farklı bir sayfada bu değerler okunuyorsa, o sayfanın yeniden build olması gerekebilir.
      }
    } else {
       if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Lütfen geçerli değerler girin.')),
        );
      }
    }
  }

  @override
  void dispose() {
    _alertThresholdController.dispose();
    _maxStockThresholdController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Genel Ayarlar'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save_alt_outlined), // Daha uygun bir kaydet ikonu
            onPressed: _isLoading ? null : _saveSettings,
            tooltip: 'Ayarları Kaydet',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form( // Form widget'ı eklendi
                key: _formKey,
                child: ListView(
                  children: <Widget>[
                    Text(
                      'Stok Uyarıları',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(height: 12),
                    TextFormField( // TextField -> TextFormField
                      controller: _alertThresholdController,
                      decoration: const InputDecoration(
                        labelText: 'Genel Düşük Stok Alarm Eşiği',
                        hintText: 'Örn: 10',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.warning_amber_rounded),
                      ),
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Lütfen bir değer girin.';
                        }
                        final n = int.tryParse(value);
                        if (n == null || n <= 0) {
                          return 'Lütfen 0\'dan büyük bir sayı girin.';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Fanus Gösterge Ayarı',
                       style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(height: 12),
                    TextFormField( // TextField -> TextFormField
                      controller: _maxStockThresholdController,
                      decoration: const InputDecoration(
                        labelText: 'Genel Maksimum Stok Eşiği',
                        hintText: 'Örn: 100 (Fanus %100 doluluk için)',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.opacity_rounded), // Fanus benzeri bir ikon
                      ),
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Lütfen bir değer girin.';
                        }
                        final n = int.tryParse(value);
                        if (n == null || n <= 0) {
                          return 'Lütfen 0\'dan büyük bir sayı girin.';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 30),
                    ElevatedButton.icon(
                      icon: const Icon(Icons.save_alt_outlined),
                      label: const Text('Ayarları Kaydet'),
                      onPressed: _isLoading ? null : _saveSettings,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        textStyle: const TextStyle(fontSize: 16),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}