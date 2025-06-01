// lib/models/customer.dart
import 'package:hive/hive.dart';

part 'customer.g.dart';

@HiveType(typeId: 0)
class Customer extends HiveObject {
  @HiveField(0)
  final String id;
  @HiveField(1)
  final String name;
  @HiveField(2)
  final String email;
  @HiveField(3)
  final String phone;
  @HiveField(4)
  final bool isActive;

  Customer({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.isActive,
  });

  // For Firebase/Firestore
  factory Customer.fromMap(Map<String, dynamic> map) {
    return Customer(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      phone: map['phone'] ?? '',
      isActive: map['isActive'] ?? true,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'isActive': isActive,
    };
  }

  // For Hive/local storage
  factory Customer.fromJson(Map<String, dynamic> json) =>
      Customer.fromMap(json);
  Map<String, dynamic> toJson() => toMap();

  Customer copyWith({
    String? id,
    String? name,
    String? email,
    String? phone,
    bool? isActive,
  }) {
    return Customer(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      isActive: isActive ?? this.isActive,
    );
  }
}
