/*
 File: home_page.dart
 Purpose: 
 Created Date: CCS-29 
 Author: 

 last modified: 2025-02-09 | Dinith | CCS-9 Emergency button 
*/

import 'package:flutter/material.dart';
import '../../services/emergency_service.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

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
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              _buildEmergencyButton(context),
              const SizedBox(height: 20),
              _buildDashboardGrid(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmergencyButton(BuildContext context) {
    return Card(
      elevation: 4,
      color: Colors.red,
      child: InkWell(
        onTap: () => _handleEmergency(context),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 20.0),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.call,
                size: 48,
                color: Colors.white,
              ),
              SizedBox(width: 16),
              Text(
                'EMERGENCY',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDashboardGrid() {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
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
          // Navigation logic here
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

  Future<void> _handleEmergency(BuildContext context) async {
    try {
      await EmergencyService().sendEmergencyAlert();
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Emergency services have been notified'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to contact emergency services'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}