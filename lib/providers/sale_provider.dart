// lib/providers/sale_provider.dart
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/sale_item.dart';
import '../models/stock_item.dart';

class SaleProvider with ChangeNotifier {
  List<SaleItem> _sales = [];
  final Uuid _uuid = const Uuid();
  static const String _storageKey = 'saleItems_v1';

  List<SaleItem> get sales => List.unmodifiable(_sales);

  SaleProvider() {
    // İlk yükleme main.dart'tan veya ilgili sayfadan yapılacak
  }

  Future<void> fetchAndSetItems({bool forceFetch = false}) async {
    // Bu provider da diğerleri gibi kontrollü fetch kullanabilir
    final prefs = await SharedPreferences.getInstance();
    if (!prefs.containsKey(_storageKey)) {
      _sales = [];
      notifyListeners();
      return;
    }
    final List<String>? extractedData = prefs.getStringList(_storageKey);
    if (extractedData == null || extractedData.isEmpty) {
      _sales = [];
      notifyListeners();
      return;
    }
    _sales = extractedData
        .map((itemJson) => SaleItem.fromMap(json.decode(itemJson) as Map<String, dynamic>))
        .toList();
    notifyListeners();
  }

  Future<void> _saveItemsToPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> itemsJsonList = _sales.map((item) => json.encode(item.toMap())).toList();
    await prefs.setStringList(_storageKey, itemsJsonList);
  }

  void addSale({
    required StockItem soldStockItem,
    required int quantitySold,
    String? customerName,
  }) {
    final newSale = SaleItem(
      id: _uuid.v4(),
      soldStockItem: soldStockItem,
      quantitySold: quantitySold,
      customerName: customerName,
      saleDate: DateTime.now(),
    );
    _sales = List.from(_sales)..add(newSale);
    notifyListeners();
    _saveItemsToPrefs();
    debugPrint("${newSale.quantitySold} adet ${newSale.soldStockItem.name} satıldı.");
  }
}