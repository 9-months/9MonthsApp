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
  final String? birthday;

  User({
    required this.uid,
    required this.email,
    required this.username,
    required this.accountType,
    this.location,
    this.phone,
    this.birthday,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      uid: json['uid'] ?? json['_id'] ?? '',
      email: json['email'] ?? '',
      username: json['username'] ?? '',
      location: json['location'] as String?,
      phone: json['phone'] as String?,
      accountType : json['accountType'] ?? 'mother',
      birthday: json['birthday'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'email': email,
      'username': username,
      'location': location,
      'phone': phone,
      'birthday': birthday,
      'accountType': accountType,
    };
  }

  User copyWith({
    String? uid,
    String? email,
    String? username,
    String? location,
    String? phone,
    String? birthday,
    String? accountType,
  }) {
    return User(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      username: username ?? this.username,
      location: location ?? this.location,
      phone: phone ?? this.phone,
      birthday: birthday ?? this.birthday,
      accountType: accountType ?? this.accountType,
    );
  }
}
