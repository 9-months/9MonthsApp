import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';

class RoleSelectionPage extends StatefulWidget {
  const RoleSelectionPage({super.key});

  @override
  State<RoleSelectionPage> createState() => _RoleSelectionPageState();
}

class _RoleSelectionPageState extends State<RoleSelectionPage> {
  String _selectedRole = 'mother';
  
  Future<void> _continueWithRole() async {
    // Update user role
    final authProvider = context.read<AuthProvider>();
    
    // If user was just created, the role is already set
    // If user already exists, call API to update role
    
    // Navigate to appropriate screen
    if (_selectedRole == 'partner') {
      // Show partner code input or QR scan
      Navigator.pushReplacementNamed(context, '/partner-linking');
    } else {
      // Go directly to home
      Navigator.pushReplacementNamed(context, '/home');
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Tell us about yourself',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),
              
              const Text(
                'I am a:',
                style: TextStyle(fontSize: 18),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              
              // Mother option
              GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedRole = 'mother';
                  });
                },
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: _selectedRole == 'mother' 
                          ? Theme.of(context).primaryColor 
                          : Colors.grey,
                      width: 2,
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.pregnant_woman,
                        color: _selectedRole == 'mother' 
                            ? Theme.of(context).primaryColor 
                            : Colors.grey,
                        size: 32,
                      ),
                      const SizedBox(width: 16),
                      const Expanded(
                        child: Text(
                          'Mother',
                          style: TextStyle(fontSize: 18),
                        ),
                      ),
                      if (_selectedRole == 'mother')
                        Icon(
                          Icons.check_circle,
                          color: Theme.of(context).primaryColor,
                        ),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Partner option
              GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedRole = 'partner';
                  });
                },
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: _selectedRole == 'partner' 
                          ? Theme.of(context).primaryColor 
                          : Colors.grey,
                      width: 2,
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.family_restroom,
                        color: _selectedRole == 'partner' 
                            ? Theme.of(context).primaryColor 
                            : Colors.grey,
                        size: 32,
                      ),
                      const SizedBox(width: 16),
                      const Expanded(
                        child: Text(
                          'Partner',
                          style: TextStyle(fontSize: 18),
                        ),
                      ),
                      if (_selectedRole == 'partner')
                        Icon(
                          Icons.check_circle,
                          color: Theme.of(context).primaryColor,
                        ),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 40),
              
              ElevatedButton(
                onPressed: _continueWithRole,
                child: const Text('Continue'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}