/*
 File: user-model.dart
 Purpose: Contains the user model class.
 Created Date: 11/02/2021 CCS-55 State Management
 Author: Dinith Perera

 last modified: 11/02/2021 | Dinith | CCS-55 model for user created
*/
// lib/models/user_model.dart

class User {
  final String uid;
  final String email;
  final String username;
  final String? location;
  final String? phone;

  User({
    required this.uid,
    required this.email,
    required this.username,
    this.location,
    this.phone,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      uid: json['uid'],
      email: json['email'],
      username: json['username'],
      location: json['location'],
      phone: json['phone'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'email': email,
      'username': username,
      'location': location,
      'phone': phone,
    };
  }
}
