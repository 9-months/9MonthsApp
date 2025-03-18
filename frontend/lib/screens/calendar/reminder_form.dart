import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:timezone/data/latest.dart' as tzdata;
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../../providers/auth_provider.dart';

class ReminderForm extends StatefulWidget {
  final String userId;
  final DateTime? selectedDate;

  const ReminderForm({super.key, required this.userId, this.selectedDate});

  @override
  _ReminderFormState createState() => _ReminderFormState();
}

class _ReminderFormState extends State<ReminderForm> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  DateTime? _selectedTime;
  List<int> _alertOffsets = [0];
  final List<Map<String, dynamic>> _alertOptions = [
    {'label': 'At time of reminder', 'value': 0},
    {'label': '5 mins before', 'value': 5},
    {'label': '10 mins before', 'value': 10},
    {'label': '15 mins before', 'value': 15},
    {'label': '30 mins before', 'value': 30},
    {'label': '1 hour before', 'value': 60},
  ];
  String _type = 'appointment';
  String _timezone = 'Asia/Colombo';
  String _repeat = 'none';
  String _location = '';

  @override
  void initState() {
    super.initState();
    tzdata.initializeTimeZones();
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() {
        _selectedTime = DateTime(
          widget.selectedDate!.year,
          widget.selectedDate!.month,
          widget.selectedDate!.day,
          picked.hour,
          picked.minute,
        );
      });
    }
  }

  Future<void> _createReminder() async {
    if (_formKey.currentState!.validate()) {
      final userId =
          Provider.of<AuthProvider>(context, listen: false).user!.uid;
      final response = await http.post(
        Uri.parse('http://localhost:3000/reminder/$userId'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'title': _titleController.text,
          'description': _descriptionController.text,
          'dateTime': _selectedTime!.toIso8601String(),
          'timezone': _timezone,
          'repeat': _repeat,
          'alertOffsets': _alertOffsets,
          'type': _type,
          'location': _location,
        }),
      );
      if (response.statusCode == 201) {
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to create reminder")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('New Reminder')),
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
                        onPressed: () => _selectTime(context),
                        icon: Icon(Icons.access_time),
                        label: Text(
                          _selectedTime == null
                              ? 'Select Time'
                              : DateFormat('yyyy-MM-dd HH:mm')
                                  .format(_selectedTime!),
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
                onPressed: _createReminder,
                child: Text('Create Reminder'),
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
