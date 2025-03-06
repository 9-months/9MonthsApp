import 'package:flutter/material.dart';

class PregnancyInfo extends StatelessWidget {
  final Map<String, dynamic> pregnancyData;

  const PregnancyInfo({super.key, required this.pregnancyData});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Card(
          child: ListTile(
            title: const Text('Current Week'),
            subtitle: Text('Week ${pregnancyData['currentWeek']}'),
            leading: const Icon(Icons.calendar_today),
          ),
        ),
        Card(
          child: ListTile(
            title: const Text('Baby Size'),
            subtitle: Text(pregnancyData['babySize']),
            leading: const Icon(Icons.child_care),
          ),
        ),
        Card(
          child: ListTile(
            title: const Text('Due Date'),
            subtitle: Text(DateTime.parse(pregnancyData['dueDate'])
                .toString()
                .split(' ')[0]),
            leading: const Icon(Icons.event),
          ),
        ),
        if (pregnancyData['babyDevelopment'] != null)
          Card(
            child: ListTile(
              title: const Text('Baby Development'),
              subtitle: Text(pregnancyData['babyDevelopment']),
              leading: const Icon(Icons.child_friendly),
            ),
          ),
        if (pregnancyData['motherChanges'] != null)
          Card(
            child: ListTile(
              title: const Text('What to Expect'),
              subtitle: Text(pregnancyData['motherChanges']),
              leading: const Icon(Icons.pregnant_woman),
            ),
          ),
        if (pregnancyData['tips'] != null)
          Card(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const ListTile(
                  title: Text('Weekly Tips'),
                  leading: Icon(Icons.lightbulb),
                ),
                ...List<String>.from(pregnancyData['tips'])
                    .map((tip) => Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                          child: Row(
                            children: [
                              const Icon(Icons.check, size: 20),
                              const SizedBox(width: 8),
                              Expanded(child: Text(tip)),
                            ],
                          ),
                        ))
                    .toList(),
              ],
            ),
          ),
      ],
    );
  }
}
