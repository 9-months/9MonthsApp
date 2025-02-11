/*
 File: user-model.dart
 Purpose: Contains the user model class.
 Created Date: 11/02/2021 CCS-55 State Management
 Author: Dinith Perera

 last modified: 11/02/2021 | Dinith | CCS-55 model for user created
*/

class User {
  final String id;
  final String username;
  final String email;

  User({required this.id, required this.username, required this.email});
}
