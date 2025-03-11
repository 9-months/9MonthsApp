/*
 File: user-model.dart
 Purpose: Contains the user model class.
 Created Date: 11/02/2021 CCS-55 State Management
 Author: Dinith Perera

 last modified: 11/03/2025 | Chamod | CCS-67 model for partner role
*/

class User {
  final String uid;
  final String email;
  final String username;
  final String? location;
  final String? phone;
  final String? role;
  final String? partnerId;

  User({
    required this.uid,
    required this.email,
    required this.username,
    this.location,
    this.phone,
    this.role,
    this.partnerId,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      uid: json['uid'] ?? json['_id'] ?? '',
      email: json['email'] ?? '',
      username: json['username'] ?? '',
      location: json['location'] as String?,
      phone: json['phone'] as String?,
      role: json['role'] as String?,
      partnerId: json['partnerId'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'email': email,
      'username': username,
      'location': location,
      'phone': phone,
      'role': role,
      'partnerId': partnerId,
    };
  }

  User copyWith({
    String? uid,
    String? email,
    String? username,
    String? location,
    String? phone,
    String? role,
    String? partnerId,
  }) {
    return User(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      username: username ?? this.username,
      location: location ?? this.location,
      phone: phone ?? this.phone,
      role: role ?? this.role,
      partnerId: partnerId ?? this.partnerId,
    );
  }
}
