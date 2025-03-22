import 'package:_9months/config/config.dart';
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';
import 'reminder_form.dart'; // Import ReminderForm
import 'edit_reminder_form.dart'; // Import EditReminderForm
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';

class CalendarScreen extends StatefulWidget {
  final String userId;

  const CalendarScreen({super.key, required this.userId});

  @override
  _CalendarScreenState createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  List<dynamic> _reminders = [];
  Map<DateTime, List<dynamic>> _remindersByDate = {};

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
    _fetchReminders();
  }

  Future<void> _fetchReminders() async {
    try {
      final userId =
          Provider.of<AuthProvider>(context, listen: false).user?.uid;

      if (userId == null) {
        _showErrorSnackBar("Failed to load reminders: User not logged in.");
        return;
      }

      final response = await http.get(
        Uri.parse('${Config.apiBaseUrl}/reminder/$userId'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        setState(() {
          _reminders = json.decode(response.body);
          _remindersByDate = _groupRemindersByDate(_reminders);
        });
      } else {
        print('Failed to fetch reminders. Status code: ${response.statusCode}');
        print('Response body: ${response.body}');
        _showErrorSnackBar(
            "Failed to load reminders: ${response.reasonPhrase}");
      }
    } catch (e) {
      print('Error fetching reminders: $e');
      _showErrorSnackBar("Failed to load reminders: Network error.");
    }
  }

  void _showErrorSnackBar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    }
  }

  DateTime? _tryParseDate(String rawDate) {
    try {
      // Attempt to parse in ISO 8601 format (most common)
      if (rawDate.contains('T')) {
        return DateTime.parse(rawDate).toLocal();
      }
      // Attempt to parse the custom format you encountered
      if (rawDate.contains('GMT')) {
        final cleanedDate = rawDate.split('GMT')[0].trim();
        final dateFormat = DateFormat("EEE MMM dd yyyy HH:mm:ss", 'en_US');
        return dateFormat.parseStrict(cleanedDate).toLocal();
      }
      // Add more parsing attempts for other potential formats if needed
      return null; // Return null if parsing fails
    } catch (e) {
      print('Error parsing date: $rawDate - $e');
      return null;
    }
  }

  Map<DateTime, List<dynamic>> _groupRemindersByDate(List<dynamic> reminders) {
    Map<DateTime, List<dynamic>> groupedReminders = {};

    for (var reminder in reminders) {
      final dateTime = reminder['dateTime'];
      if (dateTime is String) {
        final parsedDate = _tryParseDate(dateTime);
        if (parsedDate != null) {
          final dateOnly =
              DateTime(parsedDate.year, parsedDate.month, parsedDate.day);
          groupedReminders.putIfAbsent(dateOnly, () => []);
          groupedReminders[dateOnly]!.add(reminder);
        } else {
          print(
              'Warning: Could not parse date: $dateTime for reminder: ${reminder['title']}');
        }
      } else if (dateTime is DateTime) {
        final dateOnly = DateTime(dateTime.year, dateTime.month, dateTime.day);
        groupedReminders.putIfAbsent(dateOnly, () => []);
        groupedReminders[dateOnly]!.add(reminder);
      } else {
        print(
            'Warning: Invalid dateTime format in reminder: ${reminder['title']} - $dateTime');
      }
    }
    return groupedReminders;
  }

  List<dynamic> _getRemindersForDay(DateTime day) {
    return _remindersByDate[DateTime(day.year, day.month, day.day)] ?? [];
  }

  Widget _buildReminderListTile(dynamic reminder) {
    DateTime? reminderDate;
    if (reminder['dateTime'] is String) {
      reminderDate = _tryParseDate(reminder['dateTime']);
    } else if (reminder['dateTime'] is DateTime) {
      reminderDate = reminder['dateTime'].toLocal();
    }

    if (reminderDate == null) {
      return ListTile(
        title: Text(reminder['title']),
        subtitle: const Text('Invalid date format'),
      );
    }

    return ListTile(
      title: Text(reminder['title']),
      subtitle: Text(DateFormat('yyyy-MM-dd HH:mm').format(reminderDate)),
      onTap: () {
        _showReminderDetailsDialog(reminder, reminderDate!);
      },
    );
  }

  void _showReminderDetailsDialog(dynamic reminder, DateTime reminderDate) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(reminder['title']),
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Date: ${DateFormat('yyyy-MM-dd').format(reminderDate)}'),
              Text('Time: ${DateFormat('HH:mm').format(reminderDate)}'),
              if (reminder['description'] != null &&
                  reminder['description'].isNotEmpty)
                Text('Description: ${reminder['description']}'),
              if (reminder['type'] != null) Text('Type: ${reminder['type']}'),
              if (reminder['location'] != null &&
                  reminder['location'].isNotEmpty)
                Text('Location: ${reminder['location']}'),
              if (reminder['repeat'] != null)
                Text('Repeat: ${reminder['repeat']}'),
              if (reminder['alertOffsets'] != null &&
                  (reminder['alertOffsets'] as List).isNotEmpty)
                Text(
                    'Alerts: ${(reminder['alertOffsets'] as List).join(", ")} minutes before'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Close"),
            ),
          ],
        );
      },
    );
  }

  Future<void> _deleteReminder(String reminderId) async {
    try {
      final response = await http.delete(
        Uri.parse('${Config.apiBaseUrl}/reminder/${widget.userId}/$reminderId'),
      );
      if (response.statusCode == 200) {
        _fetchReminders(); // Refresh reminders
      } else {
        print('Failed to delete reminder. Status code: ${response.statusCode}');
        _showErrorSnackBar("Failed to delete reminder.");
      }
    } catch (e) {
      print('Error deleting reminder: $e');
      _showErrorSnackBar("Failed to delete reminder: Network error.");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Calendar'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _fetchReminders,
          ),
          IconButton(
            icon: const Icon(Icons.list),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) {
                  return AlertDialog(
                    title: const Text("All Reminders"),
                    content: SizedBox(
                      width: double.maxFinite,
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: _reminders.length,
                        itemBuilder: (context, index) {
                          final reminder = _reminders[index];
                          return ListTile(
                            title: Text(reminder['title']),
                            subtitle: Text(
                              _tryParseDate(reminder['dateTime']) != null
                                  ? DateFormat('yyyy-MM-dd HH:mm').format(
                                      _tryParseDate(reminder['dateTime'])!)
                                  : 'Invalid date format',
                            ),
                            onTap: () {
                              final reminderDate =
                                  _tryParseDate(reminder['dateTime']);
                              if (reminderDate != null) {
                                _showReminderDetailsDialog(
                                    reminder, reminderDate);
                              } else {
                                _showErrorSnackBar(
                                    "Invalid date format for this reminder.");
                              }
                            },
                          );
                        },
                      ),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text("Close"),
                      ),
                    ],
                  );
                },
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          TableCalendar(
            firstDay: DateTime.utc(2010, 10, 16),
            lastDay: DateTime.utc(2030, 3, 14),
            focusedDay: _focusedDay,
            calendarFormat: _calendarFormat,
            selectedDayPredicate: (day) {
              return isSameDay(_selectedDay, day);
            },
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDay = selectedDay;
                _focusedDay = focusedDay;
              });
            },
            onFormatChanged: (format) {
              setState(() {
                _calendarFormat = format;
              });
            },
            onPageChanged: (focusedDay) {
              _focusedDay = focusedDay;
            },
            eventLoader: (day) {
              return _getRemindersForDay(day);
            },
            calendarStyle: const CalendarStyle(
              markerDecoration: BoxDecoration(
                color: Colors.blue,
                shape: BoxShape.circle,
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount:
                  _getRemindersForDay(_selectedDay ?? _focusedDay).length,
              itemBuilder: (context, index) {
                final reminder =
                    _getRemindersForDay(_selectedDay ?? _focusedDay)[index];
                return Dismissible(
                  key: Key(reminder['_id'].toString()),
                  onDismissed: (direction) {
                    _deleteReminder(reminder['_id']);
                  },
                  background: Container(color: Colors.red),
                  child: Card(
                    margin: const EdgeInsets.symmetric(
                        vertical: 8.0, horizontal: 16.0),
                    child: _buildReminderListItem(reminder),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ReminderForm(
                userId: widget.userId,
                selectedDate: _selectedDay,
              ),
            ),
          ).then((value) => {_fetchReminders()});
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildReminderListItem(dynamic reminder) {
    DateTime? reminderDate;
    if (reminder['dateTime'] is String) {
      reminderDate = _tryParseDate(reminder['dateTime']);
    } else if (reminder['dateTime'] is DateTime) {
      reminderDate = reminder['dateTime'].toLocal();
    }

    return ListTile(
      contentPadding: const EdgeInsets.all(16.0),
      title: Text(
        reminder['title'],
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 18.0,
        ),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 8.0),
          if (reminderDate != null)
            Text(
              DateFormat('HH:mm').format(reminderDate),
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 16.0,
              ),
            )
          else
            const Text(
              'Invalid time format',
              style: TextStyle(color: Colors.red),
            ),
          if (reminder['description'] != null &&
              reminder['description'].isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Text(
                reminder['description'],
                style: TextStyle(
                  color: Colors.grey[700],
                  fontSize: 14.0,
                ),
              ),
            ),
        ],
      ),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16.0),
      onTap: () {
        if (reminderDate != null) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => EditReminderForm(
                userId: widget.userId,
                reminder: reminder,
              ),
            ),
          ).then((value) => {_fetchReminders()});
        } else {
          _showErrorSnackBar("Cannot edit reminder with invalid date.");
        }
      },
    );
  }
}
