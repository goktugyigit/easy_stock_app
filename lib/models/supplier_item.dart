// lib/models/supplier_item.dart - TEDARİKÇİ MODELİ

import 'dart:convert';

class SupplierItem {
  final String id;
  final String name;
  final String? phoneNumber;
  final String? email;
  final String? address;
  final String? contactPerson;

  SupplierItem({
    required this.id,
    required this.name,
    this.phoneNumber,
    this.email,
    this.address,
    this.contactPerson,
  });

  SupplierItem copyWith({
    String? id,
    String? name,
    String? phoneNumber,
    String? email,
    String? address,
    String? contactPerson,
  }) {
    return SupplierItem(
      id: id ?? this.id,
      name: name ?? this.name,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      email: email ?? this.email,
      address: address ?? this.address,
      contactPerson: contactPerson ?? this.contactPerson,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'phoneNumber': phoneNumber,
      'email': email,
      'address': address,
      'contactPerson': contactPerson,
    };
  }

  factory SupplierItem.fromMap(Map<String, dynamic> map) {
    return SupplierItem(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      phoneNumber: map['phoneNumber'],
      email: map['email'],
      address: map['address'],
      contactPerson: map['contactPerson'],
    );
  }

  String toJson() => json.encode(toMap());

  factory SupplierItem.fromJson(String source) =>
      SupplierItem.fromMap(json.decode(source));

  @override
  String toString() {
    return 'SupplierItem(id: $id, name: $name, phoneNumber: $phoneNumber, email: $email, address: $address, contactPerson: $contactPerson)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is SupplierItem &&
        other.id == id &&
        other.name == name &&
        other.phoneNumber == phoneNumber &&
        other.email == email &&
        other.address == address &&
        other.contactPerson == contactPerson;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        name.hashCode ^
        phoneNumber.hashCode ^
        email.hashCode ^
        address.hashCode ^
        contactPerson.hashCode;
  }
}
