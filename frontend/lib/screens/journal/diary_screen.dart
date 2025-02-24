import 'package:flutter/material.dart';

class DiaryScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'My Diary',
          style: Theme.of(context).appBarTheme.titleTextStyle,
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Your Entries',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              SizedBox(height: 8),
              Text(
                'Capture your journey, one day at a time',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              SizedBox(height: 24),
              Expanded(
                child: ListView.builder(
                  itemCount: 0, // Replace with actual diary entries count
                  itemBuilder: (context, index) {
                    return Card(
                      margin: EdgeInsets.only(bottom: 16),
                      child: ListTile(
                        contentPadding: EdgeInsets.all(16),
                        title: Text(
                          'Entry Title', // Replace with actual entry title
                          style:
                              Theme.of(context).textTheme.bodyLarge?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(height: 8),
                            Text(
                              'Entry preview...', // Replace with actual entry preview
                              style: Theme.of(context).textTheme.bodyMedium,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            SizedBox(height: 8),
                            Text(
                              'Date', // Replace with actual date
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(
                                    color:
                                        Theme.of(context).colorScheme.primary,
                                  ),
                            ),
                          ],
                        ),
                        onTap: () {
                          // Handle entry tap
                        },
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Navigate to create new entry screen
        },
        child: Icon(Icons.add),
      ),
    );
  }
}
