/*
 File: reminder_screen.dart
 Purpose: UI for managing reminders
 Created Date: 02-03-2025
 Author: Chamod Kamiss
*/

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../services/reminder_service.dart';
import '../../models/reminder_model.dart';
import 'add_reminder_screen.dart';

class ReminderScreen extends StatefulWidget {
  final String userId;

  const ReminderScreen({super.key, required this.userId});

  @override
  State<ReminderScreen> createState() => _ReminderScreenState();
}

class _ReminderScreenState extends State<ReminderScreen> {
  final ReminderService _reminderService = ReminderService();
  List<Reminder> _reminders = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadReminders();
  }

  Future<void> _loadReminders() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final reminders = await _reminderService.getRemindersByUser(widget.userId);
      setState(() {
        _reminders = reminders;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load reminders: ${e.toString()}')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _deleteReminder(String reminderId) async {
    try {
      await _reminderService.deleteReminder(widget.userId, reminderId);
      _loadReminders();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Reminder deleted successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to delete reminder: ${e.toString()}')),
        );
      }
    }
  }

  String _getTypeIcon(String type) {
    switch (type) {
      case 'medicine':
        return '💊';
      case 'appointment':
        return '🏥';
      default:
        return '📝';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reminders'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadReminders,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _reminders.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.notifications_off, size: 64, color: Colors.grey),
                      const SizedBox(height: 16),
                      Text(
                        'No reminders yet',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Tap the + button to add a new reminder',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  itemCount: _reminders.length,
                  itemBuilder: (context, index) {
                    final reminder = _reminders[index];
                    final dateTime = DateTime.parse(reminder.dateTime);
                    
                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: _getTypeColor(reminder.type),
                          child: Text(_getTypeIcon(reminder.type)),
                        ),
                        title: Text(
                          reminder.title,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (reminder.description != null && reminder.description!.isNotEmpty)
                              Text(reminder.description!),
                            Text(
                              DateFormat('MMM d, yyyy - h:mm a').format(dateTime),
                              style: const TextStyle(color: Colors.grey),
                            ),
                          ],
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit, color: Colors.blue),
                              onPressed: () {
                                // TODO: Navigate to edit reminder screen
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () => _showDeleteConfirmation(reminder.id),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AddReminderScreen(userId: widget.userId),
            ),
          );
          
          if (result == true) {
            _loadReminders();
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Color _getTypeColor(String type) {
    switch (type) {
      case 'medicine':
        return Colors.blue;
      case 'appointment':
        return Colors.green;
      default:
        return Colors.orange;
    }
  }

  Future<void> _showDeleteConfirmation(String reminderId) async {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Reminder'),
          content: const Text('Are you sure you want to delete this reminder?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _deleteReminder(reminderId);
              },
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }
}