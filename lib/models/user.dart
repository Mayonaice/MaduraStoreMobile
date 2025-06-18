import 'dart:convert';

class User {
  final int id;
  final String name;
  final String email;
  final String role;
  final String phoneNumber;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    required this.phoneNumber,
  });

  // Convert user to JSON string
  String toJson() {
    return jsonEncode({
      'id': id,
      'name': name,
      'email': email,
      'role': role,
      'phoneNumber': phoneNumber,
    });
  }

  // Create user from JSON string
  factory User.fromJson(String jsonString) {
    final Map<String, dynamic> data = jsonDecode(jsonString);
    return User.fromMap(data);
  }

  // Create user from Map
  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'],
      name: map['name'],
      email: map['email'],
      role: map['role'],
      phoneNumber: map['phoneNumber'],
    );
  }

  // Copy with
  User copyWith({
    int? id,
    String? name,
    String? email,
    String? role,
    String? phoneNumber,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      role: role ?? this.role,
      phoneNumber: phoneNumber ?? this.phoneNumber,
    );
  }

  @override
  String toString() {
    return 'User(id: $id, name: $name, email: $email, role: $role, phoneNumber: $phoneNumber)';
  }
} 