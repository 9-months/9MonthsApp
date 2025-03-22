/*
 File: emergency_btn.dart
 Purpose: emergency button widget to call partner or ambulance
 Created Date: CCS-9 08-03-2025
 Author: Dinith Perera

 last modified: 08-03-2025 | Dinith | enhanced UI and hardcoded partner info
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
    this.color = Colors.white, // Default to white for better contrast on red background
  }) : super(key: key);

  @override
  State<EmergencyButton> createState() => _EmergencyButtonState();
}

class _EmergencyButtonState extends State<EmergencyButton> {
  final EmergencyService _emergencyService = EmergencyService();
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    // Using a container with emergency styling
    return GestureDetector(
      onTap: _isLoading ? null : _handleEmergencyPress,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: theme.colorScheme.error,
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: theme.colorScheme.error.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: _isLoading 
            ? SizedBox(
                width: widget.size,
                height: widget.size,
                child: CircularProgressIndicator(color: widget.color),
              )
            : Icon(widget.icon, size: widget.size, color: widget.color),
      ),
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
    // Hardcoded partner information as requested
    const partnerNumber = '+94729457512'; 
    // ignore: unused_local_variable
    const partnerName = 'Irosh';
    
    _makePhoneCall(partnerNumber);
    _logEmergencyCall('partner');
  }

  Future<void> _callAmbulance() async {
    const ambulanceNumber = '1990'; // Suwa Sariya ambulance
    _makePhoneCall(ambulanceNumber);
    _logEmergencyCall('ambulance');
  }

  Future<void> _makePhoneCall(String number) async {
    final Uri phoneUri = Uri(scheme: 'tel', path: number);
    
    try {
      if (await canLaunchUrl(phoneUri)) {
        await launchUrl(phoneUri);
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Could not launch phone app')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
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
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
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
    final theme = Theme.of(context);
    
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
      ),
      elevation: 0,
      backgroundColor: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.rectangle,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 10.0,
              offset: const Offset(0.0, 10.0),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
  clipBehavior: Clip.none,
  alignment: Alignment.topCenter,
  children: [
    Container(
      height: 70,
      width: double.infinity,
      decoration: BoxDecoration(
        color: theme.colorScheme.error.withOpacity(0.1),
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(20),
          bottom: Radius.circular(40),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.pregnant_woman,
            color: theme.colorScheme.error,
            size: 28,
          ),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 8),
            width: 80,
            height: 2,
            decoration: BoxDecoration(
              color: theme.colorScheme.error,
              borderRadius: BorderRadius.circular(1),
            ),
          ),
          Icon(
            Icons.local_hospital,
            color: theme.colorScheme.error,
            size: 28,
          ),
        ],
      ),
    ),
    Positioned(
      top: -30,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          border: Border.all(
            color: theme.colorScheme.error,
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: theme.colorScheme.error.withOpacity(0.3),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Icon(
          Icons.emergency,
          color: theme.colorScheme.error,
          size: 40,
        ),
      ),
    ),
  ],
),
            const SizedBox(height: 24),
            Text(
              'Emergency Call',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.error,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            Text(
              'Who do you want to call for emergency assistance?',
              style: theme.textTheme.bodyLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            // Partner Call Button with cute bubble design
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: theme.colorScheme.primary.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () {
                    Navigator.of(context).pop();
                    onCallPartner();
                  },
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          theme.colorScheme.primary,
                          theme.colorScheme.primary.withOpacity(0.8),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.favorite,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Call Irosh',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            Text(
                              '(My Partner)',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.white.withOpacity(0.8),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Ambulance Call Button
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.green.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () {
                    Navigator.of(context).pop();
                    onCallAmbulance();
                  },
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.green,
                          Colors.green.shade600,
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.local_hospital,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Call 1990',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            Text(
                              'Suwa Sariya Ambulance',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.white.withOpacity(0.9),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Cancel button with soft design
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              child: Text(
                'Cancel',
                style: TextStyle(
                  color: theme.colorScheme.onSurface.withOpacity(0.7),
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Custom painter for heartbeat line
class HeartbeatPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;

  HeartbeatPainter({
    required this.color,
    this.strokeWidth = 2.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    Path path = Path();
    
    // Starting point
    path.moveTo(0, size.height / 2);
    
    // First gentle wave
    path.lineTo(size.width * 0.15, size.height / 2);
    
    // Heartbeat spike up
    path.lineTo(size.width * 0.2, size.height * 0.3);
    path.lineTo(size.width * 0.3, size.height * 0.8);
    path.lineTo(size.width * 0.4, size.height * 0.1);
    path.lineTo(size.width * 0.5, size.height * 0.8);
    
    // Return to baseline
    path.lineTo(size.width * 0.6, size.height / 2);
    
    // Small bump
    path.lineTo(size.width * 0.75, size.height / 2);
    path.lineTo(size.width * 0.8, size.height * 0.4);
    path.lineTo(size.width * 0.85, size.height / 2);
    
    // End
    path.lineTo(size.width, size.height / 2);
    
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}