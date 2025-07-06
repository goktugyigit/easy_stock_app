// lib/models/sale_item.dart
import './stock_item.dart';

class SaleItem {
  final String id;
  final StockItem soldStockItem; // Hangi stoktan satıldığı bilgisi
  final int quantitySold;
  final String? customerName;
  final DateTime saleDate;
  // final String staffId; // Gelecekte eklenecek personel ID'si

  SaleItem({
    required this.id,
    required this.soldStockItem,
    required this.quantitySold,
    required this.saleDate,
    this.customerName,
    // required this.staffId,
  });

  // SharedPreferences için toMap ve fromMap
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'soldStockItem':
          soldStockItem.toMap(), // StockItem'ı da map'e çeviriyoruz
      'quantitySold': quantitySold,
      'customerName': customerName,
      'saleDate': saleDate.toIso8601String(), // Tarihi string olarak sakla
    };
  }

  factory SaleItem.fromMap(Map<String, dynamic> map) {
    return SaleItem(
      id: map['id'] as String,
      soldStockItem:
          StockItem.fromMap(map['soldStockItem'] as Map<String, dynamic>),
      quantitySold: map['quantitySold'] as int,
      customerName: map['customerName'] as String?,
      saleDate: DateTime.parse(map['saleDate'] as String),
    );
  }
}
