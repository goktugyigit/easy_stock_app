// lib/models/shop_item.dart
class ShopItem {
  final String id;
  String name;
  String? address;
  String? localImagePath;
  double? latitude;   // Harita için
  double? longitude;  // Harita için
  // Dükkana özel ek alanlar buraya eklenebilir (örn: telefon, çalışma saatleri)
  // String? phoneNumber;
  // String? workingHours;

  ShopItem({
    required this.id,
    required this.name,
    this.address,
    this.localImagePath,
    this.latitude,
    this.longitude,
    // this.phoneNumber,
    // this.workingHours,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'address': address,
      'localImagePath': localImagePath,
      'latitude': latitude,
      'longitude': longitude,
      // 'phoneNumber': phoneNumber,
      // 'workingHours': workingHours,
    };
  }

  factory ShopItem.fromMap(Map<String, dynamic> map) {
    return ShopItem(
      id: map['id'] as String,
      name: map['name'] as String,
      address: map['address'] as String?,
      localImagePath: map['localImagePath'] as String?,
      latitude: map['latitude'] as double?,
      longitude: map['longitude'] as double?,
      // phoneNumber: map['phoneNumber'] as String?,
      // workingHours: map['workingHours'] as String?,
    );
  }
}