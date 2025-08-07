// lib/providers/supplier_provider.dart - TEDARİKÇİ PROVIDER

import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/supplier_item.dart';

class SupplierProvider with ChangeNotifier {
  List<SupplierItem> _suppliers = [];
  final String _storageKey = 'supplierItems_v1';

  List<SupplierItem> get suppliers {
    return [..._suppliers];
  }

  SupplierItem? findById(String id) {
    try {
      return _suppliers.firstWhere((supplier) => supplier.id == id);
    } catch (e) {
      return null;
    }
  }

  Future<void> fetchAndSetItems({bool forceFetch = false}) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final extractedData = prefs.getString(_storageKey);

      if (extractedData == null) {
        _suppliers = [];
        if (kDebugMode) {
          print('SupplierProvider: Henüz tedarikçi eklenmemiş.');
        }
      } else {
        final List<dynamic> supplierList = json.decode(extractedData);
        final List<SupplierItem> loadedSuppliers = supplierList
            .map((item) => SupplierItem.fromMap(item as Map<String, dynamic>))
            .toList();
        _suppliers = loadedSuppliers;
        if (kDebugMode) {
          print('SupplierProvider: ${_suppliers.length} tedarikçi yüklendi.');
        }
      }

      notifyListeners();
    } catch (error) {
      if (kDebugMode) {
        print('SupplierProvider fetchAndSetItems hatası: $error');
      }
      rethrow;
    }
  }

  Future<void> addSupplier({
    required String name,
    String? phoneNumber,
    String? email,
    String? address,
    String? contactPerson,
  }) async {
    final newSupplier = SupplierItem(
      id: 'supplier_${DateTime.now().millisecondsSinceEpoch}',
      name: name,
      phoneNumber: phoneNumber,
      email: email,
      address: address,
      contactPerson: contactPerson,
    );

    _suppliers.add(newSupplier);
    notifyListeners();
    await _saveToStorage();
  }

  Future<void> updateSupplier({
    required String id,
    required String name,
    String? phoneNumber,
    String? email,
    String? address,
    String? contactPerson,
  }) async {
    final supplierIndex =
        _suppliers.indexWhere((supplier) => supplier.id == id);
    if (supplierIndex >= 0) {
      _suppliers[supplierIndex] = SupplierItem(
        id: id,
        name: name,
        phoneNumber: phoneNumber,
        email: email,
        address: address,
        contactPerson: contactPerson,
      );
      notifyListeners();
      await _saveToStorage();
    }
  }

  Future<void> deleteSupplier(String id) async {
    _suppliers.removeWhere((supplier) => supplier.id == id);
    notifyListeners();
    await _saveToStorage();
  }

  Future<void> _saveToStorage() async {
    final prefs = await SharedPreferences.getInstance();
    final supplierData =
        json.encode(_suppliers.map((supplier) => supplier.toMap()).toList());
    await prefs.setString(_storageKey, supplierData);
  }
}
