/*
 File: mood_tracking.dart
 Purpose: moodtracking dashboard in the journal page
 Created Date: CCS-48 11-02-2025
 Author: Dinith Perera

 last modified: 11-02-2025 | Dinith | CCS-49 Mood tracking 
*/

import 'package:flutter/material.dart';
import '../../models/mood_model.dart';
import '../../services/mood_tracking_service.dart';

class MoodTrackingScreen extends StatefulWidget {
  final String userId;

  const MoodTrackingScreen({Key? key, required this.userId}) : super(key: key);

  @override
  _MoodTrackingScreenState createState() => _MoodTrackingScreenState();
}

class _MoodTrackingScreenState extends State<MoodTrackingScreen> {
  final MoodTrackingService _moodService = MoodTrackingService();
  final TextEditingController _noteController = TextEditingController();
  String? _selectedMood;
  List<MoodModel> _moods = [];
  bool _isLoading = false;

  final List<Map<String, dynamic>> _moodOptions = [
    {'mood': 'happy', 'emoji': '😊'},
    {'mood': 'sad', 'emoji': '😢'},
    {'mood': 'anxious', 'emoji': '😰'},
    {'mood': 'calm', 'emoji': '😌'},
    {'mood': 'stressed', 'emoji': '😫'},
    {'mood': 'excited', 'emoji': '🤩'},
  ];

  @override
  void initState() {
    super.initState();
    _loadMoods();
  }

  Future<void> _loadMoods() async {
    setState(() => _isLoading = true);
    try {
      _moods = await _moodService.getAllMoods(widget.userId);
      setState(() {});
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading moods: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _saveMood() async {
    if (_selectedMood == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a mood')),
      );
      return;
    }

    final newMood = MoodModel(
      userId: widget.userId,
      mood: _selectedMood!,
      note: _noteController.text,
      date: DateTime.now(),
    );

    try {
      await _moodService.createMood(newMood);
      _noteController.clear();
      setState(() => _selectedMood = null);
      _loadMoods();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error saving mood: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mood Tracking')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildMoodSelector(),
                    const SizedBox(height: 20),
                    _buildNoteInput(),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: _saveMood,
                      child: const Text('Save Mood'),
                    ),
                    const SizedBox(height: 20),
                    _buildMoodHistory(),
                  ],
                ),
              ),
            ),
    );
  }

    Widget _buildMoodSelector() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: _moodOptions.map((option) {
          final bool isSelected = _selectedMood == option['mood'];
          return Padding(
            padding: const EdgeInsets.only(right: 10),
            child: GestureDetector(
              onTap: () => setState(() => _selectedMood = option['mood']),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isSelected ? Colors.blue.withOpacity(0.2) : Colors.grey[200],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      option['emoji'],
                      style: const TextStyle(fontSize: 32),
                    ),
                    Text(option['mood']),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildNoteInput() {
    return TextField(
      controller: _noteController,
      maxLength: 500,
      maxLines: 3,
      decoration: const InputDecoration(
        labelText: 'How are you feeling?',
        border: OutlineInputBorder(),
      ),
    );
  }

  Widget _buildMoodHistory() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Mood History',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _moods.length,
          itemBuilder: (context, index) {
            final mood = _moods[index];
            return Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                leading: Text(
                  _moodOptions
                      .firstWhere((m) => m['mood'] == mood.mood)['emoji'],
                  style: const TextStyle(fontSize: 24),
                ),
                title: Text(mood.mood),
                subtitle: Text(mood.note),
                trailing: Text(
                  '${mood.date.day}/${mood.date.month}/${mood.date.year}',
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }
}