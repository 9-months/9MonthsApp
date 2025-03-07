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

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
    _fetchReminders();
  }

  Future<void> _fetchReminders() async {
    try {
      final userId =
          Provider.of<AuthProvider>(context, listen: false).user!.uid;
      final response = await http.get(
        Uri.parse('http://localhost:3000/reminder/$userId'),
      );
      if (response.statusCode == 200) {
        setState(() {
          _reminders = json.decode(response.body);
        });
      } else {
        print('Failed to fetch reminders. Status code: ${response.statusCode}');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Failed to load reminders")),
          );
        }
      }
    } catch (e) {
      print('Error fetching reminders: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to load reminders")),
        );
      }
    }
  }

  List<dynamic> _getRemindersForDay(DateTime day) {
    return _reminders.where((reminder) {
      DateTime reminderDate = DateTime.parse(reminder['dateTime']);
      return isSameDay(reminderDate, day);
    }).toList();
  }

  Future<void> _deleteReminder(String reminderId) async {
    try {
      final response = await http.delete(
        Uri.parse(
            'http://localhost:3000/reminder/${widget.userId}/$reminderId'),
      );
      if (response.statusCode == 200) {
        _fetchReminders(); // Refresh reminders
      } else {
        print('Failed to delete reminder. Status code: ${response.statusCode}');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Failed to delete reminder")),
          );
        }
      }
    } catch (e) {
      print('Error deleting reminder: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to delete reminder")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Calendar')),
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
          ),
          Expanded(
            child: ListView(
              children: _getRemindersForDay(_selectedDay!).map((reminder) {
                return Dismissible(
                  key: Key(reminder['_id']),
                  onDismissed: (direction) {
                    _deleteReminder(reminder['_id']);
                  },
                  background: Container(color: Colors.red),
                  child: Card(
                    margin:
                        EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                    child: ListTile(
                      contentPadding: EdgeInsets.all(16.0),
                      title: Text(
                        reminder['title'],
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18.0,
                        ),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(height: 8.0),
                          Text(
                            DateFormat('HH:mm')
                                .format(DateTime.parse(reminder['dateTime'])),
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 16.0,
                            ),
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
                      trailing: Icon(Icons.arrow_forward_ios, size: 16.0),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => EditReminderForm(
                              userId: widget.userId,
                              reminder: reminder,
                            ),
                          ),
                        ).then((value) => {_fetchReminders()});
                      },
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton(
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
              child: Text('Add Reminder'),
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 16.0),
                textStyle: TextStyle(fontSize: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
