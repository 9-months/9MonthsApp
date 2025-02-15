import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/pregnancy_provider.dart';
import 'create_pregnancy_form.dart';
import 'pregnancy_info.dart';


class PregnancyTrackerPage extends StatelessWidget {
  const PregnancyTrackerPage({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final pregnancyProvider = Provider.of<PregnancyProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Pregnancy Journey'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: authProvider.isLoggedIn
          ? FutureBuilder(
              future: pregnancyProvider.fetchPregnancyData(authProvider.username),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error_outline, size: 48, color: Colors.blue),
                        const SizedBox(height: 16),
                        Text('Error: ${snapshot.error}'),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const PregnancyTrackerPage(),
                              ),
                            );
                          },
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  );
                } else if (!snapshot.hasData) {
                  return Center(
                    child: Card(
                      margin: const EdgeInsets.all(16),
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.favorite, size: 64, color: Colors.pink),
                            const SizedBox(height: 24),
                            Text(
                              'Start Your Pregnancy Journey',
                              style: Theme.of(context).textTheme.headlineSmall,
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 16),
                            const Text(
                              'Track your pregnancy progress, get weekly updates, and helpful tips for your journey to motherhood.',
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 24),
                            ElevatedButton.icon(
                              icon: const Icon(Icons.add),
                              label: const Text('Create Pregnancy Tracker'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.pink,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 32,
                                  vertical: 16,
                                ),
                              ),
                              onPressed: () {
                                showModalBottomSheet(
                                  context: context,
                                  isScrollControlled: true,
                                  builder: (context) => CreatePregnancyForm(),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                } else {
                  return PregnancyInfo(pregnancyData: snapshot.data!);
                }
              },
            )
          : const Center(
              child: Text('Please login to track your pregnancy'),
            ),
    );
  }
}
