/*
 File: Diary_screen.dart
 Purpose: Screen for users to view, add, edit, and delete diary entries
 Created Date: CCS-50 23-02-2025
 Author: Melissa Joanne

 last modified: 24-02-2025 | Melissa | CCS-50 Diary screen
*/
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
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
  String? _token;
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
    _token = authProvider.token; // Get token from authProvider
    _diaryService = DiaryService();
    await _fetchDiaries();
  }

  Future<void> _fetchDiaries() async {
    if (_token == null) {
      setState(() {
        _errorMessage = 'Authentication required. Please login again.';
        _isLoading = false;
      });
      return;
    }

    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      final diaries = await _diaryService.getDiaries(_userId, _token!);

      // Sort diaries by date (newest first)
      diaries.sort((a, b) => b.date.compareTo(a.date));

      setState(() {
        _diaries = diaries;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        if (e.toString().contains('user not found') ||
            e.toString().contains('User not found')) {
          _diaries = []; // Ensure diaries is empty
          _errorMessage = null;
        } else {
          _errorMessage = e.toString();
        }
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Journal'),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () => _showSortingOptions(),
            tooltip: 'Sort entries',
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _fetchDiaries,
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _errorMessage != null
                ? _buildErrorView()
                : _buildDiaryList(),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showDiaryDialog(),
        icon: const Icon(Icons.add),
        label: const Text('New Entry'),
        tooltip: 'Add new journal entry',
      ),
    );
  }

  void _showSortingOptions() {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'Sort Entries',
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
            ListTile(
              leading: const Icon(Icons.arrow_downward),
              title: const Text('Newest first'),
              onTap: () {
                setState(() {
                  _diaries.sort((a, b) => b.date.compareTo(a.date));
                });
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.arrow_upward),
              title: const Text('Oldest first'),
              onTap: () {
                setState(() {
                  _diaries.sort((a, b) => a.date.compareTo(b.date));
                });
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.error_outline,
            size: 60,
            color: Colors.red,
          ),
          const SizedBox(height: 16),
          Text(
            _errorMessage ?? 'Something went wrong',
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.red),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: _fetchDiaries,
            icon: const Icon(Icons.refresh),
            label: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildDiaryList() {
    if (_diaries.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.book_outlined,
              size: 80,
              color: Colors.grey,
            ),
            const SizedBox(height: 16),
            const Text(
              'Your journal is empty',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Tap the + button to add your first entry',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: _diaries.length,
      itemBuilder: (context, index) {
        final diary = _diaries[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: DiaryCard(
            diary: diary,
            onEdit: () => _showDiaryDialog(diary: diary),
            onDelete: () => _showDeleteConfirmation(diary),
          ),
        );
      },
    );
  }

  Future<void> _showDiaryDialog({DiaryEntry? diary}) async {
    if (_token == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Authentication required. Please login again.')),
      );
      return;
    }

    final textController = TextEditingController(text: diary?.description);
    final currentDate = diary?.date ?? DateTime.now();
    DateTime selectedDate = currentDate;
    TimeOfDay selectedTime = TimeOfDay.fromDateTime(currentDate);

    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text(diary == null ? 'New Entry' : 'Edit Entry'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Date picker
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.calendar_today),
                  title: Text(
                    'Date: ${DateFormat('MMM dd, yyyy').format(selectedDate)}',
                  ),
                  onTap: () async {
                    final pickedDate = await showDatePicker(
                      context: context,
                      initialDate: selectedDate,
                      firstDate: DateTime(2020),
                      lastDate: DateTime.now().add(const Duration(days: 1)),
                    );
                    if (pickedDate != null) {
                      setState(() {
                        selectedDate = DateTime(
                          pickedDate.year,
                          pickedDate.month,
                          pickedDate.day,
                          selectedTime.hour,
                          selectedTime.minute,
                        );
                      });
                    }
                  },
                ),

                // Time picker
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.access_time),
                  title: Text(
                    'Time: ${selectedTime.format(context)}',
                  ),
                  onTap: () async {
                    final pickedTime = await showTimePicker(
                      context: context,
                      initialTime: selectedTime,
                    );
                    if (pickedTime != null) {
                      setState(() {
                        selectedTime = pickedTime;
                        selectedDate = DateTime(
                          selectedDate.year,
                          selectedDate.month,
                          selectedDate.day,
                          pickedTime.hour,
                          pickedTime.minute,
                        );
                      });
                    }
                  },
                ),

                const SizedBox(height: 16),
                const Text(
                  'Your thoughts:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: textController,
                  maxLines: 6,
                  decoration: const InputDecoration(
                    hintText: 'Write your thoughts...',
                    border: OutlineInputBorder(),
                    filled: true,
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (textController.text.trim().isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('Please write something before saving')),
                  );
                  return;
                }
                Navigator.pop(context, {
                  'text': textController.text,
                  'date': selectedDate,
                });
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );

    if (result != null && result['text'].trim().isNotEmpty) {
      try {
        setState(() => _isLoading = true);
        if (diary == null) {
          await _diaryService.createDiaryWithDate(
            _userId,
            result['text'],
            result['date'],
            _token!, // Pass the token
          );

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Entry created successfully'),
              duration: Duration(seconds: 2),
            ),
          );
        } else {
          await _diaryService.updateDiaryWithDate(
            _userId,
            diary.diaryId!,
            result['text'],
            result['date'],
            _token!, // Pass the token
          );

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Entry updated successfully'),
              duration: Duration(seconds: 2),
            ),
          );
        }
        await _fetchDiaries();
      } catch (e) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );
      }
    }
  }

  Future<void> _showDeleteConfirmation(DiaryEntry diary) async {
    if (_token == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Authentication required. Please login again.')),
      );
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Entry'),
        content: const Text(
            'Are you sure you want to delete this entry? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        setState(() => _isLoading = true);
        await _diaryService.deleteDiary(
            _userId, diary.diaryId!, _token!); // Pass the token

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Entry deleted'),
            duration: Duration(seconds: 2),
          ),
        );

        await _fetchDiaries();
      } catch (e) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );
      }
    }
  }
}
