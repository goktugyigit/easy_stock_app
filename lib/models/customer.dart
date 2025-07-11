// lib/models/customer.dart
class Customer {
  final String id;
  final String name; // Ad/Soyad veya Firma Adı
  final String? taxNumber; // Vergi Numarası
  final String? phone; // Telefon
  final String? email; // E-posta
  final String? address; // Adres
  final CustomerType type; // Müşteri/Tedarikçi
  final String? customerNumber; // Müşteri Numarası
  final String? supplierNumber; // Tedarikçi Numarası
  final double balance; // Bakiye (+ alacak, - borç)
  final String? notes; // Notlar
  final DateTime createdDate; // Oluşturulma Tarihi
  final DateTime? lastTransactionDate; // Son İşlem Tarihi

  Customer({
    required this.id,
    required this.name,
    this.taxNumber,
    this.phone,
    this.email,
    this.address,
    required this.type,
    this.customerNumber,
    this.supplierNumber,
    this.balance = 0.0,
    this.notes,
    required this.createdDate,
    this.lastTransactionDate,
  });

  // JSON'dan Customer nesnesi oluşturma
  factory Customer.fromJson(Map<String, dynamic> json) {
    return Customer(
      id: json['id'] as String,
      name: json['name'] as String,
      taxNumber: json['taxNumber'] as String?,
      phone: json['phone'] as String?,
      email: json['email'] as String?,
      address: json['address'] as String?,
      type: CustomerType.values.firstWhere(
        (e) => e.toString() == 'CustomerType.${json['type']}',
        orElse: () => CustomerType.customer,
      ),
      customerNumber: json['customerNumber'] as String?,
      supplierNumber: json['supplierNumber'] as String?,
      balance: (json['balance'] as num?)?.toDouble() ?? 0.0,
      notes: json['notes'] as String?,
      createdDate: DateTime.parse(json['createdDate'] as String),
      lastTransactionDate: json['lastTransactionDate'] != null
          ? DateTime.parse(json['lastTransactionDate'] as String)
          : null,
    );
  }

  // Customer nesnesini JSON'a çevirme
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'taxNumber': taxNumber,
      'phone': phone,
      'email': email,
      'address': address,
      'type': type.toString().split('.').last,
      'customerNumber': customerNumber,
      'supplierNumber': supplierNumber,
      'balance': balance,
      'notes': notes,
      'createdDate': createdDate.toIso8601String(),
      'lastTransactionDate': lastTransactionDate?.toIso8601String(),
    };
  }

  // Copy with method
  Customer copyWith({
    String? id,
    String? name,
    String? taxNumber,
    String? phone,
    String? email,
    String? address,
    CustomerType? type,
    String? customerNumber,
    String? supplierNumber,
    double? balance,
    String? notes,
    DateTime? createdDate,
    DateTime? lastTransactionDate,
  }) {
    return Customer(
      id: id ?? this.id,
      name: name ?? this.name,
      taxNumber: taxNumber ?? this.taxNumber,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      address: address ?? this.address,
      type: type ?? this.type,
      customerNumber: customerNumber ?? this.customerNumber,
      supplierNumber: supplierNumber ?? this.supplierNumber,
      balance: balance ?? this.balance,
      notes: notes ?? this.notes,
      createdDate: createdDate ?? this.createdDate,
      lastTransactionDate: lastTransactionDate ?? this.lastTransactionDate,
    );
  }

  @override
  String toString() {
    return 'Customer(id: $id, name: $name, type: $type, balance: $balance)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Customer && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  // Getter'lar
  bool get isCustomer => type == CustomerType.customer;
  bool get isSupplier => type == CustomerType.supplier;
  bool get hasDebt => balance < 0;
  bool get hasCredit => balance > 0;
  String get balanceDisplay => balance >= 0
      ? '+${balance.toStringAsFixed(2)}'
      : balance.toStringAsFixed(2);
  String get typeDisplay =>
      type == CustomerType.customer ? 'Müşteri' : 'Tedarikçi';
}

// Cari türü enum'u
enum CustomerType {
  customer, // Müşteri
  supplier, // Tedarikçi
}

// Customer Type Extension
extension CustomerTypeExtension on CustomerType {
  String get displayName {
    switch (this) {
      case CustomerType.customer:
        return 'Müşteri';
      case CustomerType.supplier:
        return 'Tedarikçi';
    }
  }

  String get icon {
    switch (this) {
      case CustomerType.customer:
        return '👤';
      case CustomerType.supplier:
        return '🏢';
    }
  }
}
