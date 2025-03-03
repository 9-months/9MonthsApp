import 'package:_9months/providers/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:timezone/data/latest.dart' as tzdata;
import 'package:provider/provider.dart';
// ignore: depend_on_referenced_packages

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
  List<int> _alertOffsets = [5];
  String _type = 'appointment';
  String _timezone = 'Asia/Colombo'; // Default to Sri Lankan timezone
  String _repeat = 'none';
  String _location = '';

  @override
  void initState() {
    super.initState();
    tzdata.initializeTimeZones(); // Initialize time zone data
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
        print('Failed to create reminder. Status code: ${response.statusCode}');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text("Failed to create reminder")));
        }
      }
    }
    print(
        'Request URL: ${Uri.parse('http://localhost:3000/reminder/${Provider.of<AuthProvider>(context, listen: false).user!.uid}')}');
    print('Request Body: ${json.encode({
          'title': _titleController.text,
          'description': _descriptionController.text,
          'dateTime': _selectedTime!.toIso8601String(),
          'timezone': _timezone,
          'repeat': _repeat,
          'alertOffsets': _alertOffsets,
          'type': _type,
          'location': _location,
        })}');
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
              TextFormField(
                controller: _titleController,
                decoration: InputDecoration(labelText: 'Title'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a title';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _descriptionController,
                decoration: InputDecoration(labelText: 'Description'),
              ),
              ElevatedButton(
                onPressed: () => _selectTime(context),
                child: Text(_selectedTime == null
                    ? 'Select Time'
                    : DateFormat('HH:mm').format(_selectedTime!)),
              ),
              DropdownButtonFormField<String>(
                value: _type,
                items: ['appointment', 'medicine', 'other'].map((String value) {
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
                decoration: InputDecoration(labelText: 'Type'),
              ),
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
                decoration: InputDecoration(labelText: 'Repeat'),
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Timezone'),
                initialValue: _timezone,
                onChanged: (value) {
                  setState(() {
                    _timezone = value;
                  });
                },
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Location'),
                initialValue: _location,
                onChanged: (value) {
                  setState(() {
                    _location = value;
                  });
                },
              ),
              TextFormField(
                decoration: InputDecoration(
                    labelText: 'Alert Offsets (comma separated)'),
                initialValue: _alertOffsets.join(','),
                onChanged: (value) {
                  setState(() {
                    _alertOffsets = value
                        .split(',')
                        .map((e) => int.tryParse(e.trim()) ?? 0)
                        .toList();
                  });
                },
              ),
              ElevatedButton(
                onPressed: _createReminder,
                child: Text('Create Reminder'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
