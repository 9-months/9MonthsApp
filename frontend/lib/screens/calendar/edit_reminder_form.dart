import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:timezone/data/latest.dart' as tzdata;
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:_9months/providers/auth_provider.dart';

class EditReminderForm extends StatefulWidget {
  final String userId;
  final Map<String, dynamic> reminder;

  const EditReminderForm(
      {super.key, required this.userId, required this.reminder});

  @override
  _EditReminderFormState createState() => _EditReminderFormState();
}

class _EditReminderFormState extends State<EditReminderForm> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  DateTime? _selectedTime;
  List<int> _alertOffsets = [0]; // Default alert offset at the time of reminder
  final List<Map<String, dynamic>> _alertOptions = [
    {'label': 'At time of reminder', 'value': 0},
    {'label': '5 mins before', 'value': 5},
    {'label': '10 mins before', 'value': 10},
    {'label': '15 mins before', 'value': 15},
    {'label': '30 mins before', 'value': 30},
    {'label': '1 hour before', 'value': 60},
  ];
  String _type = 'appointment';
  String _timezone = 'Asia/Colombo'; // Default to Sri Lankan timezone
  String _repeat = 'none';
  String _location = '';

  @override
  void initState() {
    super.initState();
    tzdata.initializeTimeZones(); // Initialize time zone data

    _titleController = TextEditingController(text: widget.reminder['title']);
    _descriptionController =
        TextEditingController(text: widget.reminder['description']);
    _selectedTime = DateTime.parse(widget.reminder['dateTime']);
    _alertOffsets = List<int>.from(widget.reminder['alertOffsets']);
    _type = widget.reminder['type'];
    _timezone = widget.reminder['timezone'];
    _repeat = widget.reminder['repeat'];
    _location = widget.reminder['location'];
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_selectedTime!),
    );
    if (picked != null) {
      setState(() {
        _selectedTime = DateTime(
          _selectedTime!.year,
          _selectedTime!.month,
          _selectedTime!.day,
          picked.hour,
          picked.minute,
        );
      });
    }
  }

  Future<void> _updateReminder() async {
    if (_formKey.currentState!.validate()) {
      final userId =
          Provider.of<AuthProvider>(context, listen: false).user!.uid;
      final response = await http.put(
        Uri.parse(
            'http://localhost:3000/reminder/$userId/${widget.reminder['_id']}'),
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
      if (response.statusCode == 200) {
        Navigator.pop(context);
      } else {
        print('Failed to update reminder. Status code: ${response.statusCode}');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text("Failed to update reminder")));
        }
      }
    }
    print('Timezone: $_timezone');
    print('Updated Time: ${_selectedTime!.toIso8601String()}');
    print(
        'Request URL: ${Uri.parse('http://localhost:3000/reminder/${Provider.of<AuthProvider>(context, listen: false).user!.uid}/${widget.reminder['_id']}')}');
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
      appBar: AppBar(title: Text('Edit Reminder')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: TextFormField(
                  controller: _titleController,
                  decoration: InputDecoration(
                    labelText: 'Title',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a title';
                    }
                    return null;
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: TextFormField(
                  controller: _descriptionController,
                  decoration: InputDecoration(
                    labelText: 'Description',
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: ElevatedButton(
                  onPressed: () => _selectTime(context),
                  child: Text(_selectedTime == null
                      ? 'Select Time'
                      : DateFormat('HH:mm').format(_selectedTime!)),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: DropdownButtonFormField<String>(
                  value: _type,
                  items:
                      ['appointment', 'medicine', 'other'].map((String value) {
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
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: DropdownButtonFormField<String>(
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
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: TextFormField(
                  decoration: InputDecoration(
                    labelText: 'Location',
                    border: OutlineInputBorder(),
                  ),
                  initialValue: _location,
                  onChanged: (value) {
                    setState(() {
                      _location = value;
                    });
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: DropdownButtonFormField<int>(
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
                    labelText: 'Early reminder',
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                child: ElevatedButton(
                  onPressed: _updateReminder,
                  child: Text('Update Reminder'),
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 16.0),
                    textStyle: TextStyle(fontSize: 16),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
