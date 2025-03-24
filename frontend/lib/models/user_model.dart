/*
 File: user-model.dart
 Purpose: Contains the user model class.
 Created Date: 11/02/2021 CCS-55 State Management
 Author: Dinith Perera

 last modified: 11/02/2021 | Dinith | CCS-55 model for user created
*/

class LinkedAccount {
  final String uid;
  final String username;
  final String? phone;

  LinkedAccount({
    required this.uid,
    required this.username,
    this.phone,
  });

  factory LinkedAccount.fromJson(Map<String, dynamic> json) {
    return LinkedAccount(
      uid: json['uid'] ?? '',
      username: json['username'] ?? '',
      phone: json['phone'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'username': username,
      'phone': phone,
    };
  }
}

class User {
  final String uid;
  final String email;
  final String username;
  final String accountType;
  final String? location;
  final String? phone;
  final String? birthday;
  final String? token;
  final String? linkCode;
  final LinkedAccount? linkedAccount;

  User({
    required this.uid,
    required this.email,
    required this.username,
    required this.accountType,
    this.location,
    this.phone,
    this.birthday,
    this.token,
    this.linkCode,
    this.linkedAccount,
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
      token: json['token'] as String?,
      linkCode: json['linkCode'] as String?,
      linkedAccount: json['linkedAccount'] != null 
          ? LinkedAccount.fromJson(json['linkedAccount']) 
          : null,
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
      'token': token,
      'linkCode': linkCode,
      'linkedAccount': linkedAccount?.toJson(),
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
    String? token,
    String? linkCode,
    LinkedAccount? linkedAccount,
  }) {
    return User(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      username: username ?? this.username,
      location: location ?? this.location,
      phone: phone ?? this.phone,
      birthday: birthday ?? this.birthday,
      accountType: accountType ?? this.accountType,
      token: token ?? this.token,
      linkCode: linkCode ?? this.linkCode,
      linkedAccount: linkedAccount ?? this.linkedAccount,
    );
  }
}
