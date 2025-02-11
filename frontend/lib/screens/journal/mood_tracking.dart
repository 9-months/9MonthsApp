/*
 File: mood_tracking.dart
 Purpose: moodtracking dashboard in the journal page
 Created Date: CCS-48 11-02-2025
 Author: Dinith Perera

 last modified: 12-02-2025 | Dinith | CCS-49 delete and update mood entries
*/

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../models/mood_model.dart';
import '../../services/mood_tracking_service.dart';

class MoodTrackingScreen extends StatefulWidget {
  const MoodTrackingScreen({Key? key}) : super(key: key);

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

  String? _getUserId() {
    return Provider.of<AuthProvider>(context, listen: false).user?.uid;
  }

  // load all moods for the current user
  Future<void> _loadMoods() async {
    final userId = _getUserId();
    if (userId == null) return;

    setState(() => _isLoading = true);
    try {
      _moods = await _moodService.getAllMoods(userId);
      setState(() {});
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading moods: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  // save a new mood entry
  Future<void> _saveMood() async {
    final userId = _getUserId();
    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User not authenticated')),
      );
      return;
    }

    if (_selectedMood == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a mood')),
      );
      return;
    }

    final newMood = MoodModel(
      userId: userId,
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

  // update an existing mood entry
  Future<void> _updateMood(MoodModel mood) async {
    final userId = _getUserId();
    if (userId == null || mood.id == null) return;

    try {
      final updatedMood = MoodModel(
        userId: userId,
        mood: _selectedMood ?? mood.mood,
        note: _noteController.text.isEmpty ? mood.note : _noteController.text,
        date: mood.date,
      );

      await _moodService.updateMood(userId, mood.id!, updatedMood);
      _noteController.clear();
      setState(() => _selectedMood = null);
      _loadMoods();
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Mood updated successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error updating mood: $e')),
      );
    }
  }

  // delete an existing mood entry
  Future<void> _deleteMood(String moodId) async {
    final userId = _getUserId();
    if (userId == null) return;

    try {
      await _moodService.deleteMood(userId, moodId);
      _loadMoods();
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Mood deleted successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error deleting mood: $e')),
      );
    }
  }


  // screen layout
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
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '${mood.date.day}/${mood.date.month}/${mood.date.year}',
                  ),
                  IconButton(
                    icon: const Icon(Icons.edit),
                    onPressed: () => _showEditDialog(mood),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () => _showDeleteDialog(mood),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    ],
  );
}

void _showEditDialog(MoodModel mood) {
  _selectedMood = mood.mood;
  _noteController.text = mood.note;
  
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Edit Mood'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildMoodSelector(),
          const SizedBox(height: 16),
          _buildNoteInput(),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () {
            _updateMood(mood);
            Navigator.pop(context);
          },
          child: const Text('Save'),
        ),
      ],
    ),
  );
}

  void _showDeleteDialog(MoodModel mood) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Mood'),
        content: const Text('Are you sure you want to delete this mood entry?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              if (mood.id != null) {
                _deleteMood(mood.id!);
              }
              Navigator.pop(context);
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }
}