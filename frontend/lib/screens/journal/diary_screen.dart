import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/diary_model.dart';
import '../../providers/auth_provider.dart';
import '../../services/diary_service.dart';
import '../../widgets/diary_card.dart';

class DiaryScreen extends StatefulWidget {
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
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final diaries = await _diaryService.getDiaries(_userId);
      setState(() {
        _diaries = diaries;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _createDiary(String description) async {
    try {
      final newDiary = await _diaryService.createDiary(_userId, description);
      setState(() {
        _diaries.add(newDiary);
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
      });
    }
  }

  Future<void> _updateDiary(String diaryId, String description) async {
    try {
      final updatedDiary =
          await _diaryService.updateDiary(_userId, diaryId, description);
      setState(() {
        final index = _diaries.indexWhere((diary) => diary.diaryId == diaryId);
        if (index != -1) {
          _diaries[index] = updatedDiary;
        }
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
      });
    }
  }

  Future<void> _deleteDiary(String diaryId) async {
    try {
      await _diaryService.deleteDiary(_userId, diaryId);
      setState(() {
        _diaries.removeWhere((diary) => diary.diaryId == diaryId);
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Diary'),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? Center(child: Text(_errorMessage!))
              : ListView.builder(
                  itemCount: _diaries.length,
                  itemBuilder: (context, index) {
                    final diary = _diaries[index];
                    return DiaryCard(
                      diary: diary,
                      onEdit: () {
                        // Handle update
                      },
                      onDelete: () => _deleteDiary(diary.diaryId!),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Handle create
        },
        child: Icon(Icons.add),
      ),
    );
  }
}
