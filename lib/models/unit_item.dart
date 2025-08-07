// lib/models/unit_item.dart - BİRİM MODELİ

import 'dart:convert';

class UnitItem {
  final String id;
  final String name;
  final String shortName; // Kısaltma (adet, kg, m vb.)
  final bool isDefault; // Varsayılan birimler (silinemez)

  UnitItem({
    required this.id,
    required this.name,
    required this.shortName,
    this.isDefault = false,
  });

  UnitItem copyWith({
    String? id,
    String? name,
    String? shortName,
    bool? isDefault,
  }) {
    return UnitItem(
      id: id ?? this.id,
      name: name ?? this.name,
      shortName: shortName ?? this.shortName,
      isDefault: isDefault ?? this.isDefault,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'shortName': shortName,
      'isDefault': isDefault,
    };
  }

  factory UnitItem.fromMap(Map<String, dynamic> map) {
    return UnitItem(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      shortName: map['shortName'] ?? '',
      isDefault: map['isDefault'] ?? false,
    );
  }

  String toJson() => json.encode(toMap());

  factory UnitItem.fromJson(String source) =>
      UnitItem.fromMap(json.decode(source));

  @override
  String toString() {
    return 'UnitItem(id: $id, name: $name, shortName: $shortName, isDefault: $isDefault)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is UnitItem &&
        other.id == id &&
        other.name == name &&
        other.shortName == shortName &&
        other.isDefault == isDefault;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        name.hashCode ^
        shortName.hashCode ^
        isDefault.hashCode;
  }
}
