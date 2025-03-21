/*
 File: Diary_screen.dart
 Purpose: Screen for users to view, add, edit, and delete diary entries
 Created Date: CCS-50 23-02-2025
 Author: Melissa Joanne

 last modified: 24-02-2025 | Melissa | CCS-50 Diary screen
*/
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/diary_model.dart';
import '../../providers/auth_provider.dart';
import '../../services/diary_service.dart';
import '../../widgets/diary_card.dart';

class DiaryScreen extends StatefulWidget {
  const DiaryScreen({super.key});

  @override
  _DiaryScreenState createState() => _DiaryScreenState();
}

class _DiaryScreenState extends State<DiaryScreen> {
  late DiaryService _diaryService;
  late String _userId;
  List<DiaryEntry> _diaries = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _initialize();
  }

  void _initialize() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    _userId = authProvider.user?.uid ?? '';
    _diaryService = DiaryService();
    await _fetchDiaries();
  }

  Future<void> _fetchDiaries() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      final diaries = await _diaryService.getDiaries(_userId);
      setState(() {
        _diaries = diaries;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Diary'),
        elevation: 0,
      ),
      body: RefreshIndicator(
        onRefresh: _fetchDiaries,
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _errorMessage != null
                ? _buildErrorView()
                : _buildDiaryList(),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showDiaryDialog(),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildErrorView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            _errorMessage ?? 'Something went wrong',
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.red),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _fetchDiaries,
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildDiaryList() {
    if (_diaries.isEmpty) {
      return const Center(
        child: Text('No diary entries yet. Tap + to add one!'),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(8),
      itemCount: _diaries.length,
      itemBuilder: (context, index) {
        final diary = _diaries[index];
        return DiaryCard(
          diary: diary,
          onEdit: () => _showDiaryDialog(diary: diary),
          onDelete: () => _showDeleteConfirmation(diary),
        );
      },
    );
  }

  Future<void> _showDiaryDialog({DiaryEntry? diary}) async {
    final textController = TextEditingController(text: diary?.description);

    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(diary == null ? 'New Entry' : 'Edit Entry'),
        content: TextField(
          controller: textController,
          maxLines: 4,
          decoration: const InputDecoration(
            hintText: 'Write your thoughts...',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, textController.text),
            child: const Text('Save'),
          ),
        ],
      ),
    );

    if (result != null && result.trim().isNotEmpty) {
      try {
        setState(() => _isLoading = true);
        if (diary == null) {
          await _diaryService.createDiary(_userId, result);
        } else {
          await _diaryService.updateDiary(_userId, diary.diaryId!, result);
        }
        await _fetchDiaries();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );
      }
    }
  }

  Future<void> _showDeleteConfirmation(DiaryEntry diary) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Entry'),
        content: const Text('Are you sure you want to delete this entry?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        setState(() => _isLoading = true);
        await _diaryService.deleteDiary(_userId, diary.diaryId!);
        await _fetchDiaries();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );
      }
    }
  }
}
