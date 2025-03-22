/*
 File: user-model.dart
 Purpose: Contains the user model class.
 Created Date: 11/02/2021 CCS-55 State Management
 Author: Dinith Perera

 last modified: 11/02/2021 | Dinith | CCS-55 model for user created
*/

class User {
  final String uid;
  final String email;
  final String username;
  final String accountType;
  final String? location;
  final String? phone;
  final String? dateOfBirth;
  final String? token;

  User({
    required this.uid,
    required this.email,
    required this.username,
    required this.accountType,
    this.location,
    this.phone,
    this.dateOfBirth,
    this.token,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      uid: json['uid'] ?? json['_id'] ?? '',
      email: json['email'] ?? '',
      username: json['username'] ?? '',
      location: json['location'] as String?,
      phone: json['phone'] as String?,
      accountType : json['accountType'] ?? 'mother',
      dateOfBirth: json['dateOfBirth'] as String?,
      token: json['token'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'email': email,
      'username': username,
      'location': location,
      'phone': phone,
      'dateOfBirth': dateOfBirth,
      'accountType': accountType,
      'token': token,
    };
  }

  User copyWith({
    String? uid,
    String? email,
    String? username,
    String? location,
    String? phone,
    String? dateOfBirth,
    String? accountType,
    String? token,
  }) {
    return User(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      username: username ?? this.username,
      location: location ?? this.location,
      phone: phone ?? this.phone,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      accountType: accountType ?? this.accountType,
      token: token ?? this.token,
    );
  }
}
