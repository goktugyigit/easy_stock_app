// lib/providers/stock_provider.dart
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/stock_item.dart'; // Güncellenmiş StockItem modelini import ediyoruz

class StockProvider with ChangeNotifier {
  List<StockItem> _items = [];
  final Uuid _uuid = const Uuid();
  // _storageKey'i güncelledim, çünkü model değişti (warehouseId ve shopId eklendi)
  // Bu, eski verilerle uyumsuzluk olmaması için önemlidir.
  // Eğer eski verilerin yeni modele uygun şekilde migrate edilmesi gerekiyorsa,
  // fetchAndSetItems içinde bir kontrol ve dönüşüm mantığı eklenebilir.
  static const String _storageKey = 'stockItems_v3'; // Model değiştiği için güncellendi
  bool _isFetching = false;
  bool _hasFetchedOnce = false;

  // Getter HER ZAMAN _items listesinin bir KOPYASINI döndürmeli.
  List<StockItem> get items => List.unmodifiable(_items);

  StockProvider() {
    debugPrint("StockProvider CONSTRUCTOR çağrıldı.");
    // İlk fetch main.dart'tan kontrollü yapılacak
  }

  Future<void> fetchAndSetItems({bool forceFetch = false}) async {
    if (_isFetching || (!forceFetch && _hasFetchedOnce)) {
      debugPrint("StockProvider: fetchAndSetItems çağrısı engellendi. isFetching: $_isFetching, hasFetchedOnce: $_hasFetchedOnce, forceFetch: $forceFetch");
      return;
    }
    _isFetching = true;
    debugPrint("StockProvider: fetchAndSetItems BAŞLADI. forceFetch: $forceFetch");

    List<StockItem> loadedItems = [];
    try {
      final prefs = await SharedPreferences.getInstance();
      if (!prefs.containsKey(_storageKey)) {
        debugPrint("StockProvider: SharedPreferences'te anahtar yok (_storageKey: $_storageKey).");
      } else {
        final List<String>? extractedData = prefs.getStringList(_storageKey);
        if (extractedData == null || extractedData.isEmpty) {
          debugPrint("StockProvider: SharedPreferences'te veri boş.");
        } else {
          loadedItems = extractedData
              .map((itemJson) {
                try {
                  return StockItem.fromMap(json.decode(itemJson) as Map<String, dynamic>);
                } catch (e) {
                  debugPrint('Tek bir stok öğesi parse edilirken hata (fetchAndSetItems): $e, JSON: $itemJson');
                  return null;
                }
              })
              .where((item) => item != null)
              .cast<StockItem>()
              .toList();
          debugPrint("StockProvider: SharedPreferences'ten ${loadedItems.length} stok yüklendi.");
        }
      }
      _items = loadedItems;
      _hasFetchedOnce = true;
      notifyListeners();
      debugPrint("StockProvider: fetchAndSetItems BİTTİ ve notifyListeners çağrıldı. Items count: ${_items.length}");
    } catch (error) {
      debugPrint("StockProvider: fetchAndSetItems sırasında genel hata: $error");
      _items = [];
      _hasFetchedOnce = true;
      notifyListeners();
    } finally {
      _isFetching = false;
    }
  }

