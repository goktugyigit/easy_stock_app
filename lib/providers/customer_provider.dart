// lib/providers/customer_provider.dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/customer.dart';

class CustomerProvider with ChangeNotifier {
  List<Customer> _customers = [];
  bool _isLoading = false;

  // Getter'lar
  List<Customer> get customers => [..._customers];
  bool get isLoading => _isLoading;

  // Filtreli listeler
  List<Customer> get customersOnly =>
      _customers.where((c) => c.isCustomer).toList();
  List<Customer> get suppliersOnly =>
      _customers.where((c) => c.isSupplier).toList();

  // İstatistikler
  int get totalCustomers => customersOnly.length;
  int get totalSuppliers => suppliersOnly.length;
  double get totalReceivables =>
      _customers.fold(0.0, (sum, c) => sum + (c.creditAmount));
  double get totalPayables =>
      _customers.fold(0.0, (sum, c) => sum + (c.debtAmount));

  // Yalnızca müşteriler seçildiğinde kullanılacak toplamlar
  double get totalCustomerDebts =>
      customersOnly.fold(0.0, (sum, c) => sum + c.debtAmount);
  double get totalCustomerCredits =>
      customersOnly.fold(0.0, (sum, c) => sum + c.creditAmount);
  double get totalCustomerBalance => totalCustomerDebts - totalCustomerCredits;

  // Yalnız tedarikçiler için toplamlar
  double get totalSupplierDebts =>
      suppliersOnly.fold(0.0, (sum, c) => sum + c.debtAmount);
  double get totalSupplierCredits =>
      suppliersOnly.fold(0.0, (sum, c) => sum + c.creditAmount);
  double get totalSupplierBalance => totalSupplierCredits - totalSupplierDebts;

  // SharedPreferences key
  static const String _customersKey = 'customers_data';

  // Carileri yükle
  Future<void> fetchAndSetCustomers({bool forceFetch = false}) async {
    if (_isLoading && !forceFetch) return;

    _isLoading = true;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final customersData = prefs.getString(_customersKey);

      if (customersData != null) {
        final List<dynamic> decodedData = json.decode(customersData);
        _customers =
            decodedData.map((item) => Customer.fromJson(item)).toList();

        // Tarihe göre sırala (en yeni önce)
        _customers.sort((a, b) => b.createdDate.compareTo(a.createdDate));
      } else {
        _customers = [];
      }
    } catch (error) {
      print('Cari yükleme hatası: $error');
      _customers = [];
    }

