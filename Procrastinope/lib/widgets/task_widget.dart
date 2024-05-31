import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/task.dart';
import '../providers/task_provider.dart';

class TaskWidget extends StatelessWidget {
  final Task task;

  TaskWidget({required this.task});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPress: () {
        _showDeleteDialog(context, task);
      },
      child: Dismissible(
        key: Key(task.id),
        direction: DismissDirection.endToStart,
        onDismissed: (direction) {
          Provider.of<TaskProvider>(context, listen: false).deleteTask(task.id);
        },
        background: Container(color: Colors.red),
        child: ListTile(
          title: Text(task.name, style: TextStyle(color: Colors.white)),
          subtitle: Text(
            'Category: ${task.category}, Priority: ${task.priority}',
            style: TextStyle(color: Colors.white70),
          ),
          trailing: Checkbox(
            value: task.completed,
            onChanged: (bool? value) {
              if (value != null && value) {
                Provider.of<TaskProvider>(context, listen: false).markTaskAsCompleted(task.id);
              }
            },
          ),
        ),
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, Task task) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Delete Task'),
          content: Text('Are you sure you want to delete this task?'),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Delete'),
              onPressed: () {
                Provider.of<TaskProvider>(context, listen: false).deleteTask(task.id);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
