import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/pregnancy_provider.dart';
import '../home/home_page.dart';

class CreatePregnancyForm extends StatefulWidget {
  @override
  _CreatePregnancyFormState createState() => _CreatePregnancyFormState();
}

class _CreatePregnancyFormState extends State<CreatePregnancyForm> {
  DateTime? _selectedDate;

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(DateTime.now().year - 1),
      lastDate: DateTime.now(),
    );

    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final pregnancyProvider = Provider.of<PregnancyProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Create Pregnancy Tracker'),
      ),
      body: Center(
        child: Card(
          margin: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Create Pregnancy Tracker',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              SizedBox(height: 16),
              Text('Select the date of your last period:'),
              SizedBox(height: 8),
              ElevatedButton(
                onPressed: () => _selectDate(context),
                child: Text(_selectedDate == null
                    ? 'Select Date'
                    : 'Selected Date: ${_selectedDate.toString().split(' ')[0]}'),
              ),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: _selectedDate == null
                    ? null
                    : () async {
                        try {
                          await pregnancyProvider.createPregnancy(
                            authProvider.username,
                            _selectedDate!,
                          );
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Pregnancy tracker created successfully!')),
                          );
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(builder: (context) => HomePage()),
                          );
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Failed to create pregnancy tracker')),
                          );
                        }
                      },
                child: Text('Create Tracker'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}