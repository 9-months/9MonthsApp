import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class PregnancyTrackerPage extends StatefulWidget {
  const PregnancyTrackerPage({Key? key}) : super(key: key);

  @override
  _PregnancyTrackerPageState createState() => _PregnancyTrackerPageState();
}

class _PregnancyTrackerPageState extends State<PregnancyTrackerPage> {
  bool isLoading = true;
  Map<String, dynamic>? pregnancyData;
  String? error;

  @override
  void initState() {
    super.initState();
    fetchPregnancyData();
  }

  Future<void> fetchPregnancyData() async {
    try {
      final response = await http.get(
        Uri.parse('http://10.0.2.2:3000/pregnancy/user123'),
      );

      setState(() {
        isLoading = false;
        if (response.statusCode == 200) {
          pregnancyData = json.decode(response.body);
        } else {
          error = 'Failed to load pregnancy data';
        }
      });
    } catch (e) {
      setState(() {
        isLoading = false;
        error = 'Error connecting to server';
      });
    }
  }

  Future<void> createPregnancyData() async {
    try {
      setState(() {
        isLoading = true;
        error = null;
      });

      final response = await http.post(
        Uri.parse('http://10.0.2.2:3000/pregnancy'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'userId': 'user123',
          'lastPeriodDate': DateTime.now().subtract(Duration(days: 30)).toIso8601String(),
        }),
      );

      setState(() {
        isLoading = false;
        if (response.statusCode == 201) {
          pregnancyData = json.decode(response.body);
        } else {
          error = 'Failed to create pregnancy data';
        }
      });
    } catch (e) {
      setState(() {
        isLoading = false;
        error = 'Error connecting to server';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Pregnancy Tracker'),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: fetchPregnancyData,
          ),
        ],
      ),
      body: isLoading 
        ? Center(child: CircularProgressIndicator())
        : error != null
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(error!),
                  ElevatedButton(
                    onPressed: createPregnancyData,
                    child: Text('Create New Pregnancy Data'),
                  ),
                ],
              ),
            )
          : _buildPregnancyContent(),
    );
  }

  Widget _buildPregnancyContent() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildProgressCard(),
          SizedBox(height: 16),
          _buildBabySizeCard(),
          SizedBox(height: 16),
          _buildTipsCard(),
        ],
      ),
    );
  }

  Widget _buildProgressCard() {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Pregnancy Progress',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            SizedBox(height: 16),
            LinearProgressIndicator(
              value: (pregnancyData?['currentWeek'] ?? 0) / 40,
              backgroundColor: Colors.grey[200],
              valueColor: AlwaysStoppedAnimation<Color>(Colors.pink),
            ),
            SizedBox(height: 8),
            Text(
              'Week ${pregnancyData?['currentWeek']} of 40',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            SizedBox(height: 8),
            Text(
              'Due Date: ${pregnancyData?['dueDate']?.toString().split('T')[0]}',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBabySizeCard() {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Baby Size',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            SizedBox(height: 16),
            Row(
              children: [
                Icon(Icons.child_care, size: 24),
                SizedBox(width: 8),
                Text(
                  'Your baby is the size of a ${pregnancyData?['babySize']}',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTipsCard() {
    List<String> tips = List<String>.from(pregnancyData?['weeklyTips'] ?? []);
    
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Weekly Tips',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            SizedBox(height: 16),
            ...tips.map((tip) => Padding(
              padding: EdgeInsets.symmetric(vertical: 4),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.check_circle, size: 20, color: Colors.green),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(tip),
                  ),
                ],
              ),
            )).toList(),
          ],
        ),
      ),
    );
  }
}