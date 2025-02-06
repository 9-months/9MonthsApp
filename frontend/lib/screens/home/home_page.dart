import 'package:flutter/material.dart';

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
            onPressed: () {
              // Add logout logic here
              Navigator.pushReplacementNamed(context, '/login');
            },
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
