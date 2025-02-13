import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../services/pregnancy_service.dart';

class CreatePregnancyScreen extends StatefulWidget {
  const CreatePregnancyScreen({super.key});

  @override
  _CreatePregnancyScreenState createState() => _CreatePregnancyScreenState();
}

class _CreatePregnancyScreenState extends State<CreatePregnancyScreen> {
  DateTime? selectedDate;
  final PregnancyService _pregnancyService = PregnancyService();

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now().subtract(Duration(days: 280)),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  Future<void> _createPregnancy() async {
    if (selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please select your last period date')),
      );
      return;
    }

    try {
      await _pregnancyService.createPregnancy('USER_ID', selectedDate!);
      Navigator.pushReplacementNamed(context, '/home');
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error creating pregnancy data')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Start Tracking'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'When was your last period?',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => _selectDate(context),
              child: Text(
                selectedDate == null
                    ? 'Select Date'
                    : DateFormat('MMM dd, yyyy').format(selectedDate!),
              ),
            ),
            SizedBox(height: 32),
            ElevatedButton(
              onPressed: _createPregnancy,
              style: ElevatedButton.styleFrom(
                minimumSize: Size(double.infinity, 48),
              ),
              child: Text('Start Tracking'),
            ),
          ],
        ),
      ),
    );
  }
}