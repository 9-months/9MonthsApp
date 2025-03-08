/*
 File: emergency_btn.dart
 Purpose: emergency button widget to call partner or ambulance
 Created Date: CCS-9 08-03-2025
 Author: Dinith Perera

 last modified: 08-03-2025 | Dinith | dart created 
*/

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../services/emergency_service.dart';


class EmergencyButton extends StatefulWidget {
  final IconData icon;
  final double size;
  final Color color;

  const EmergencyButton({
    Key? key,
    this.icon = Icons.emergency,
    this.size = 24.0,
    this.color = Colors.red,
  }) : super(key: key);

  @override
  State<EmergencyButton> createState() => _EmergencyButtonState();
}

class _EmergencyButtonState extends State<EmergencyButton> {
  final EmergencyService _emergencyService = EmergencyService();
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: _isLoading 
          ? SizedBox(
              width: widget.size,
              height: widget.size,
              child: CircularProgressIndicator(color: widget.color),
            )
          : Icon(widget.icon, size: widget.size, color: widget.color),
      onPressed: _isLoading ? null : _handleEmergencyPress,
    );
  }

  Future<void> _handleEmergencyPress() async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return EmergencyDialog(
          onCallPartner: _callPartner,
          onCallAmbulance: _callAmbulance,
        );
      },
    );
  }

  Future<void> _callPartner() async {
  // Temporary solution - replace with proper user management later
  const partnerNumber = ''; // Empty for now, add default or test number if needed
  
  if (partnerNumber.isNotEmpty) {
    _makePhoneCall(partnerNumber);
    _logEmergencyCall('partner');
  } else {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('No partner number saved')),
    );
  }
}

  Future<void> _callAmbulance() async {
    const ambulanceNumber = '+941990'; // Suwa Sariya ambulance
    _makePhoneCall(ambulanceNumber);
    _logEmergencyCall('ambulance');
  }

  Future<void> _makePhoneCall(String number) async {
    final Uri phoneUri = Uri(scheme: 'tel', path: number);
    
    try {
      if (await canLaunchUrl(phoneUri)) {
        await launchUrl(phoneUri);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not launch phone app')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    }
  }

  Future<void> _logEmergencyCall(String callType) async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Use existing service with new method
      await _emergencyService.sendEmergencyAlertWithType(
        callType: callType,
        location: 'Current Location', 
      );
      
      // Also call the original method for backward compatibility
      await _emergencyService.sendEmergencyAlert();
    } catch (e) {
      print('Error logging emergency call: ${e.toString()}');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
}

class EmergencyDialog extends StatelessWidget {
  final Function onCallPartner;
  final Function onCallAmbulance;

  const EmergencyDialog({
    Key? key,
    required this.onCallPartner,
    required this.onCallAmbulance,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        children: [
          Icon(Icons.warning_amber_rounded, color: Colors.red, size: 28),
          SizedBox(width: 10),
          Text('Emergency Call', style: TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
      content: Text(
        'Who do you want to call for emergency assistance?',
        style: TextStyle(fontSize: 16),
      ),
      actions: [
        Column(
          children: [
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  onCallPartner();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  padding: EdgeInsets.symmetric(vertical: 12),
                ),
                child: Text('Call Partner'),
              ),
            ),
            SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  onCallAmbulance();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  padding: EdgeInsets.symmetric(vertical: 12),
                ),
                child: Text('Call 1990 Suwa Sariya Ambulance'),
              ),
            ),
            SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text('Cancel'),
              ),
            ),
          ],
        ),
      ],
    );
  }
}