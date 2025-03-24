import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../services/profile_service.dart';

class ProfileForm extends StatefulWidget {
  @override
  _ProfileFormState createState() => _ProfileFormState();
}

class _ProfileFormState extends State<ProfileForm> {
  final _formKey = GlobalKey<FormState>();
  String _accountType = 'mother'; // Make sure this matches one of the dropdown options
  DateTime _birthday = DateTime.now();
  late String _location;
  late String _phoneNumber;

  @override
  Widget build(BuildContext context) {
    // Get possible values for dropdown
    final accountTypes = ['mother', 'partner'];
    
    // Ensure _accountType is a valid option
    if (!accountTypes.contains(_accountType)) {
      _accountType = accountTypes[0]; // Default to 'mother' if invalid
    }
    
    return Scaffold(
      appBar: AppBar(
        title: Text('Complete Profile'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              DropdownButtonFormField<String>(
                value: _accountType,
                decoration: InputDecoration(
                  labelText: 'Account Type',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
                items: accountTypes.map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (newValue) {
                  setState(() {
                    _accountType = newValue!;
                  });
                },
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Please select an account type';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Date of Birth',
                  hintText: 'Select your date of birth',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
                readOnly: true,
                onTap: () async {
                  DateTime? pickedDate = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime(1900),
                    lastDate: DateTime.now(),
                  );
                  if (pickedDate != null) {
                    setState(() {
                      _birthday = pickedDate;
                    });
                  }
                },
                validator: (value) {
                  if (_birthday == null) {
                    return 'Please select your date of birth';
                  }
                  return null;
                },
                controller: TextEditingController(
                  text: _birthday == null
                      ? ''
                      : DateFormat('yyyy-MM-dd').format(_birthday),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Location',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
                onChanged: (value) {
                  _location = value;
                },
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Please enter your location';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Phone Number',
                  prefixText: '+94 ',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
                keyboardType: TextInputType.phone,
                onChanged: (value) {
                  _phoneNumber = value;
                },
                validator: (value) {
                  if (value!.isEmpty || !RegExp(r'^\d{9}$').hasMatch(value!)) {
                    return 'Please enter a valid phone number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    _submitForm();
                  }
                },
                child: Text('Submit'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _submitForm() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final uid = authProvider.user!.uid;
    try {
      // Format phone number with +94 prefix
      final formattedPhone = '+94${_phoneNumber.trim()}';
      
      // Prepare profile data
      final profileData = {
        'accountType': _accountType,
        'birthday': DateFormat('yyyy-MM-dd').format(_birthday),
        'location': _location,
        'phone': formattedPhone,
      };
      
      // Submit profile data to backend
      await authProvider.completeProfile(uid, profileData);
      
      // Update user profile in AuthProvider
      await authProvider.updateUserProfile(
        accountType: _accountType,
        birthday: DateFormat('yyyy-MM-dd').format(_birthday),
        location: _location,
        phone: formattedPhone,
      );
      
      // Route to appropriate homepage based on account type
      if (_accountType.toLowerCase() == 'partner') {
        Navigator.pushReplacementNamed(context, '/partner-home');
      } else {
        Navigator.pushReplacementNamed(context, '/home');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to complete profile: ${e.toString()}')),
      );
    }
  }
}