  Future<void> _saveItemsToPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final List<String> itemsJsonList = _items.map((item) => json.encode(item.toMap())).toList();
      await prefs.setStringList(_storageKey, itemsJsonList);
      debugPrint("StockProvider: ${_items.length} stok SharedPreferences'e kaydedildi.");
    } catch (error) {
      if (kDebugMode) {
        print('SharedPreferences\'a stok kaydedilirken hata: $error');
      }
    }
  }

  void addItem({ // Parametreler AddEditStockPage'deki sıraya göre güncellendi
    required String name,
    required int quantity,
    String? localImagePath,
    String? shelfLocation,
    String? stockCode,
    String? category,
    String? brand,
    String? supplier,
    String? invoiceNumber,
    String? barcode,
    String? qrCode,
    int? alertThreshold,
    int? maxStockThreshold,
    // YENİ ALANLAR EKLENDİ
    String? warehouseId,
    String? shopId,
  }) {
    debugPrint("StockProvider: addItem BAŞLADI - Mevcut items: ${_items.length}");
    final newItem = StockItem(
      id: _uuid.v4(),
      name: name,
      quantity: quantity,
      localImagePath: localImagePath,
      shelfLocation: shelfLocation,
      stockCode: stockCode,
      category: category,
      brand: brand,
      supplier: supplier,
      invoiceNumber: invoiceNumber,
      barcode: barcode,
      qrCode: qrCode,
      alertThreshold: alertThreshold,
      maxStockThreshold: maxStockThreshold,
      warehouseId: warehouseId, // YENİ
      shopId: shopId,          // YENİ
    );
    _items = List.from(_items)..add(newItem); // Yeni liste referansı ata
    if (kDebugMode) {
      print('Stok Eklendi (Provider): ${newItem.name}, DepoID: ${newItem.warehouseId}, DükkanID: ${newItem.shopId}, Yeni Toplam: ${_items.length}');
    }
    notifyListeners();
    debugPrint("StockProvider: addItem - notifyListeners ÇAĞRILDI");
    _saveItemsToPrefs();
  }

  void updateItem({ // Parametreler AddEditStockPage'deki sıraya göre güncellendi
    required String id,
    required String name,
    required int quantity,
    String? localImagePath,
    String? shelfLocation,
    String? stockCode,
    String? category,
    String? brand,
    String? supplier,
    String? invoiceNumber,
    String? barcode,
    String? qrCode,
    int? alertThreshold,
    int? maxStockThreshold,
    // YENİ ALANLAR EKLENDİ
    String? warehouseId,
    String? shopId,
  }) {
    final itemIndex = _items.indexWhere((item) => item.id == id);
    if (itemIndex >= 0) {
      final updatedItem = StockItem(
        id: id,
        name: name,
        quantity: quantity,
        localImagePath: localImagePath,
        shelfLocation: shelfLocation,
        stockCode: stockCode,
        category: category,
        brand: brand,
        supplier: supplier,
        invoiceNumber: invoiceNumber,
        barcode: barcode,
        qrCode: qrCode,
        alertThreshold: alertThreshold,
        maxStockThreshold: maxStockThreshold,
        warehouseId: warehouseId, // YENİ
        shopId: shopId,          // YENİ
      );
      List<StockItem> tempList = List.from(_items);
      tempList[itemIndex] = updatedItem;
      _items = tempList; // Yeni liste referansı ata

      if (kDebugMode) {
        print('Stok Güncellendi (Provider): ${updatedItem.name}');
      }
      notifyListeners();
      _saveItemsToPrefs();
    } else {
      if (kDebugMode) print('Güncellenecek stok bulunamadı: ID $id');
    }
  }

  void deleteItem(String id, {bool notify = true}) { // notify parametresi korundu
    final itemIndex = _items.indexWhere((item) => item.id == id);
    if (itemIndex >= 0) {
      final itemName = _items[itemIndex].name;
      _items = List.from(_items)..removeAt(itemIndex); // Yeni liste referansı ata

      if (kDebugMode) print('Stok Silindi (Provider): $itemName (ID: $id)');
      if (notify) { // notify parametresine göre davran
        notifyListeners();
      }
      _saveItemsToPrefs();
    } else {
      if (kDebugMode) print('Silinecek stok bulunamadı: ID $id');
    }
  }

  StockItem? findById(String id) {
    try {
      return _items.firstWhere((item) => item.id == id);
    } catch (e) {
      if (kDebugMode) print('ID ($id) ile stok bulunamadı (findById): $e');
      return null;
    }
  }

  StockItem? findByBarcodeOrQr(String code) {
    if (code.isEmpty) return null;
    try {
      return _items.firstWhere(
        (item) =>
            (item.barcode?.trim() == code.trim()) ||
            (item.qrCode?.trim() == code.trim()),
      );
    } catch (e) {
      if (kDebugMode) print('Barkod/QR ($code) ile stok bulunamadı (findByBarcodeOrQr): $e');
      return null;
    }
  }
}