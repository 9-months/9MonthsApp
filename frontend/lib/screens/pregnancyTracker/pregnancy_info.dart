import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/pregnancy_provider.dart';
import 'pregnancy_tracker_page.dart';

class PregnancyInfo extends StatelessWidget {
  final Map<String, dynamic> pregnancyData;

  const PregnancyInfo({super.key, required this.pregnancyData});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final pregnancyProvider = Provider.of<PregnancyProvider>(context, listen: false);
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
                  _showEditDueDateDialog(context, authProvider, pregnancyProvider);
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
                  _showDeleteConfirmation(context, authProvider, pregnancyProvider);
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  // Method to show edit due date dialog
  void _showEditDueDateDialog(BuildContext context, AuthProvider authProvider, PregnancyProvider pregnancyProvider) {
    DateTime selectedDate = DateTime.now().add(const Duration(days: 280));
    
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Edit Due Date'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Current due date: ${DateFormat('MMM dd, yyyy').format(
                DateTime.parse(pregnancyData['dueDate'].toString())
              )}'),
              const SizedBox(height: 16),
              Text('New due date: ${DateFormat('MMM dd, yyyy').format(selectedDate)}'),
              const SizedBox(height: 16),
              ElevatedButton(
                child: const Text('Select New Date'),
                onPressed: () async {
                  final DateTime? picked = await showDatePicker(
                    context: context,
                    initialDate: selectedDate,
                    firstDate: DateTime.now(),
                    lastDate: DateTime.now().add(const Duration(days: 280)),
                  );
                  if (picked != null) {
                    setState(() {
                      selectedDate = picked;
                    });
                  }
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                try {
                  await pregnancyProvider.updatePregnancy(
                    authProvider.username,
                    selectedDate,
                  );
                  
                  // Close the dialog and refresh the page
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Due date updated successfully')),
                  );
                  
                  // Force rebuild the page
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const PregnancyTrackerPage(),
                    ),
                  );
                } catch (e) {
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error updating due date: $e')),
                  );
                }
              },
              child: const Text('Update'),
            ),
          ],
        ),
      ),
    );
  }

  // Method to show delete confirmation
  void _showDeleteConfirmation(BuildContext context, AuthProvider authProvider, PregnancyProvider pregnancyProvider) {

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Pregnancy Tracker'),
        content: const Text('Are you sure you want to delete your pregnancy tracker? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            onPressed: () async {
              try {
                await pregnancyProvider.deletePregnancy(authProvider.username);
                
                // Close the dialog
                Navigator.of(context).pop();
                
                // Show success message
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Pregnancy tracker deleted successfully')),
                );
                
                // Navigate back to the home page
                Navigator.pushReplacementNamed(context, '/home');
              } catch (e) {
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Error deleting pregnancy tracker: $e')),
                );
              }
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}