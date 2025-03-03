/*
 File: add_reminder_screen.dart
 Purpose: UI for adding a new reminder
 Created Date: 02-03-2025
 Author: Chamod Kamiss
*/

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../services/reminder_service.dart';

class AddReminderScreen extends StatefulWidget {
  final String userId;

  const AddReminderScreen({super.key, required this.userId});

  @override
  State<AddReminderScreen> createState() => _AddReminderScreenState();
}

class _AddReminderScreenState extends State<AddReminderScreen> {
  final _formKey = GlobalKey<FormState>();
  final ReminderService _reminderService = ReminderService();
  
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _locationController = TextEditingController();
  
  DateTime _selectedDate = DateTime.now();
  TimeOfDay _selectedTime = TimeOfDay.now();
  String _selectedRepeat = 'none';
  String _selectedType = 'appointment';
  final List<int> _alertOffsets = [30]; // Default 30 minutes before
  bool _isSubmitting = false;

  final List<String> _repeatOptions = ['none', 'daily', 'weekly', 'monthly', 'yearly'];
  final List<String> _typeOptions = ['medicine', 'appointment', 'other'];
  
  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );
    if (picked != null && picked != _selectedTime) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  Future<void> _saveReminder() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isSubmitting = true;
    });

    try {
      // Combine date and time
      final dateTime = DateTime(
        _selectedDate.year,
        _selectedDate.month,
        _selectedDate.day,
        _selectedTime.hour,
        _selectedTime.minute,
      );

      final reminderData = {
        'title': _titleController.text,
        'description': _descriptionController.text,
        'location': _locationController.text,
        'dateTime': dateTime.toIso8601String(),
        'timezone': 'UTC', // Use device timezone in real app
        'repeat': _selectedRepeat,
        'alertOffsets': _alertOffsets,
        'type': _selectedType,
      };

      await _reminderService.createReminder(widget.userId, reminderData);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Reminder created successfully')),
        );
        Navigator.pop(context, true); // Return true to indicate success
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to create reminder: ${e.toString()}')),
        );
      }
    } finally {
      setState(() {
        _isSubmitting = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Reminder'),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
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
              const SizedBox(height: 16),
              
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description (optional)',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              
              TextFormField(
                controller: _locationController,
                decoration: const InputDecoration(
                  labelText: 'Location (optional)',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              
              // Date and Time
              Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: () => _selectDate(context),
                      child: InputDecorator(
                        decoration: const InputDecoration(
                          labelText: 'Date',
                          border: OutlineInputBorder(),
                        ),
                        child: Text(
                          DateFormat('MMM d, yyyy').format(_selectedDate),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: InkWell(
                      onTap: () => _selectTime(context),
                      child: InputDecorator(
                        decoration: const InputDecoration(
                          labelText: 'Time',
                          border: OutlineInputBorder(),
                        ),
                        child: Text(
                          _selectedTime.format(context),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              
              // Type selection
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: 'Reminder Type',
                  border: OutlineInputBorder(),
                ),
                value: _selectedType,
                items: _typeOptions.map((String type) {
                  return DropdownMenuItem<String>(
                    value: type,
                    child: Text(type.substring(0, 1).toUpperCase() + type.substring(1)),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  if (newValue != null) {
                    setState(() {
                      _selectedType = newValue;
                    });
                  }
                },
              ),
              const SizedBox(height: 16),
              
              // Repeat selection
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: 'Repeat',
                  border: OutlineInputBorder(),
                ),
                value: _selectedRepeat,
                items: _repeatOptions.map((String option) {
                  return DropdownMenuItem<String>(
                    value: option,
                    child: Text(option.substring(0, 1).toUpperCase() + option.substring(1)),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  if (newValue != null) {
                    setState(() {
                      _selectedRepeat = newValue;
                    });
                  }
                },
              ),
              const SizedBox(height: 16),
              
              // Alert times
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Remind me before:',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: [
                      _buildChip(15, 'At time'),
                      _buildChip(15, '15 min'),
                      _buildChip(30, '30 min'),
                      _buildChip(60, '1 hour'),
                      _buildChip(24 * 60, '1 day'),
                    ],
                  ),
                ],
              ),
              
              const SizedBox(height: 32),
              
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isSubmitting ? null : _saveReminder,
                  child: _isSubmitting
                      ? const CircularProgressIndicator()
                      : const Text('Save Reminder'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildChip(int minutes, String label) {
    final isSelected = _alertOffsets.contains(minutes);
    
    return FilterChip(
      selected: isSelected,
      label: Text(label),
      onSelected: (bool selected) {
        setState(() {
          if (selected) {
            _alertOffsets.add(minutes);
          } else {
            _alertOffsets.remove(minutes);
          }
        });
      },
    );
  }
}