// lib/models/stock_item.dart
class StockItem {
  final String id;
  String name;
  int quantity;
  String? localImagePath;
  String? shelfLocation;
  String? stockCode;
  String? category;
  String? brand;
  String? supplier;
  String? invoiceNumber;
  String? barcode;
  String? qrCode;
  int? alertThreshold;
  int? maxStockThreshold;

  // YENİ ALANLAR
  String? warehouseId; // Ait olduğu depo ID'si
  String? shopId;      // Ait olduğu dükkan ID'si

  StockItem({
    required this.id,
    required this.name,
    required this.quantity,
    this.localImagePath,
    this.shelfLocation,
    this.stockCode,
    this.category,
    this.brand,
    this.supplier,
    this.invoiceNumber,
    this.barcode,
    this.qrCode,
    this.alertThreshold,
    this.maxStockThreshold,
    this.warehouseId, // YENİ
    this.shopId,      // YENİ
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'quantity': quantity,
      'localImagePath': localImagePath,
      'shelfLocation': shelfLocation,
      'stockCode': stockCode,
      'category': category,
      'brand': brand,
      'supplier': supplier,
      'invoiceNumber': invoiceNumber,
      'barcode': barcode,
      'qrCode': qrCode,
      'alertThreshold': alertThreshold,
      'maxStockThreshold': maxStockThreshold,
      'warehouseId': warehouseId, // YENİ
      'shopId': shopId,          // YENİ
    };
  }

  factory StockItem.fromMap(Map<String, dynamic> map) {
    return StockItem(
      id: map['id'] as String,
      name: map['name'] as String,
      quantity: map['quantity'] as int,
      localImagePath: map['localImagePath'] as String?,
      shelfLocation: map['shelfLocation'] as String?,
      stockCode: map['stockCode'] as String?,
      category: map['category'] as String?,
      brand: map['brand'] as String?,
      supplier: map['supplier'] as String?,
      invoiceNumber: map['invoiceNumber'] as String?,
      barcode: map['barcode'] as String?,
      qrCode: map['qrCode'] as String?,
      alertThreshold: map['alertThreshold'] as int?,
      maxStockThreshold: map['maxStockThreshold'] as int?,
      warehouseId: map['warehouseId'] as String?, // YENİ
      shopId: map['shopId'] as String?,          // YENİ
    );
  }
}