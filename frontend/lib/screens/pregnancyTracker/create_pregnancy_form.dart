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
  DateTime? _dueDate;
  bool? _hasUltrasound;

  Future<void> _selectDate(BuildContext context, bool isDueDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(DateTime.now().year - 1),
      lastDate: isDueDate ? DateTime(DateTime.now().year + 2) : DateTime.now(),
    );

    if (picked != null) {
      setState(() {
        if (isDueDate) {
          _dueDate = picked;
        } else {
          _selectedDate = picked;
          // Calculate due date if last period date is selected
          _dueDate = picked.add(const Duration(days: 280)); // 40 weeks
        }
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
              Text('Have you had an ultrasound test?'),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Yes'),
                  Radio<bool>(
                    value: true,
                    groupValue: _hasUltrasound,
                    onChanged: (bool? value) {
                      setState(() {
                        _hasUltrasound = value;
                        // Reset dates when switching between options
                        _selectedDate = null;
                        _dueDate = null;
                      });
                    },
                  ),
                  Text('No'),
                  Radio<bool>(
                    value: false,
                    groupValue: _hasUltrasound,
                    onChanged: (bool? value) {
                      setState(() {
                        _hasUltrasound = value;
                        // Reset dates when switching between options
                        _selectedDate = null;
                        _dueDate = null;
                      });
                    },
                  ),
                ],
              ),
              SizedBox(height: 16),
              if (_hasUltrasound == true) ...[
                Text('Select your due date:'),
                SizedBox(height: 8),
                ElevatedButton(
                  onPressed: () => _selectDate(context, true),
                  child: Text(_dueDate == null
                      ? 'Select Due Date'
                      : 'Due Date: ${_dueDate.toString().split(' ')[0]}'),
                ),
              ] else if (_hasUltrasound == false) ...[
                Text('Select the date of your last period:'),
                SizedBox(height: 8),
                ElevatedButton(
                  onPressed: () => _selectDate(context, false),
                  child: Text(_selectedDate == null
                      ? 'Select Last Period Date'
                      : 'Last Period: ${_selectedDate.toString().split(' ')[0]}'),
                ),
              ],
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: (_hasUltrasound == null ||
                        (_hasUltrasound! && _dueDate == null) ||
                        (!_hasUltrasound! && _selectedDate == null))
                    ? null
                    : () async {
                        try {
                          await pregnancyProvider.createPregnancy(
                            authProvider.username,
                            _hasUltrasound! ? _dueDate! : _selectedDate!,
                            _hasUltrasound!,
                          );
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                                content: Text(
                                    'Pregnancy tracker created successfully!')),
                          );
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(builder: (context) => HomePage()),
                          );
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                                content:
                                    Text('Failed to create pregnancy tracker')),
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
