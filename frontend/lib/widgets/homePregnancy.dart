import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/pregnancy_provider.dart';
import '../providers/auth_provider.dart';
import '../screens/pregnancyTracker/pregnancy_tracker_page.dart';

class HomePregnancyWidget extends StatelessWidget {
  const HomePregnancyWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final pregnancyProvider = Provider.of<PregnancyProvider>(context);

    return FutureBuilder(
      future: pregnancyProvider.fetchPregnancyData(authProvider.username),
      builder: (context, AsyncSnapshot<Map<String, dynamic>?> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Card(
            margin: const EdgeInsets.all(16),
            color: Colors.red[50],
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.error_outline, color: Colors.red, size: 48),
                  const SizedBox(height: 16),
                  Text('Error loading pregnancy data: ${snapshot.error}'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      // Force rebuild the widget
                      (context as Element).markNeedsBuild();
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
          );
        }

        if (!snapshot.hasData) {
          return Card(
            margin: const EdgeInsets.all(16),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.pregnant_woman,
                      size: 48, color: Colors.blue),
                  const SizedBox(height: 16),
                  Text(
                    'Track Your Pregnancy Journey',
                    style: Theme.of(context).textTheme.titleLarge,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Start tracking your pregnancy to get weekly updates, tips, and more!',
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.add),
                    label: const Text('Start Tracking'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 12),
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const PregnancyTrackerPage(),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          );
        }

        // When pregnancy data exists
        return Card(
          margin: const EdgeInsets.all(16.0),
          child: InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const PregnancyTrackerPage(),
                ),
              );
            },
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Pregnancy Progress',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const Icon(Icons.chevron_right),
                    ],
                  ),
                  const SizedBox(height: 16),
                  LinearProgressIndicator(
                    value: (snapshot.data!['currentWeek'] as num) / 40,
                    backgroundColor: Colors.grey[200],
                    valueColor:
                        const AlwaysStoppedAnimation<Color>(Colors.blue),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildInfoColumn(
                        context,
                        'Week',
                        '${snapshot.data!['currentWeek']}/40',
                        Icons.calendar_today,
                      ),
                      _buildInfoColumn(
                        context,
                        'Baby Size',
                        snapshot.data!['baby_size'] ??
                            'Not available', // Add null check with fallback
                        Icons.child_care,
                      ),
                      _buildInfoColumn(
                        context,
                        'Days Left',
                        _calculateDaysRemaining(
                                DateTime.parse(snapshot.data!['dueDate']))
                            .toString(),
                        Icons.event,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildInfoColumn(
    BuildContext context,
    String label,
    String value,
    IconData icon,
  ) {
    return Column(
      children: [
        Icon(icon, color: Colors.blue),
        const SizedBox(height: 8),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall,
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: Theme.of(context).textTheme.titleMedium,
        ),
      ],
    );
  }

  int _calculateDaysRemaining(DateTime dueDate) {
    final now = DateTime.now();
    return dueDate.difference(now).inDays;
  }
}
