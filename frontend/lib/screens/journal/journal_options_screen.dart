/*
 File: journal_options_screen.dart
 Purpose: Screen for users to choose between writing a diary entry or tracking their mood
 Created Date: CCS-50 23-02-2025
 Author: Melissa Joanne

 last modified: 24-02-2025 | Melissa | CCS-50 Journal options screen
*/

import 'package:flutter/material.dart';

class JournalOptionsScreen extends StatelessWidget {
  const JournalOptionsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'My Journal',
          style: Theme.of(context).appBarTheme.titleTextStyle,
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                'Welcome back!',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              SizedBox(height: 8),
              Text(
                'How would you like to express yourself today?',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              SizedBox(height: 32),
              _buildJournalOption(
                context: context,
                title: 'Write a Diary Entry',
                description: 'Express your thoughts and feelings freely',
                icon: Icons.edit_note,
                onTap: () => Navigator.pushNamed(context, '/journal/diary'),
              ),
              SizedBox(height: 16),
              _buildJournalOption(
                context: context,
                title: 'Track Your Mood',
                description: 'Record and monitor your emotional well-being',
                icon: Icons.mood,
                onTap: () => Navigator.pushNamed(context, '/journal/mood'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildJournalOption({
    required BuildContext context,
    required String title,
    required String description,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  size: 28,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      description,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right,
                color: Theme.of(context).colorScheme.primary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
