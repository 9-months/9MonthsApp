import 'package:_9months/config/config.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:timezone/data/latest.dart' as tz;
import '../../providers/auth_provider.dart';

class EditReminderForm extends StatefulWidget {
  final String userId;
  final Map<String, dynamic> reminder;

  const EditReminderForm({
    super.key,
    required this.userId,
    required this.reminder,
  });

  @override
  _EditReminderFormState createState() => _EditReminderFormState();
}

class _EditReminderFormState extends State<EditReminderForm> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  DateTime? _selectedDateTime;
  List<int> _alertOffsets = [0];
  String _type = 'appointment';
  String _repeat = 'none';
  String _location = '';

  final List<Map<String, dynamic>> _alertOptions = [
    {'label': 'At time of reminder', 'value': 0},
    {'label': '5 mins before', 'value': 5},
    {'label': '10 mins before', 'value': 10},
    {'label': '15 mins before', 'value': 15},
    {'label': '30 mins before', 'value': 30},
    {'label': '1 hour before', 'value': 60},
  ];

  @override
  void initState() {
    super.initState();
    tz.initializeTimeZones();

    _titleController = TextEditingController(text: widget.reminder['title']);
    _descriptionController =
        TextEditingController(text: widget.reminder['description']);
    _selectedDateTime = DateTime.parse(widget.reminder['dateTime']);
    _alertOffsets = List<int>.from(widget.reminder['alertOffsets']);
    _type = widget.reminder['type'];
    _repeat = widget.reminder['repeat'];
    _location = widget.reminder['location'];
  }

  Future<void> _selectDateTime(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDateTime ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (pickedDate != null) {
      final TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime:
            TimeOfDay.fromDateTime(_selectedDateTime ?? DateTime.now()),
      );
      if (pickedTime != null) {
        setState(() {
          _selectedDateTime = DateTime(
            pickedDate.year,
            pickedDate.month,
            pickedDate.day,
            pickedTime.hour,
            pickedTime.minute,
          );
        });
      }
    }
  }

  Future<void> _updateReminder() async {
    if (_formKey.currentState!.validate()) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final userId = authProvider.user?.uid;
      final token = authProvider.token;

      if (userId == null || token == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Failed to update reminder: User not logged in.')),
        );
        return;
      }

      final response = await http.put(
        Uri.parse(
            '${Config.apiBaseUrl}/reminder/$userId/${widget.reminder['_id']}'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode({
          'title': _titleController.text,
          'description': _descriptionController.text,
          'dateTime': _selectedDateTime!.toIso8601String(),
          'alertOffsets': _alertOffsets,
          'type': _type,
          'repeat': _repeat,
          'location': _location,
        }),
      );
      if (response.statusCode == 200) {
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to update reminder")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Edit Reminder')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              Text(
                'Reminder Details',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 16),
              Card(
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      TextFormField(
                        controller: _titleController,
                        decoration: InputDecoration(
                          labelText: 'Title',
                          prefixIcon: Icon(Icons.title),
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter a title';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 16),
                      TextFormField(
                        controller: _descriptionController,
                        decoration: InputDecoration(
                          labelText: 'Description',
                          prefixIcon: Icon(Icons.description),
                          border: OutlineInputBorder(),
                        ),
                      ),
                      SizedBox(height: 16),
                      ElevatedButton.icon(
                        onPressed: () => _selectDateTime(context),
                        icon: Icon(Icons.calendar_today),
                        label: Text(
                          _selectedDateTime == null
                              ? 'Select Date & Time'
                              : DateFormat('yyyy-MM-dd HH:mm')
                                  .format(_selectedDateTime!),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 16),
              Text(
                'Additional Settings',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 16),
              Card(
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      DropdownButtonFormField<String>(
                        value: _type,
                        items: ['appointment', 'medicine', 'other']
                            .map((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _type = value!;
                          });
                        },
                        decoration: InputDecoration(
                          labelText: 'Type',
                          prefixIcon: Icon(Icons.category),
                          border: OutlineInputBorder(),
                        ),
                      ),
                      SizedBox(height: 16),
                      DropdownButtonFormField<String>(
                        value: _repeat,
                        items: ['none', 'daily', 'weekly', 'monthly', 'yearly']
                            .map((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _repeat = value!;
                          });
                        },
                        decoration: InputDecoration(
                          labelText: 'Repeat',
                          prefixIcon: Icon(Icons.repeat),
                          border: OutlineInputBorder(),
                        ),
                      ),
                      SizedBox(height: 16),
                      TextFormField(
                        decoration: InputDecoration(
                          labelText: 'Location',
                          prefixIcon: Icon(Icons.location_on),
                          border: OutlineInputBorder(),
                        ),
                        initialValue: _location,
                        onChanged: (value) {
                          setState(() {
                            _location = value;
                          });
                        },
                      ),
                      SizedBox(height: 16),
                      DropdownButtonFormField<int>(
                        value: _alertOffsets.first,
                        items: _alertOptions.map((option) {
                          return DropdownMenuItem<int>(
                            value: option['value'],
                            child: Text(option['label']),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _alertOffsets = [value!];
                          });
                        },
                        decoration: InputDecoration(
                          labelText: 'Alert',
                          prefixIcon: Icon(Icons.alarm),
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 24),
              ElevatedButton(
                onPressed: _updateReminder,
                child: Text('Update Reminder'),
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 16.0),
                  textStyle: TextStyle(fontSize: 16),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
