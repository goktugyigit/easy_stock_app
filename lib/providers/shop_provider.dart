// lib/providers/shop_provider.dart
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/shop_item.dart';

class ShopProvider with ChangeNotifier {
  List<ShopItem> _items = [];
  final Uuid _uuid = const Uuid();
  static const String _storageKey = 'shopItems_v1';
  bool _isFetching = false;
  bool _hasFetchedOnce = false;

  List<ShopItem> get items => List.unmodifiable(_items);

  ShopProvider() {
    debugPrint("ShopProvider CONSTRUCTOR çağrıldı.");
    // İlk fetch artık main.dart'tan değil, ilgili liste sayfasının initState'inden
    // veya RefreshIndicator'dan kontrollü bir şekilde yapılacak.
  }

  Future<void> fetchAndSetItems({bool forceFetch = false}) async {
    if (_isFetching || (!forceFetch && _hasFetchedOnce)) {
      debugPrint("ShopProvider: fetchAndSetItems çağrısı engellendi. isFetching: $_isFetching, hasFetchedOnce: $_hasFetchedOnce, forceFetch: $forceFetch");
      // Eğer zaten fetch edilmişse ve zorlama yoksa, mevcut state ile devam et.
      // notifyListeners() burada gereksiz olabilir çünkü state değişmedi.
      return;
    }
    _isFetching = true;
    // _hasFetchedOnce'ı burada true yapmak yerine, başarılı bir fetch sonrası yapalım.
    // Ancak, birden fazla çağrıyı engellemek için burada da set edilebilir.
    // Şimdilik, başarılı fetch sonrası set edelim.
    debugPrint("ShopProvider: fetchAndSetItems BAŞLADI. forceFetch: $forceFetch");

    List<ShopItem> loadedItems = [];
    try {
      final prefs = await SharedPreferences.getInstance();
      if (!prefs.containsKey(_storageKey)) {
        debugPrint("ShopProvider: SharedPreferences'te anahtar yok (_storageKey: $_storageKey).");
      } else {
        final List<String>? extractedData = prefs.getStringList(_storageKey);
        if (extractedData == null || extractedData.isEmpty) {
          debugPrint("ShopProvider: SharedPreferences'te veri boş.");
        } else {
          loadedItems = extractedData
              .map((itemJson) {
                try {
                  return ShopItem.fromMap(json.decode(itemJson) as Map<String, dynamic>);
                } catch (e) {
                  debugPrint('Bir dükkan parse edilirken hata (fetchAndSetItems): $e, JSON: $itemJson');
                  return null;
                }
              })
              .where((item) => item != null)
              .cast<ShopItem>()
              .toList();
          debugPrint("ShopProvider: SharedPreferences'ten ${loadedItems.length} dükkan yüklendi.");
        }
      }
      _items = loadedItems; // _items'a yeni instance'ı ata
      _hasFetchedOnce = true; // Başarılı fetch sonrası bayrağı set et
      notifyListeners();
      debugPrint("ShopProvider: fetchAndSetItems BİTTİ ve notifyListeners çağrıldı. Items count: ${_items.length}");
    } catch (error) {
      debugPrint("ShopProvider: fetchAndSetItems sırasında genel hata: $error");
      // Hata durumunda _items'ı değiştirmeyebiliriz veya boşaltabiliriz.
      // Şimdilik boşaltalım.
      _items = [];
      _hasFetchedOnce = true; // Hata olsa bile fetch denendi.
      notifyListeners(); // Hata durumunda da UI güncellensin (boş liste ile)
    } finally {
      _isFetching = false;
    }
  }

  Future<void> _saveItemsToPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final List<String> itemsJsonList = _items.map((item) => json.encode(item.toMap())).toList();
      await prefs.setStringList(_storageKey, itemsJsonList);
      debugPrint("ShopProvider: ${_items.length} dükkan SharedPreferences'e kaydedildi.");
    } catch (error) {
      debugPrint('SharedPreferences\'a dükkan kaydedilirken hata: $error');
    }
  }

  void addItem({
    required String name,
    String? address,
    String? localImagePath,
    double? latitude,
    double? longitude,
  }) {
    debugPrint("ShopProvider: addItem BAŞLADI - Mevcut items: ${_items.length}");
    final newItem = ShopItem(
      id: _uuid.v4(),
      name: name,
      address: address,
      localImagePath: localImagePath,
      latitude: latitude,
      longitude: longitude,
    );
    _items = List.from(_items)..add(newItem);
    debugPrint("ShopProvider: newItem eklendi. YENİ items: ${_items.length}");
    notifyListeners();
    debugPrint("ShopProvider: addItem - notifyListeners ÇAĞRILDI");
    _saveItemsToPrefs();
  }

  void updateItem({
    required String id,
    required String name,
    String? address,
    String? localImagePath,
    double? latitude,
    double? longitude,
  }) {
    final itemIndex = _items.indexWhere((item) => item.id == id);
    if (itemIndex >= 0) {
      final updatedItem = ShopItem(
        id: id, name: name, address: address, localImagePath: localImagePath,
        latitude: latitude, longitude: longitude,
      );
      List<ShopItem> tempList = List.from(_items);
      tempList[itemIndex] = updatedItem;
      _items = tempList;
      notifyListeners();
      _saveItemsToPrefs();
    } else {
      debugPrint('Güncellenecek dükkan bulunamadı: ID $id');
    }
  }

  void deleteItem(String id) {
    final itemIndex = _items.indexWhere((item) => item.id == id);
    if (itemIndex >= 0) {
      _items = List.from(_items)..removeAt(itemIndex);
      notifyListeners();
      _saveItemsToPrefs();
    } else {
      debugPrint('Silinecek dükkan bulunamadı: ID $id');
    }
  }

  ShopItem? findById(String id) {
    try {
      return _items.firstWhere((item) => item.id == id);
    } catch (e) {
      debugPrint('ID ($id) ile dükkan bulunamadı (findById): $e');
      return null;
    }
  }
}