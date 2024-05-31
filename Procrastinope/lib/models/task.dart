import 'package:cloud_firestore/cloud_firestore.dart';

class Task {
  final String id;
  final String name;
  final String category;
  final DateTime deadline;
  final String priority;  // Changed from int to String
  bool completed;
  final int exp;

  Task({
    required this.id,
    required this.name,
    required this.category,
    required this.deadline,
    required this.priority,
    this.completed = false,
    required this.exp,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'category': category,
      'deadline': deadline,
      'priority': priority,
      'completed': completed,
      'exp': exp,
    };
  }

  factory Task.fromMap(Map<String, dynamic> map) {
    return Task(
      id: map['id'],
      name: map['name'],
      category: map['category'],
      deadline: (map['deadline'] as Timestamp).toDate(),
      priority: map['priority'],  // Changed from int to String
      completed: map['completed'],
      exp: map['exp'],
    );
  }
}
