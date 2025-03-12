import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/pregnancy_provider.dart';

class PartnerHomeContent extends StatelessWidget {
  final String? partnerId;
  
  const PartnerHomeContent({super.key, this.partnerId});
  
  @override
  Widget build(BuildContext context) {
    final pregnancyProvider = Provider.of<PregnancyProvider>(context);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Card(
          margin: const EdgeInsets.only(bottom: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Partner Support Tips',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 16),
                FutureBuilder(
                  future: pregnancyProvider.fetchPartnerTips(partnerId),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    
                    if (snapshot.hasError || !snapshot.hasData) {
                      return const Text('Unable to load partner tips');
                    }
                    
                    final tips = snapshot.data!;
                    return Column(
                      children: tips.map((tip) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(Icons.tips_and_updates, color: Colors.amber),
                            const SizedBox(width: 8),
                            Expanded(child: Text(tip)),
                          ],
                        ),
                      )).toList(),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
        
        Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'How You Can Help',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 16),
                const PartnerSupportItem(
                  icon: Icons.favorite_outline,
                  title: 'Emotional Support',
                  description: 'Be patient, listen actively, and validate her feelings.',
                ),
                const Divider(),
                const PartnerSupportItem(
                  icon: Icons.medical_services_outlined,
                  title: 'Attend Appointments',
                  description: 'Go to prenatal checkups and be involved in healthcare decisions.',
                ),
                const Divider(),
                const PartnerSupportItem(
                  icon: Icons.restaurant_outlined,
                  title: 'Help with Nutrition',
                  description: 'Cook healthy meals and ensure she stays hydrated.',
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class PartnerSupportItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  
  const PartnerSupportItem({
    super.key,
    required this.icon,
    required this.title,
    required this.description,
  });
  
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 28, color: Theme.of(context).primaryColor),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(description),
              ],
            ),
          ),
        ],
      ),
    );
  }
}