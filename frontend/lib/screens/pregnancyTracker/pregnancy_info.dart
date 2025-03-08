import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class PregnancyInfo extends StatelessWidget {
  final Map<String, dynamic> pregnancyData;

  const PregnancyInfo({super.key, required this.pregnancyData});

  @override
  Widget build(BuildContext context) {
    // Parse due date with null safety
    DateTime? dueDate;
    try {
      if (pregnancyData['dueDate'] != null) {
        dueDate = DateTime.parse(pregnancyData['dueDate'].toString());
      }
    } catch (e) {
      print('Error parsing due date: $e');
    }

    // Format due date with null safety
    String formattedDueDate = 'Not set';
    if (dueDate != null) {
      formattedDueDate = DateFormat('MMM dd, yyyy').format(dueDate);
    }

    // Calculate days remaining with null safety
    int daysRemaining = 0;
    if (dueDate != null) {
      daysRemaining = dueDate.difference(DateTime.now()).inDays;
      daysRemaining = daysRemaining < 0 ? 0 : daysRemaining;
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Progress indicator
        Container(
          margin: const EdgeInsets.only(bottom: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Progress: Week ${pregnancyData['currentWeek']?.toString() ?? '?'} of 40',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              LinearProgressIndicator(
                value: ((pregnancyData['currentWeek'] as num?) ?? 0) / 40,
                backgroundColor: Colors.grey[200],
                valueColor: const AlwaysStoppedAnimation<Color>(Colors.blue),
                minHeight: 10,
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('First Trimester'),
                  Text('Second Trimester'),
                  Text('Third Trimester'),
                ],
              ),
            ],
          ),
        ),

        // Current week card
        Card(
          child: ListTile(
            title: const Text('Current Week'),
            subtitle: Text('Week ${pregnancyData['currentWeek']?.toString() ?? 'Unknown'}'),
            leading: const Icon(Icons.calendar_today, color: Colors.blue),
          ),
        ),

        // Baby size card
        Card(
          child: ListTile(
            title: const Text('Baby Size'),
            subtitle: Text(pregnancyData['baby_size']?.toString() ?? 'Not available'),
            leading: const Icon(Icons.child_care, color: Colors.blue),
          ),
        ),

        // Due date card
        Card(
          child: ListTile(
            title: const Text('Due Date'),
            subtitle: Text(formattedDueDate),
            leading: const Icon(Icons.event, color: Colors.blue),
          ),
        ),

        // Days remaining card
        Card(
          child: ListTile(
            title: const Text('Days Remaining'),
            subtitle: Text(daysRemaining.toString()),
            leading: const Icon(Icons.hourglass_empty, color: Colors.blue),
          ),
        ),

        // Baby development card
        if (pregnancyData['baby_development'] != null)
          Card(
            margin: const EdgeInsets.only(top: 16),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.child_friendly, color: Colors.blue),
                      const SizedBox(width: 8),
                      Text('Baby Development',
                          style: Theme.of(context).textTheme.titleMedium),
                    ],
                  ),
                  const Divider(),
                  Text(pregnancyData['baby_development'].toString()),
                ],
              ),
            ),
          ),

        // Mother changes card
        if (pregnancyData['mother_changes'] != null)
          Card(
            margin: const EdgeInsets.only(top: 16),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.pregnant_woman, color: Colors.pink),
                      const SizedBox(width: 8),
                      Text('What to Expect',
                          style: Theme.of(context).textTheme.titleMedium),
                    ],
                  ),
                  const Divider(),
                  Text(pregnancyData['mother_changes'].toString()),
                ],
              ),
            ),
          ),

        // Weekly tips card
        if (pregnancyData['tips'] != null)
          Card(
            margin: const EdgeInsets.only(top: 16),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.lightbulb, color: Colors.amber),
                      const SizedBox(width: 8),
                      Text('Tips for Week ${pregnancyData['currentWeek']?.toString() ?? ""}',
                          style: Theme.of(context).textTheme.titleMedium),
                    ],
                  ),
                  const Divider(),
                  if (pregnancyData['tips'] is List && (pregnancyData['tips'] as List).isNotEmpty)
                    ...List<String>.from(pregnancyData['tips'])
                        .map((tip) => Padding(
                              padding: const EdgeInsets.symmetric(vertical: 4),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Icon(Icons.check_circle, size: 20, color: Colors.green),
                                  const SizedBox(width: 8),
                                  Expanded(child: Text(tip)),
                                ],
                              ),
                            ))
                        .toList()
                  else
                    const Text('No tips available for this week'),
                ],
              ),
            ),
          ),

        // Edit and delete buttons
        Container(
          margin: const EdgeInsets.only(top: 24),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton.icon(
                icon: const Icon(Icons.edit),
                label: const Text('Edit Due Date'),
                onPressed: () {
                  // This would be implemented to show a date picker dialog
                  _showEditDueDateDialog(context);
                },
              ),
              ElevatedButton.icon(
                icon: const Icon(Icons.delete),
                label: const Text('Delete Tracker'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                ),
                onPressed: () {
                  // This would be implemented to show a confirmation dialog
                  _showDeleteConfirmation(context);
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  // Method to show edit due date dialog
  void _showEditDueDateDialog(BuildContext context) {
    // This is a placeholder - you'd need to implement the actual functionality
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Edit Due Date'),
        content: Text('This feature is not yet implemented.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Close'),
          ),
        ],
      ),
    );
  }

  // Method to show delete confirmation
  void _showDeleteConfirmation(BuildContext context) {
    // This is a placeholder - you'd need to implement the actual functionality
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete Pregnancy Tracker'),
        content: Text('Are you sure you want to delete your pregnancy tracker? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Cancel'),
          ),
          TextButton(
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            onPressed: () {
              Navigator.of(context).pop();
              // Here you would call the delete method
            },
            child: Text('Delete'),
          ),
        ],
      ),
    );
  }
}