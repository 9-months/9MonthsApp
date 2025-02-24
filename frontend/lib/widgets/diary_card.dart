import 'package:flutter/material.dart';
import '../models/diary_model.dart';

class DiaryCard extends StatelessWidget {
  final DiaryEntry diary;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const DiaryCard({
    Key? key,
    required this.diary,
    required this.onEdit,
    required this.onDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      child: ListTile(
        title: Text(diary.description),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: Icon(Icons.edit),
              onPressed: onEdit,
            ),
            IconButton(
              icon: Icon(Icons.delete),
              onPressed: onDelete,
            ),
          ],
        ),
      ),
    );
  }
}