    _isLoading = false;
    notifyListeners();
  }

  // Carileri kaydet
  Future<void> _saveCustomers() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final customersData =
          json.encode(_customers.map((c) => c.toJson()).toList());
      await prefs.setString(_customersKey, customersData);
    } catch (error) {
      print('Cari kaydetme hatası: $error');
      throw Exception('Cari kaydetme işlemi başarısız oldu');
    }
  }

  // Sonraki müşteri numarasını al
  String _getNextCustomerNumber() {
    final existingCustomers = customersOnly;
    if (existingCustomers.isEmpty) return '1';

    int maxNumber = 0;
    for (final customer in existingCustomers) {
      if (customer.customerNumber != null) {
        final number = int.tryParse(customer.customerNumber!) ?? 0;
        if (number > maxNumber) maxNumber = number;
      }
    }
    return (maxNumber + 1).toString();
  }

  // Sonraki tedarikçi numarasını al
  String _getNextSupplierNumber() {
    final existingSuppliers = suppliersOnly;
    if (existingSuppliers.isEmpty) return '1';

    int maxNumber = 0;
    for (final supplier in existingSuppliers) {
      if (supplier.supplierNumber != null) {
        final number = int.tryParse(supplier.supplierNumber!) ?? 0;
        if (number > maxNumber) maxNumber = number;
      }
    }
    return (maxNumber + 1).toString();
  }

  // Yeni cari ekle
  Future<void> addCustomer({
    required String name,
    String? customerNumber,
    String? supplierNumber,
    String? taxNumber,
    String? phone,
    String? email,
    String? address,
    required CustomerType type,
    double initialDebt = 0.0,
    double initialCredit = 0.0,
    String? notes,
  }) async {
    try {
      // Otomatik numara oluştur (eğer verilmemişse)
      String? finalCustomerNumber = customerNumber;
      String? finalSupplierNumber = supplierNumber;

      if (type == CustomerType.customer &&
          (customerNumber == null || customerNumber.isEmpty)) {
        finalCustomerNumber = _getNextCustomerNumber();
      }

      if (type == CustomerType.supplier &&
          (supplierNumber == null || supplierNumber.isEmpty)) {
        finalSupplierNumber = _getNextSupplierNumber();
      }

      final newCustomer = Customer(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: name,
        taxNumber: taxNumber,
        phone: phone,
        email: email,
        address: address,
        type: type,
        customerNumber: finalCustomerNumber,
        supplierNumber: finalSupplierNumber,
        initialDebt: initialDebt,
        initialCredit: initialCredit,
        notes: notes,
        createdDate: DateTime.now(),
      );

      _customers.add(newCustomer);
      await _saveCustomers();
      notifyListeners();
    } catch (error) {
      print('Cari ekleme hatası: $error');
      throw Exception('Cari ekleme işlemi başarısız oldu');
    }
  }

  // Cari güncelle
  Future<void> updateCustomer({
    required String id,
    required String name,
    String? customerNumber,
    String? supplierNumber,
    String? taxNumber,
    String? phone,
    String? email,
    String? address,
    required CustomerType type,
    double initialDebt = 0.0,
    double initialCredit = 0.0,
    String? notes,
  }) async {
    try {
      final customerIndex = _customers.indexWhere((c) => c.id == id);
      if (customerIndex >= 0) {
        final customer = _customers[customerIndex];
        _customers[customerIndex] = customer.copyWith(
          name: name,
          taxNumber: taxNumber,
          phone: phone,
          email: email,
          address: address,
          type: type,
          customerNumber: customerNumber,
          supplierNumber: supplierNumber,
          initialDebt: initialDebt,
          initialCredit: initialCredit,
          notes: notes,
        );

        await _saveCustomers();
        notifyListeners();
      }
    } catch (error) {
      print('Cari güncelleme hatası: $error');
      throw Exception('Cari güncelleme işlemi başarısız oldu');
    }
  }

  // Cari sil
  Future<void> deleteCustomer(String id) async {
    try {
      _customers.removeWhere((c) => c.id == id);
      await _saveCustomers();
      notifyListeners();
    } catch (error) {
      print('Cari silme hatası: $error');
      throw Exception('Cari silme işlemi başarısız oldu');
    }
  }

  // ID'ye göre cari bul
  Customer? findById(String id) {
    try {
      return _customers.firstWhere((c) => c.id == id);
    } catch (e) {
      return null;
    }
  }

  // Arama/filtreleme
  List<Customer> searchCustomers(String query, {CustomerType? filterType}) {
    if (query.isEmpty && filterType == null) {
      return customers;
    }

    List<Customer> filtered = customers;

    // Tipe göre filtrele
    if (filterType != null) {
      filtered = filtered.where((c) => c.type == filterType).toList();
    }

    // Metne göre ara
    if (query.isNotEmpty) {
      final searchQuery = query.toLowerCase();
      filtered = filtered.where((c) {
        return c.name.toLowerCase().contains(searchQuery) ||
            (c.taxNumber?.toLowerCase().contains(searchQuery) ?? false) ||
            (c.phone?.toLowerCase().contains(searchQuery) ?? false) ||
            (c.email?.toLowerCase().contains(searchQuery) ?? false);
      }).toList();
    }

    return filtered;
  }

  // Bakiye güncelle
  Future<void> updateBalance(String customerId, double amount,
      {String? description}) async {
    try {
      final customerIndex = _customers.indexWhere((c) => c.id == customerId);
      if (customerIndex >= 0) {
        final customer = _customers[customerIndex];
        _customers[customerIndex] = customer.copyWith(
          balance: customer.balance + amount,
          lastTransactionDate: DateTime.now(),
        );

        await _saveCustomers();
        notifyListeners();
      }
    } catch (error) {
      print('Bakiye güncelleme hatası: $error');
      throw Exception('Bakiye güncelleme işlemi başarısız oldu');
    }
  }

  // Cari listesini temizle
  Future<void> clearAllCustomers() async {
    try {
      _customers.clear();
      await _saveCustomers();
      notifyListeners();
    } catch (error) {
      print('Cari temizleme hatası: $error');
      throw Exception('Cari temizleme işlemi başarısız oldu');
    }
  }

  // Örnek veriler ekle (test için)
  Future<void> addSampleData() async {
    try {
      final sampleCustomers = [
        Customer(
          id: 'customer_1',
          name: 'Ali Yılmaz',
          taxNumber: '1234567890',
          phone: '0532 123 4567',
          email: 'ali@example.com',
          address: 'Atatürk Mah. No:15 Kadıköy/İstanbul',
          type: CustomerType.customer,
          customerNumber: '1',
          balance: 1250.75,
          notes: 'Düzenli müşteri',
          createdDate: DateTime.now().subtract(const Duration(days: 30)),
          lastTransactionDate: DateTime.now().subtract(const Duration(days: 5)),
        ),
        Customer(
          id: 'customer_2',
          name: 'Ayşe Demir',
          taxNumber: '0987654321',
          phone: '0533 234 5678',
          email: 'ayse@example.com',
          address: 'Çamlıca Sok. No:8 Üsküdar/İstanbul',
          type: CustomerType.customer,
          customerNumber: '2',
          balance: -500.0,
          notes: 'Vadeli alışveriş yapıyor',
          createdDate: DateTime.now().subtract(const Duration(days: 45)),
          lastTransactionDate:
              DateTime.now().subtract(const Duration(days: 10)),
        ),
        Customer(
          id: 'supplier_1',
          name: 'ABC Ltd. Şti.',
          taxNumber: '5555555555',
          phone: '0212 555 0123',
          email: 'info@abc.com',
          address: 'Levent Mah. Büyükdere Cad. No:100 Şişli/İstanbul',
          type: CustomerType.supplier,
          supplierNumber: '1',
          balance: -2750.0,
          notes: 'Ana tedarikçimiz',
          createdDate: DateTime.now().subtract(const Duration(days: 60)),
          lastTransactionDate: DateTime.now().subtract(const Duration(days: 3)),
        ),
      ];

      _customers.addAll(sampleCustomers);
      await _saveCustomers();
      notifyListeners();
    } catch (error) {
      print('Örnek veri ekleme hatası: $error');
      throw Exception('Örnek veri ekleme işlemi başarısız oldu');
    }
  }
}
