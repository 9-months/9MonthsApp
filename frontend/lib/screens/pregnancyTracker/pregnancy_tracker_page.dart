import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/pregnancy_model.dart';
import '../../services/pregnancy_service.dart';
import '../../widgets/pregnancytracker.dart'; 

class PregnancyTrackerPage extends StatefulWidget {
  const PregnancyTrackerPage({Key? key}) : super(key: key);

  @override
  _PregnancyTrackerPageState createState() => _PregnancyTrackerPageState();
}

class _PregnancyTrackerPageState extends State<PregnancyTrackerPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late Future<Pregnancy> _pregnancyFuture;
  final _pregnancyService = PregnancyService();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _pregnancyFuture = _pregnancyService.getPregnancy('USER_ID');
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
 Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pregnancy Tracker'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Overview'),
            Tab(text: 'Timeline'),
            Tab(text: 'Milestones'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildOverviewTab(),
          _buildTimelineTab(),
          _buildMilestonesTab(),
        ],
      ),
    );
  }

  Widget _buildOverviewTab() {
    return FutureBuilder<Pregnancy>(
      future: _pregnancyFuture,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Pregnancytracker(
                  currentWeek: snapshot.data!.currentWeek,
                  babySize: snapshot.data!.babySize,
                  babyHeight: 17.0,
                  babyWeight: 110.0,
                  dueDate: snapshot.data!.dueDate,
                  weeklyTips: snapshot.data!.weeklyTips,
                ),
                const SizedBox(height: 24),
                _buildUpcomingAppointments(),
                const SizedBox(height: 24),
                _buildWeightTracker(),
              ],
            ),
          );
        }
        if (snapshot.hasError) {
          return Center(
            child: Text('Error: ${snapshot.error}'),
          );
        }
        return const Center(child: CircularProgressIndicator());
      },
    );
  }

  Widget _buildTimelineTab() {
    return FutureBuilder<Pregnancy>(
      future: _pregnancyFuture,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: snapshot.data!.currentWeek,
          itemBuilder: (context, index) {
            final weekNumber = index + 1;
            return Card(
              margin: const EdgeInsets.only(bottom: 16),
              child: ExpansionTile(
                title: Text('Week $weekNumber'),
                subtitle: Text(_getWeekDescription(weekNumber)),
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Baby Development',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 8),
                        Text(_getBabyDevelopment(weekNumber)),
                        const SizedBox(height: 16),
                        Text(
                          'Mom\'s Changes',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 8),
                        Text(_getMomChanges(weekNumber)),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildMilestonesTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildMilestoneCard(
          'First Trimester',
          [
            'First Ultrasound',
            'Heartbeat Detection',
            'End of Morning Sickness',
          ],
          [true, true, false],
        ),
        const SizedBox(height: 16),
        _buildMilestoneCard(
          'Second Trimester',
          [
            'Gender Reveal',
            'First Kick',
            'Anatomy Scan',
          ],
          [false, false, false],
        ),
        const SizedBox(height: 16),
        _buildMilestoneCard(
          'Third Trimester',
          [
            'Baby Shower',
            'Hospital Tour',
            'Birth Plan Ready',
          ],
          [false, false, false],
        ),
      ],
    );
  }

  Widget _buildUpcomingAppointments() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Upcoming Appointments',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            _buildAppointmentItem(
              DateTime.now().add(const Duration(days: 7)),
              'Regular Checkup',
              'Dr. Sarah Johnson',
            ),
            const SizedBox(height: 8),
            _buildAppointmentItem(
              DateTime.now().add(const Duration(days: 14)),
              'Ultrasound Scan',
              'City Hospital',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppointmentItem(DateTime date, String title, String doctor) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            children: [
              Text(
                DateFormat('dd').format(date),
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(
                DateFormat('MMM').format(date),
                style: TextStyle(
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(
                doctor,
                style: TextStyle(color: Colors.grey[600]),
              ),
            ],
          ),
        ),
        IconButton(
          icon: const Icon(Icons.edit),
          onPressed: () {
            // TODO: Implement appointment editing
          },
        ),
      ],
    );
  }

  Widget _buildWeightTracker() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Weight Tracker',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildWeightItem('Starting', '65 kg'),
                _buildWeightItem('Current', '68 kg'),
                _buildWeightItem('Gained', '+3 kg'),
              ],
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () {
                // TODO: Implement weight update
              },
              icon: const Icon(Icons.add),
              label: const Text('Add Weight'),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 48),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWeightItem(String label, String value) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(color: Colors.grey[600]),
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

  Widget _buildMilestoneCard(String title, List<String> milestones, List<bool> completed) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            ...List.generate(
              milestones.length,
              (index) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    Icon(
                      completed[index]
                          ? Icons.check_circle
                          : Icons.radio_button_unchecked,
                      color: completed[index]
                          ? Theme.of(context).colorScheme.primary
                          : Colors.grey,
                    ),
                    const SizedBox(width: 8),
                    Text(milestones[index]),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getWeekDescription(int week) {
    // TODO: Implement actual week descriptions
    return 'Key developments and changes during week $week';
  }

  String _getBabyDevelopment(int week) {
    // TODO: Implement actual baby development information
    return 'Baby development information for week $week';
  }

  String _getMomChanges(int week) {
    // TODO: Implement actual mom changes information
    return 'Common changes and symptoms for mom during week $week';
  }
}