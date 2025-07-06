// lib/providers/stock_provider.dart
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/stock_item.dart';

class StockProvider with ChangeNotifier {
  List<StockItem> _items = [];
  final Uuid _uuid = const Uuid();
  // Model değiştiği için (pinnedTimestamp eklendi) versiyonu artırmak,
  // eski verilerle çakışmayı önler.
  static const String _storageKey = 'stockItems_v5';
  bool _isFetching = false;
  bool _hasFetchedOnce = false;

  List<StockItem> get items => List.unmodifiable(_items);

  StockProvider() {
    debugPrint("StockProvider CONSTRUCTOR çağrıldı.");
  }

  Future<void> fetchAndSetItems({bool forceFetch = false}) async {
    if (_isFetching || (!forceFetch && _hasFetchedOnce)) return;
    _isFetching = true;
    
    try {
      final prefs = await SharedPreferences.getInstance();
      final List<String>? extractedData = prefs.getStringList(_storageKey);
      if (extractedData != null) {
        _items = extractedData.map((itemJson) {
          try {
            return StockItem.fromMap(json.decode(itemJson));
          } catch (e) {
            debugPrint('Veri parse edilirken hata: $e');
            return null;
          }
        }).where((item) => item != null).cast<StockItem>().toList();
      }
      _hasFetchedOnce = true;
    } catch (error) {
      debugPrint("fetchAndSetItems hatası: $error");
      _items = [];
    } finally {
      _isFetching = false;
      notifyListeners();
    }
  }

  Future<void> _saveItemsToPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final List<String> itemsJsonList = _items.map((item) => json.encode(item.toMap())).toList();
      await prefs.setStringList(_storageKey, itemsJsonList);
    } catch (error) {
      debugPrint('Kaydetme hatası: $error');
    }
  }

  /// Bir stoğun `isPinned` durumunu tersine çevirir ve zaman damgasını günceller.
  /// Bu, en son sabitlenenin en üste gelmesi için kritik öneme sahiptir.
  Future<void> togglePinStatus(String id) async {
    final itemIndex = _items.indexWhere((item) => item.id == id);
    if (itemIndex >= 0) {
      final item = _items[itemIndex];
      item.isPinned = !item.isPinned;

      // EĞER ÖĞE SABİTLENİYORSA, o anın zaman damgasını ata.
      // EĞER SABİTLEME KALDIRILIYORSA, zaman damgasını sıfırla (null).
      if (item.isPinned) {
        item.pinnedTimestamp = DateTime.now();
      } else {
        item.pinnedTimestamp = null;
      }
      
      debugPrint('Pin Durumu Değiştirildi: ${item.name}, Yeni Durum: ${item.isPinned}');
      
      notifyListeners();
      await _saveItemsToPrefs();
    }
  }

  /// Yeni bir stok öğesi ekler.
  void addItem({
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
    String? warehouseId,
    String? shopId,
  }) {
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
      warehouseId: warehouseId,
      shopId: shopId,
      // Yeni eklenen ürün sabitlenmemiş olur.
      isPinned: false,
      pinnedTimestamp: null,
    );
    _items.add(newItem);
    notifyListeners();
    _saveItemsToPrefs();
  }

  /// Silme işleminden sonra "Geri Al" için kullanılır.
  void addItemFromModel(StockItem item) {
    _items.add(item);
    notifyListeners();
    _saveItemsToPrefs();
  }

  /// Mevcut bir stok öğesini günceller.
  void updateItem({
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
    String? warehouseId,
    String? shopId,
  }) {
    final itemIndex = _items.indexWhere((item) => item.id == id);
    if (itemIndex >= 0) {
      final originalItem = _items[itemIndex];
      
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
        warehouseId: warehouseId,
        shopId: shopId,
        // DÜZELTME: Güncelleme sırasında sabitleme durumu ve zaman damgası korunur.
        isPinned: originalItem.isPinned,
        pinnedTimestamp: originalItem.pinnedTimestamp,
      );
      _items[itemIndex] = updatedItem;
      notifyListeners();
      _saveItemsToPrefs();
    }
  }

  /// Bir stok öğesini siler.
  void deleteItem(String id, {bool notify = true}) {
    final itemIndex = _items.indexWhere((item) => item.id == id);
    if (itemIndex >= 0) {
      _items.removeAt(itemIndex);
      if (notify) {
        notifyListeners();
      }
      _saveItemsToPrefs();
    }
  }

  /// ID'ye göre bir stok bulur.
  StockItem? findById(String id) {
    try {
      return _items.firstWhere((item) => item.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Barkod veya QR koda göre bir stok bulur.
  StockItem? findByBarcodeOrQr(String code) {
    if (code.isEmpty) return null;
    try {
      return _items.firstWhere(
        (item) =>
            (item.barcode?.trim() == code.trim()) ||
            (item.qrCode?.trim() == code.trim()),
      );
    } catch (e) {
      return null;
    }
  }
}
