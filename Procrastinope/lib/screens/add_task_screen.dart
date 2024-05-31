import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/task.dart';
import '../providers/task_provider.dart';
import 'package:uuid/uuid.dart';
import 'package:intl/intl.dart';

class AddTaskScreen extends StatefulWidget {
  @override
  _AddTaskScreenState createState() => _AddTaskScreenState();
}

class _AddTaskScreenState extends State<AddTaskScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _categoryController = TextEditingController();
  final _expController = TextEditingController();
  DateTime? _selectedDateTime;
  String _selectedPriority = 'Medium';  // Default priority

  void _submitData() {
    if (_selectedDateTime == null) {
      return;
    }

    if (_formKey.currentState!.validate()) {
      final taskProvider = Provider.of<TaskProvider>(context, listen: false);
      final task = Task(
        id: Uuid().v4(),
        name: _nameController.text,
        category: _categoryController.text,
        deadline: _selectedDateTime!,
        priority: _selectedPriority,
        exp: int.parse(_expController.text),
      );

      taskProvider.addTask(task);
      Navigator.of(context).pop();
    }
  }

  void _presentDateTimePicker() async {
    final pickedDateTime = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2101),
    );

    if (pickedDateTime != null) {
      final pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
      );

      if (pickedTime != null) {
        setState(() {
          _selectedDateTime = DateTime(
            pickedDateTime.year,
            pickedDateTime.month,
            pickedDateTime.day,
            pickedTime.hour,
            pickedTime.minute,
          );
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(16.0),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            TextFormField(
              decoration: InputDecoration(labelText: 'Name'),
              controller: _nameController,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a task name';
                }
                return null;
              },
            ),
            TextFormField(
              decoration: InputDecoration(labelText: 'Category'),
              controller: _categoryController,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a category';
                }
                return null;
              },
            ),
            TextFormField(
              decoration: InputDecoration(labelText: 'EXP'),
              controller: _expController,
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter the EXP value';
                }
                if (int.tryParse(value) == null) {
                  return 'Please enter a valid number';
                }
                return null;
              },
            ),
            SizedBox(height: 20),
            DropdownButtonFormField<String>(
              decoration: InputDecoration(labelText: 'Priority'),
              value: _selectedPriority,
              items: ['Lowest', 'Low', 'Medium', 'High', 'Highest']
                  .map((priority) => DropdownMenuItem(
                child: Text(priority),
                value: priority,
              ))
                  .toList(),
              onChanged: (value) {
                setState(() {
                  _selectedPriority = value!;
                });
              },
            ),
            SizedBox(height: 20),
            Row(
              children: <Widget>[
                Expanded(
                  child: Text(
                    _selectedDateTime == null
                        ? 'No Date & Time Chosen!'
                        : 'Picked Date & Time: ${DateFormat.yMd().add_jm().format(_selectedDateTime!)}',
                  ),
                ),
                TextButton(
                  onPressed: _presentDateTimePicker,
                  child: const Text(
                    'Choose Date & Time',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _submitData,
              child: Text('Add Task'),
            ),
          ],
        ),
      ),
    );
  }
}
