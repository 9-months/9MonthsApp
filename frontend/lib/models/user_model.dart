// models/user_model.dart
class User {
  final String id;
  final String username;
  final String email;
  final String phone;
  final String location;
  String dateOfBirth; // Made mutable for updates

  User({
    required this.id,
    required this.username,
    required this.email,
    required this.phone,
    required this.location,
    this.dateOfBirth = '',
  });

  // Create a copy of User with updated fields
  User copyWith({
    String? id,
    String? username,
    String? email,
    String? phone,
    String? location,
    String? dateOfBirth,
  }) {
    return User(
      id: id ?? this.id,
      username: username ?? this.username,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      location: location ?? this.location,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'phone': phone,
      'location': location,
      'dateOfBirth': dateOfBirth,
    };
  }

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      username: json['username'],
      email: json['email'],
      phone: json['phone'],
      location: json['location'],
      dateOfBirth: json['dateOfBirth'] ?? '',
    );
  }
}

// screens/settings/user_settings_page.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

class UserSettingsPage extends StatelessWidget {
  const UserSettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.watch<UserProvider>().currentUser;
    
    if (user == null) {
      return const Center(child: Text('No user logged in'));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          Card(
            elevation: 4,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Personal Information',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),
                  ListTile(
                    leading: const Icon(Icons.calendar_today),
                    title: const Text('Date of Birth'),
                    subtitle: Text(
                      user.dateOfBirth.isEmpty 
                          ? 'Not set' 
                          : user.dateOfBirth
                    ),
                    trailing: const Icon(Icons.edit),
                    onTap: () => _showDatePicker(context, user),
                  ),
                  // Add more settings options here
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showDatePicker(BuildContext context, User user) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().subtract(const Duration(days: 365 * 18)), // Default to 18 years ago
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Colors.deepPurple, // Header background color
              onPrimary: Colors.white, // Header text color
              onSurface: Colors.black, // Calendar text color
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      final formattedDate = DateFormat('MM/dd/yyyy').format(picked);
      
      // Update user with new date of birth
      final updatedUser = user.copyWith(dateOfBirth: formattedDate);
      
      if (context.mounted) {
        // Update user in provider
        context.read<UserProvider>().setUser(updatedUser);
        
        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Date of birth updated successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    }
  }
}

// Update your main.dart to add the settings route
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // ... other properties ...
      routes: {
        '/login': (context) => const LoginPage(),
        '/register': (context) => const RegisterPage(),
        '/home': (context) => const HomePage(),
        '/profile': (context) => const ProfilePage(),
        '/settings': (context) => const UserSettingsPage(), // Add this route
      },
    );
  }
}