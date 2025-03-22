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
          Provider.of<AuthProvider>(context, listen: false).user!.uid;
      final response = await http.get(
        Uri.parse('${Config.apiBaseUrl}/reminder/$userId'),
      );
      if (response.statusCode == 200) {
        setState(() {
          _reminders = json.decode(response.body);
          _remindersByDate = _groupRemindersByDate(_reminders);
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

  Map<DateTime, List<dynamic>> _groupRemindersByDate(List<dynamic> reminders) {
    Map<DateTime, List<dynamic>> groupedReminders = {};
    for (var reminder in reminders) {
      DateTime reminderDate =
          DateTime.parse(reminder['dateTime']).toLocal(); // Ensure local time
      DateTime dateOnly =
          DateTime(reminderDate.year, reminderDate.month, reminderDate.day);
      if (groupedReminders[dateOnly] == null) {
        groupedReminders[dateOnly] = [];
      }
      groupedReminders[dateOnly]!.add(reminder);
    }
    return groupedReminders;
  }

  List<dynamic> _getRemindersForDay(DateTime day) {
    return _remindersByDate[DateTime(day.year, day.month, day.day)] ?? [];
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
      appBar: AppBar(
        title: Text('Calendar'),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _fetchReminders,
          ),
          IconButton(
            icon: Icon(Icons.list),
            onPressed: () {
              // Navigate to a screen or show a dialog with all reminders
              showDialog(
                context: context,
                builder: (context) {
                  return AlertDialog(
                    title: Text("All Reminders"),
                    content: Container(
                      width: double.maxFinite,
                      child: ListView(
                        children: _reminders
                            .map((reminder) {
                              return ListTile(
                                title: Text(reminder['title']),
                                subtitle: Text(DateFormat('yyyy-MM-dd HH:mm')
                                    .format(
                                        DateTime.parse(reminder['dateTime']))),
                                onTap: () {
                                  showDialog(
                                    context: context,
                                    builder: (context) {
                                      return AlertDialog(
                                        title: Text(reminder['title']),
                                        content: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Text(
                                                'Date: ${DateFormat('yyyy-MM-dd').format(DateTime.parse(reminder['dateTime']))}'),
                                            Text(
                                                'Time: ${DateFormat('HH:mm').format(DateTime.parse(reminder['dateTime']))}'),
                                            if (reminder['description'] !=
                                                    null &&
                                                reminder['description']
                                                    .isNotEmpty)
                                              Text(
                                                  'Description: ${reminder['description']}'),
                                          ],
                                        ),
                                        actions: [
                                          TextButton(
                                            onPressed: () =>
                                                Navigator.pop(context),
                                            child: Text("Close"),
                                          ),
                                        ],
                                      );
                                    },
                                  );
                                },
                              );
                            })
                            .toList()
                            .reversed
                            .toList(),
                      ),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text("Close"),
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
            calendarStyle: CalendarStyle(
              markerDecoration: BoxDecoration(
                color: Colors.blue,
                shape: BoxShape.circle,
              ),
            ),
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
        child: Icon(Icons.add),
      ),
    );
  }
}
