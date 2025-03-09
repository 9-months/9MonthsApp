import 'package:flutter/material.dart';

class HomeTipsWidget extends StatefulWidget {
  const HomeTipsWidget({Key? key}) : super(key: key);

  @override
  State<HomeTipsWidget> createState() => _HomeTipsWidgetState();
}

class _HomeTipsWidgetState extends State<HomeTipsWidget> {
  // Sample appointment data - you'll replace this with actual data later
  final List<Appointment> _appointments = [
    Appointment(
      id: '1',
      title: 'First Trimester Checkup',
      date: DateTime.now().add(const Duration(days: 3)),
      description: 'Regular checkup with Dr. Johnson',
      isCompleted: false,
    ),
    Appointment(
      id: '2',
      title: 'Ultrasound',
      date: DateTime.now().add(const Duration(days: 10)),
      description: 'First ultrasound scan',
      isCompleted: false,
    ),
  ];

  // Sample pregnancy tips
  final List<String> _pregnancyTips = [
    'Stay hydrated by drinking at least 8-10 glasses of water daily',
    'Take your prenatal vitamins regularly as prescribed',
    'Eat small, frequent meals to manage morning sickness',
    'Engage in light exercise like walking or prenatal yoga',
    'Avoid caffeine and alcohol during pregnancy'
  ];

  String _getRandomTip() {
    // Return a random tip
    _pregnancyTips.shuffle();
    return _pregnancyTips.first;
  }

  void _toggleAppointmentCompletion(String id) {
    setState(() {
      final index =
          _appointments.indexWhere((appointment) => appointment.id == id);
      if (index != -1) {
        _appointments[index] = _appointments[index].copyWith(
          isCompleted: !_appointments[index].isCompleted,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Daily Tip Card
        Card(
          elevation: 4,
          margin: const EdgeInsets.all(8.0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.lightbulb, color: Colors.amber[700]),
                    const SizedBox(width: 8),
                    const Text(
                      'Today\'s Tip',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  _getRandomTip(),
                  style: const TextStyle(fontSize: 16),
                ),
              ],
            ),
          ),
        ),

        // Upcoming Appointments Section
        const Padding(
          padding: EdgeInsets.all(8.0),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Upcoming Appointments',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),

        // List of appointment cards
        ..._appointments.map((appointment) => AppointmentCard(
              appointment: appointment,
              onToggleCompletion: _toggleAppointmentCompletion,
            )),
      ],
    );
  }
}

// Model for Appointment data
class Appointment {
  final String id;
  final String title;
  final DateTime date;
  final String description;
  final bool isCompleted;

  Appointment({
    required this.id,
    required this.title,
    required this.date,
    required this.description,
    required this.isCompleted,
  });

  Appointment copyWith({
    String? id,
    String? title,
    DateTime? date,
    String? description,
    bool? isCompleted,
  }) {
    return Appointment(
      id: id ?? this.id,
      title: title ?? this.title,
      date: date ?? this.date,
      description: description ?? this.description,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }
}

// Widget for displaying individual appointments
class AppointmentCard extends StatelessWidget {
  final Appointment appointment;
  final Function(String) onToggleCompletion;

  const AppointmentCard({
    Key? key,
    required this.appointment,
    required this.onToggleCompletion,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: appointment.isCompleted
              ? Colors.green.shade300
              : Colors.grey.shade300,
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          children: [
            Checkbox(
              value: appointment.isCompleted,
              activeColor: Colors.green,
              onChanged: (bool? value) {
                onToggleCompletion(appointment.id);
              },
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    appointment.title,
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      decoration: appointment.isCompleted
                          ? TextDecoration.lineThrough
                          : null,
                      color:
                          appointment.isCompleted ? Colors.grey : Colors.black,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    appointment.description,
                    style: TextStyle(
                      color: appointment.isCompleted
                          ? Colors.grey
                          : Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Date: ${appointment.date.day}/${appointment.date.month}/${appointment.date.year}',
                    style: TextStyle(
                      color: appointment.isCompleted
                          ? Colors.grey
                          : Colors.blue.shade700,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
