import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';

class PartnerLinkingPage extends StatefulWidget {
  const PartnerLinkingPage({super.key});

  @override
  State<PartnerLinkingPage> createState() => _PartnerLinkingPageState();
}

class _PartnerLinkingPageState extends State<PartnerLinkingPage> {
  final _formKey = GlobalKey<FormState>();
  final _partnerCodeController = TextEditingController();
  bool _isLoading = false;
  
  Future<void> _linkWithPartner() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() {
      _isLoading = true;
    });
    
    try {
      final partnerId = _partnerCodeController.text.trim();
      final success = await context.read<AuthProvider>().linkPartner(partnerId);
      
      if (!mounted) return;
      
      if (success) {
        Navigator.pushReplacementNamed(context, '/home');
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to link with partner')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Link with Your Partner'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'Enter your partner\'s code',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                const Text(
                  'Ask your partner to share their linking code from their profile',
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                
                TextFormField(
                  controller: _partnerCodeController,
                  decoration: const InputDecoration(
                    labelText: 'Partner Code',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter the partner code';
                    }
                    return null;
                  },
                ),
                
                const SizedBox(height: 24),
                
                ElevatedButton(
                  onPressed: _isLoading ? null : _linkWithPartner,
                  child: _isLoading
                      ? const CircularProgressIndicator()
                      : const Text('Link with Partner'),
                ),
                
                const SizedBox(height: 16),
                
                TextButton(
                  onPressed: () {
                    Navigator.pushReplacementNamed(context, '/home');
                  },
                  child: const Text('Skip for now'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
  
  @override
  void dispose() {
    _partnerCodeController.dispose();
    super.dispose();
  }
}