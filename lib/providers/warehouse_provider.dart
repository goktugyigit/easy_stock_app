// lib/providers/warehouse_provider.dart
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/warehouse_item.dart';

class WarehouseProvider with ChangeNotifier {
  List<WarehouseItem> _items = [];
  final Uuid _uuid = const Uuid();
  static const String _storageKey = 'warehouseItems_v1';
  bool _isFetching = false;
  bool _hasFetchedOnce = false;

  List<WarehouseItem> get items => List.unmodifiable(_items);

  WarehouseProvider() {
    debugPrint("WarehouseProvider CONSTRUCTOR çağrıldı.");
  }

  Future<void> fetchAndSetItems({bool forceFetch = false}) async {
    if (_isFetching || (!forceFetch && _hasFetchedOnce)) {
      debugPrint("WarehouseProvider: fetchAndSetItems çağrısı engellendi. isFetching: $_isFetching, hasFetchedOnce: $_hasFetchedOnce, forceFetch: $forceFetch");
      return;
    }
    _isFetching = true;
    debugPrint("WarehouseProvider: fetchAndSetItems BAŞLADI. forceFetch: $forceFetch");

    List<WarehouseItem> loadedItems = [];
    try {
      final prefs = await SharedPreferences.getInstance();
      if (!prefs.containsKey(_storageKey)) {
        debugPrint("WarehouseProvider: SharedPreferences'te anahtar yok (_storageKey: $_storageKey).");
      } else {
        final List<String>? extractedData = prefs.getStringList(_storageKey);
        if (extractedData == null || extractedData.isEmpty) {
          debugPrint("WarehouseProvider: SharedPreferences'te veri boş.");
        } else {
          loadedItems = extractedData
              .map((itemJson) {
                try {
                  return WarehouseItem.fromMap(json.decode(itemJson) as Map<String, dynamic>);
                } catch (e) {
                  debugPrint('Bir depo parse edilirken hata (fetchAndSetItems): $e, JSON: $itemJson');
                  return null;
                }
              })
              .where((item) => item != null)
              .cast<WarehouseItem>()
              .toList();
          debugPrint("WarehouseProvider: SharedPreferences'ten ${loadedItems.length} depo yüklendi.");
        }
      }
      _items = loadedItems;
      _hasFetchedOnce = true;
      notifyListeners();
      debugPrint("WarehouseProvider: fetchAndSetItems BİTTİ ve notifyListeners çağrıldı. Items count: ${_items.length}");
    } catch (error) {
      debugPrint("WarehouseProvider: fetchAndSetItems sırasında genel hata: $error");
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
      debugPrint("WarehouseProvider: ${_items.length} depo SharedPreferences'e kaydedildi.");
    } catch (error) {
      if (kDebugMode) {
        print('SharedPreferences\'a depo kaydedilirken hata: $error');
      }
    }
  }

  void addItem({
    required String name,
    String? address,
    String? localImagePath,
    double? latitude,
    double? longitude,
  }) {
    debugPrint("WarehouseProvider: addItem BAŞLADI - Mevcut items: ${_items.length}");
    final newItem = WarehouseItem(
      id: _uuid.v4(), name: name, address: address, localImagePath: localImagePath,
      latitude: latitude, longitude: longitude,
    );
    _items = List.from(_items)..add(newItem);
    if (kDebugMode) {
      print('Depo Eklendi (Provider): ${newItem.name}, Yeni Toplam: ${_items.length}');
    }
    notifyListeners();
    debugPrint("WarehouseProvider: addItem - notifyListeners ÇAĞRILDI");
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
      final updatedItem = WarehouseItem(
        id: id, name: name, address: address, localImagePath: localImagePath,
        latitude: latitude, longitude: longitude,
      );
      List<WarehouseItem> tempList = List.from(_items);
      tempList[itemIndex] = updatedItem;
      _items = tempList;
      if (kDebugMode) {
        print('Depo Güncellendi (Provider): ${updatedItem.name}');
      }
      notifyListeners();
      _saveItemsToPrefs();
    } else {
      if (kDebugMode) print('Güncellenecek depo bulunamadı: ID $id');
    }
  }

  void deleteItem(String id) {
    final itemIndex = _items.indexWhere((item) => item.id == id);
    if (itemIndex >= 0) {
      final itemName = _items[itemIndex].name;
      _items = List.from(_items)..removeAt(itemIndex);
      if (kDebugMode) print('Depo Silindi (Provider): $itemName (ID: $id)');
      notifyListeners();
      _saveItemsToPrefs();
    } else {
      if (kDebugMode) print('Silinecek depo bulunamadı: ID $id');
    }
  }

  WarehouseItem? findById(String id) {
    try {
      return _items.firstWhere((item) => item.id == id);
    } catch (e) {
      if (kDebugMode) print('ID ($id) ile depo bulunamadı (findById): $e');
      return null;
    }
  }
}