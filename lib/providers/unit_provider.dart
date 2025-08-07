// lib/providers/unit_provider.dart - BİRİM PROVIDER

import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/unit_item.dart';

class UnitProvider with ChangeNotifier {
  // Güvenli notifyListeners çağrısı için helper metod
  void _safeNotifyListeners() {
    if (WidgetsBinding.instance.lifecycleState != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        notifyListeners();
      });
    } else {
      Future.microtask(() => notifyListeners());
    }
  }

  List<UnitItem> _units = [];
  final String _storageKey = 'unitItems_v1';

  List<UnitItem> get units {
    return [..._units];
  }

  UnitItem? findById(String id) {
    try {
      return _units.firstWhere((unit) => unit.id == id);
    } catch (e) {
      return null;
    }
  }

  // Varsayılan birimleri oluştur
  void _createDefaultUnits() {
    final defaultUnits = [
      UnitItem(
        id: 'unit_adet',
        name: 'Adet',
        shortName: 'adet',
        isDefault: true,
      ),
      UnitItem(
        id: 'unit_kilogram',
        name: 'Kilogram',
        shortName: 'kg',
        isDefault: true,
      ),
      UnitItem(
        id: 'unit_gram',
        name: 'Gram',
        shortName: 'gr',
        isDefault: true,
      ),
      UnitItem(
        id: 'unit_litre',
        name: 'Litre',
        shortName: 'lt',
        isDefault: true,
      ),
      UnitItem(
        id: 'unit_metre',
        name: 'Metre',
        shortName: 'm',
        isDefault: true,
      ),
      UnitItem(
        id: 'unit_paket',
        name: 'Paket',
        shortName: 'pkt',
        isDefault: true,
      ),
      UnitItem(
        id: 'unit_kutu',
        name: 'Kutu',
        shortName: 'kutu',
        isDefault: true,
      ),
    ];

    _units.addAll(defaultUnits);
  }

  Future<void> fetchAndSetItems({bool forceFetch = false}) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final extractedData = prefs.getString(_storageKey);

      if (extractedData == null) {
        // İlk kez çalışıyorsa varsayılan birimleri oluştur
        _createDefaultUnits();
        await _saveToStorage();
        if (kDebugMode) {
          print('UnitProvider: Varsayılan birimler oluşturuldu.');
        }
      } else {
        final List<dynamic> unitList = json.decode(extractedData);
        final List<UnitItem> loadedUnits = unitList
            .map((item) => UnitItem.fromMap(item as Map<String, dynamic>))
            .toList();
        _units = loadedUnits;
        if (kDebugMode) {
          print('UnitProvider: ${_units.length} birim yüklendi.');
        }
      }

      _safeNotifyListeners();
    } catch (error) {
      if (kDebugMode) {
        print('UnitProvider fetchAndSetItems hatası: $error');
      }
      rethrow;
    }
  }

  Future<void> addUnit({
    required String name,
    required String shortName,
  }) async {
    try {
      if (kDebugMode) {
        print(
            'UnitProvider.addUnit: Başlıyor - name="$name", shortName="$shortName"');
      }

      final newUnit = UnitItem(
        id: 'unit_${DateTime.now().millisecondsSinceEpoch}',
        name: name,
        shortName: shortName,
        isDefault: false,
      );

      if (kDebugMode) {
        print(
            'UnitProvider.addUnit: Yeni birim oluşturuldu - ${newUnit.toString()}');
      }

      _units.add(newUnit);

      if (kDebugMode) {
        print(
            'UnitProvider.addUnit: Birim listeye eklendi. Toplam birim sayısı: ${_units.length}');
      }

      _safeNotifyListeners();

      if (kDebugMode) {
        print('UnitProvider.addUnit: notifyListeners() çağrıldı');
      }

      await _saveToStorage();

      if (kDebugMode) {
        print('UnitProvider.addUnit: Storage\'a kaydedildi');
      }
    } catch (error, stackTrace) {
      if (kDebugMode) {
        print('UnitProvider.addUnit HATA: $error');
        print('UnitProvider.addUnit StackTrace: $stackTrace');
      }
      rethrow;
    }
  }

  Future<void> updateUnit({
    required String id,
    required String name,
    required String shortName,
  }) async {
    final unitIndex = _units.indexWhere((unit) => unit.id == id);
    if (unitIndex >= 0) {
      final existingUnit = _units[unitIndex];
      _units[unitIndex] = existingUnit.copyWith(
        name: name,
        shortName: shortName,
      );
      _safeNotifyListeners();
      await _saveToStorage();
    }
  }

  Future<void> deleteUnit(String id) async {
    final unit = findById(id);
    if (unit != null) {
      _units.removeWhere((unit) => unit.id == id);
      _safeNotifyListeners();
      await _saveToStorage();
    }
  }

  Future<void> _saveToStorage() async {
    try {
      if (kDebugMode) {
        print('UnitProvider._saveToStorage: Başlıyor...');
      }

      final prefs = await SharedPreferences.getInstance();

      if (kDebugMode) {
        print('UnitProvider._saveToStorage: SharedPreferences alındı');
      }

      final unitData = json.encode(_units.map((unit) => unit.toMap()).toList());

      if (kDebugMode) {
        print(
            'UnitProvider._saveToStorage: JSON encode yapıldı. Data uzunluğu: ${unitData.length}');
      }

      await prefs.setString(_storageKey, unitData);

      if (kDebugMode) {
        print('UnitProvider._saveToStorage: Storage\'a kaydedildi');
      }
    } catch (error, stackTrace) {
      if (kDebugMode) {
        print('UnitProvider._saveToStorage HATA: $error');
        print('UnitProvider._saveToStorage StackTrace: $stackTrace');
      }
      rethrow;
    }
  }
}
