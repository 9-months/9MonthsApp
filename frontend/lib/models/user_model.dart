/*
 File: user-model.dart
 Purpose: 
 Created Date: 
 Author:

 last modified: 
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
