import 'package:flutter/material.dart';
import '../../services/emergency_service.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

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
              _buildDashboardGrid(context),
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

  Widget _buildDashboardGrid(BuildContext context) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      children: [
        _buildDashboardCard(
          context: context,
          icon: Icons.calendar_today,
          title: 'Appointments',
          color: Colors.blue,
        ),
        _buildDashboardCard(
          context: context,
          icon: Icons.medical_information,
          title: 'Medical Records',
          color: Colors.green,
        ),
        _buildDashboardCard(
          context: context,
          icon: Icons.notifications,
          title: 'Reminders',
          color: Colors.orange,
        ),
        _buildDashboardCard(
          context: context,
          icon: Icons.person,
          title: 'Profile',
          color: Colors.purple,
        ),
      ],
    );
  }

  Widget _buildDashboardCard({
    required BuildContext context,
    required IconData icon,
    required String title,
    required Color color,
  }) {
    return Card(
      elevation: 4,
      child: InkWell(
        onTap: () {
          switch (title) {
            case 'Profile':
              Navigator.pushNamed(context, '/profile');
              break;
            case 'Appointments':
              Navigator.pushNamed(context, '/appointments');
              break;
            case 'Medical Records':
              Navigator.pushNamed(context, '/medical-records');
              break;
            case 'Reminders':
              Navigator.pushNamed(context, '/reminders');
              break;
          }
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