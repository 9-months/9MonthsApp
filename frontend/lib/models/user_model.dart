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
  final String? partnerId;
  final String? linkCode;
  final DateTime? linkCodeExpiry;
  final String? dateOfBirth;
  final String? accountType;

  User({
    required this.uid,
    required this.email,
    required this.username,
    this.location,
    this.phone,
    this.partnerId,
    this.linkCode,
    this.linkCodeExpiry,
    this.dateOfBirth,
    this.accountType,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      uid: json['uid'] ?? json['_id'] ?? '',
      email: json['email'] ?? '',
      username: json['username'] ?? '',
      location: json['location'] as String?,
      phone: json['phone'] as String?,
      partnerId: json['partnerId'] as String?,
      linkCode: json['linkCode'] as String?,
      linkCodeExpiry: json['linkCodeExpiry'] != null
          ? DateTime.parse(json['linkCodeExpiry'])
          : null,
      dateOfBirth: json['dateofBirth'] as String?,
      accountType: json['accountType'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'email': email,
      'username': username,
      'location': location,
      'phone': phone,
      'partnerId': partnerId,
      'linkCode': linkCode,
      'linkCodeExpiry': linkCodeExpiry?.toIso8601String(),
      'dateofBirth': dateOfBirth,
      'accountType': accountType,
    };
  }

  User copyWith({
    String? uid,
    String? email,
    String? username,
    String? location,
    String? phone,
    String? partnerId,
    String? linkCode,
    DateTime? linkCodeExpiry,
    String? dateOfBirth,
    String? accountType,
  }) {
    return User(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      username: username ?? this.username,
      location: location ?? this.location,
      phone: phone ?? this.phone,
      partnerId: partnerId ?? this.partnerId,
      linkCode: linkCode ?? this.linkCode,
      linkCodeExpiry: linkCodeExpiry ?? this.linkCodeExpiry,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      accountType: accountType ?? this.accountType,
    );
  }
}
