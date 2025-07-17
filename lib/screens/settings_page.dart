// lib/screens/settings_page.dart
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart'; // iOS refresh için
import 'package:flutter/services.dart'; // FilteringTextInputFormatter için
import 'package:shared_preferences/shared_preferences.dart';
import '../widgets/corporate_header.dart';

// Anahtar sabitleri (key constants)
const String globalAlertThresholdKey = 'globalAlertThreshold';
const String globalMaxStockThresholdKey =
    'globalMaxStockThreshold'; // Fanus için yeni anahtar

// Bu fonksiyonlar global olarak erişilebilir olmalı.
// Ayrı bir utility dosyasına (örn: lib/utils/settings_prefs.dart) taşımak daha iyi bir pratik olabilir.
Future<void> saveGlobalAlertThreshold(int threshold) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setInt(globalAlertThresholdKey, threshold);
}

Future<int> getGlobalAlertThreshold() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getInt(globalAlertThresholdKey) ??
      10; // Varsayılan düşük stok eşiği: 10
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
  final _maxStockThresholdController =
      TextEditingController(); // Fanus için yeni controller
  bool _isLoading = true;
  final _formKey = GlobalKey<FormState>(); // Form validasyonu için

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    setState(() {
      _isLoading = true;
    }); // Yükleme başladığında göstergeyi aktif et
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
    if (_formKey.currentState!.validate()) {
      // Formu valide et
      final newAlertThreshold = int.tryParse(_alertThresholdController.text);
      final newMaxStockThreshold =
          int.tryParse(_maxStockThresholdController.text);

      if (newAlertThreshold != null) {
        // Zaten validator pozitif olmasını sağlıyor
        await saveGlobalAlertThreshold(newAlertThreshold);
      }
      if (newMaxStockThreshold != null) {
        // Zaten validator pozitif olmasını sağlıyor
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
      appBar: CorporateHeader(
        title: 'Genel Ayarlar',
        showBackButton: true,
        showSaveButton: true,
        centerTitle: true,
        onSavePressed: _isLoading ? null : _saveSettings,
      ),
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : CustomScrollView(
                // iOS refresh için gerekli physics
                physics: const BouncingScrollPhysics(
                  parent: AlwaysScrollableScrollPhysics(),
                ),
                slivers: [
                  // iOS tarzı refresh control
                  CupertinoSliverRefreshControl(
                    onRefresh: _loadSettings,
                    refreshTriggerPullDistance: 80.0,
                    refreshIndicatorExtent: 60.0,
                  ),
                  // Ana içerik
                  SliverPadding(
                    padding: EdgeInsets.only(
                      left: 16.0,
                      right: 16.0,
                      top: 16.0,
                      // Dinamik bottom padding - overflow çözümü (artırıldı)
                      bottom: MediaQuery.of(context).padding.bottom +
                          MediaQuery.of(context).viewInsets.bottom +
                          120.0,
                    ),
                    sliver: SliverList(
                      delegate: SliverChildListDelegate([
                      Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              'Stok Uyarıları',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleLarge
                                  ?.copyWith(fontWeight: FontWeight.w500),
                            ),
                            const SizedBox(height: 12),
                            TextFormField(
                              // TextField -> TextFormField
                              controller: _alertThresholdController,
                              decoration: const InputDecoration(
                                labelText: 'Genel Düşük Stok Alarm Eşiği',
                                hintText: 'Örn: 10',
                                border: OutlineInputBorder(),
                                prefixIcon: Icon(Icons.warning_amber_rounded),
                              ),
                              keyboardType: TextInputType.number,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly
                              ],
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
                              style: Theme.of(context)
                                  .textTheme
                                  .titleLarge
                                  ?.copyWith(fontWeight: FontWeight.w500),
                            ),
                            const SizedBox(height: 12),
                            TextFormField(
                              // TextField -> TextFormField
                              controller: _maxStockThresholdController,
                              decoration: const InputDecoration(
                                labelText: 'Genel Maksimum Stok Eşiği',
                                hintText: 'Örn: 100 (Fanus %100 doluluk için)',
                                border: OutlineInputBorder(),
                                prefixIcon: Icon(Icons
                                    .opacity_rounded), // Fanus benzeri bir ikon
                              ),
                              keyboardType: TextInputType.number,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly
                              ],
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
                          ],
                        ),
                      ),
                    ]),
                  ),
                ),
                ],
              ),
            ),
      );
  }
}
