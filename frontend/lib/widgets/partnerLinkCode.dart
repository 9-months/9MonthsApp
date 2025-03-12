import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../services/auth_service.dart';

class PartnerLinkCodeSection extends StatefulWidget {
  const PartnerLinkCodeSection({super.key});

  @override
  State<PartnerLinkCodeSection> createState() => _PartnerLinkCodeSectionState();
}

class _PartnerLinkCodeSectionState extends State<PartnerLinkCodeSection> {
  String? _linkCode;
  bool _isGenerating = false;

  Future<void> _generateLinkCode() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    
    if (authProvider.user == null) return;
    
    setState(() {
      _isGenerating = true;
    });
    
    try {
      final authService = AuthService();
      final code = await authService.generatePartnerLinkCode(authProvider.user!.uid);
      
      setState(() {
        _linkCode = code;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to generate code: ${e.toString()}')),
      );
    } finally {
      setState(() {
        _isGenerating = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(16.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Partner Link Code',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Generate a code to share with your partner. They can use this code to link their account with yours.',
            ),
            const SizedBox(height: 16),
            if (_linkCode != null)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  children: [
                    Text(
                      _linkCode!,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 2,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'This code will expire in 24 hours',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _isGenerating ? null : _generateLinkCode,
              child: _isGenerating
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text(_linkCode == null ? 'Generate Link Code' : 'Generate New Code'),
            ),
          ],
        ),
      ),
    );
  }
}
