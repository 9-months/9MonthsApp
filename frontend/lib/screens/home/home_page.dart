/*
 File: home_page.dart
 Purpose: 
 Created Date: CCS-29 
 Author: 

 last modified: 2025-02-09 | Melissa | CCS-43 Profile navigation
*/

import 'package:flutter/material.dart';
import '../../widgets/navbar.dart';
import '../../services/emergency_service.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;

  Future<void> _handleEmergency() async {
    try {
      await EmergencyService().sendEmergencyAlert();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Emergency services have been notified'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to contact emergency services'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _onNavTap(int index) {
    setState(() => _currentIndex = index);
    // Add navigation logic here when implementing other pages
    switch (index) {
      case 0: // Home
        break;
      case 1: // Journal
        // Navigator.pushNamed(context, '/journal');
        break;
      case 3: // Stats
        // Navigator.pushNamed(context, '/stats');
        break;
      case 4: // Settings
        // Navigator.pushNamed(context, '/settings');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => Navigator.pushReplacementNamed(context, '/login'),
          ),
        ],
      ),
      body: GridView.count(
        padding: const EdgeInsets.all(16),
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        children: [
          _buildDashboardCard(
            icon: Icons.calendar_today,
            title: 'Appointments',
            color: Colors.blue,
          ),
          _buildDashboardCard(
            icon: Icons.medical_information,
            title: 'Medical Records',
            color: Colors.green,
          ),
          _buildDashboardCard(
            icon: Icons.notifications,
            title: 'Reminders',
            color: Colors.orange,
          ),
          _buildDashboardCard(
            icon: Icons.person,
            title: 'Profile',
            color: Colors.purple,
          ),
        ],
      ),
      bottomNavigationBar: CustomNavBar(
        currentIndex: _currentIndex,
        onTap: _onNavTap,
        onEmergencyPress: _handleEmergency,
      ),
    );
  }

  Widget _buildDashboardCard({
    required IconData icon,
    required String title,
    required Color color,
  }) {
    return Card(
      elevation: 4,
      child: InkWell(
        onTap: () {
          // Add navigation logic here
        },
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 48,
              color: color,
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
