// lib/models/warehouse_item.dart
class WarehouseItem {
  final String id;
  String name;
  String? address;
  String? localImagePath;
  double? latitude;   // Harita için
  double? longitude;  // Harita için

  WarehouseItem({
    required this.id,
    required this.name,
    this.address,
    this.localImagePath,
    this.latitude,
    this.longitude,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'address': address,
      'localImagePath': localImagePath,
      'latitude': latitude,
      'longitude': longitude,
    };
  }

  factory WarehouseItem.fromMap(Map<String, dynamic> map) {
    return WarehouseItem(
      id: map['id'] as String,
      name: map['name'] as String,
      address: map['address'] as String?,
      localImagePath: map['localImagePath'] as String?,
      latitude: map['latitude'] as double?,
      longitude: map['longitude'] as double?,
    );
  }
}