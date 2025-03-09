/*
 File: home_page.dart
 Purpose: Pregnancy tracker home page
 Created Date: CCS-29
 Author: Irosh Perera

 last modified: 2025-02-15 | Chamod | CCS-8 Pregnancy Tracker
*/

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/pregnancy_provider.dart';
import '../../widgets/homePregnancy.dart';
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
          const SnackBar(content: Text('Emergency services notified')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to contact emergency services')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final pregnancyProvider = Provider.of<PregnancyProvider>(context);

    return Scaffold(
      body: SafeArea(
        child: Consumer<AuthProvider>(
          builder: (context, authProvider, _) => SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Hello ${authProvider.user?.username ?? "User"}',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: 4),
                          FutureBuilder(
                            future: pregnancyProvider
                                .fetchPregnancyData(authProvider.username),
                            builder: (context, snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return const Text('Loading...');
                              } else if (snapshot.hasError) {
                                return const Text(
                                    'Unable to load pregnancy data');
                              } else if (!snapshot.hasData) {
                                return const Text(
                                    'No pregnancy data available');
                              }

                              final pregnancyData = snapshot.data!;
                              // Use the currentWeek from the data if available, otherwise calculate it
                              int currentWeek;
                              if (pregnancyData.containsKey('currentWeek') &&
                                  pregnancyData['currentWeek'] != null) {
                                currentWeek = pregnancyData['currentWeek'];
                              } else {
                                final dueDate =
                                    DateTime.parse(pregnancyData['dueDate']);
                                currentWeek = pregnancyProvider
                                    .calculateCurrentWeek(dueDate);
                              }

                              return Text(
                                'Week $currentWeek of Pregnancy',
                                style: Theme.of(context)
                                    .textTheme
                                    .headlineSmall
                                    ?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                              );
                            },
                          ),
                        ],
                      ),
                      GestureDetector(
                        onTap: () => Navigator.pushNamed(context, '/profile'),
                        child: const CircleAvatar(
                          radius: 24,
                          backgroundImage:
                              AssetImage('assets/images/profile_picture.png'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Pregnancy Info
                  HomePregnancyWidget(),

                  // Menu Grid
                  GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 2,
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16,
                    children: [
                      _buildMenuCard(Icons.medication, 'Medicines',
                          Theme.of(context).colorScheme.secondary),
                      _buildMenuCard(
                          Icons.fitness_center, 'Exercises', Colors.green),
                      _buildMenuCard(
                          Icons.local_hospital, 'Hospitals', Colors.red),
                      _buildMenuCard(Icons.article, 'Articles', Colors.purple),
                      _buildMenuCard(
                          Icons.video_library, 'Videos', Colors.blue),
                      _buildMenuCard(
                          Icons.restaurant_menu, 'Food', Colors.teal),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      bottomNavigationBar: CustomNavBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        onEmergencyPress: _handleEmergency,
      ),
    );
  }

  Widget _buildInfoColumn(String label, String value) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Colors.grey,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ],
    );
  }

  Widget _buildMenuCard(IconData icon, String title, Color color) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: () {},
        borderRadius: BorderRadius.circular(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 32,
              color: color,
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
