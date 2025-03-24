/*
 File: home_page.dart
 Purpose: Pregnancy tracker home page
 Created Date: CCS-29
 Author: Irosh Perera

 last modified: 2025-02-15 | Chamod | CCS-8 Pregnancy Tracker
*/

import 'package:_9months/widgets/homeTIps.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/pregnancy_provider.dart';
import '../../widgets/homePregnancy.dart';
import '../../widgets/navbar.dart';
import '../../services/emergency_service.dart';

import '../calendar/calendar_screen.dart';
import '../../providers/auth_provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;
  late String userId;

  @override
  void initState() {
    super.initState();
    // Get activeUserId from the auth provider
    userId = Provider.of<AuthProvider>(context, listen: false).getActiveUserId();
  }

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
                                .fetchPregnancyData(authProvider.getActiveUserId()),
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
                      Row(
                        children: [
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => CalendarScreen(
                                    userId: authProvider.user!.uid,
                                  ),
                                ),
                              );
                            },
                            child: const Icon(Icons.calendar_today, size: 28),
                          ),
                          const SizedBox(width: 16),
                          GestureDetector(
                            onTap: () =>
                                Navigator.pushNamed(context, '/profile'),
                            child: const CircleAvatar(
                              radius: 24,
                              backgroundImage: AssetImage(
                                  'assets/images/profile_picture.png'),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Pregnancy Info
                  HomePregnancyWidget(),

                  //Tips Widget
                  HomeTipsWidget(),
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
}
