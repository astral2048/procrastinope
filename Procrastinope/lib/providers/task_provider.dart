import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/task.dart';

class TaskProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  User? _currentUser;
  List<Task> _tasks = [];
  int _totalExp = 0;
  int _level = 1;

  List<Task> get tasks => _tasks;
  int get totalExp => _totalExp;
  int get level => _level;

  TaskProvider() {
    _currentUser = FirebaseAuth.instance.currentUser;
    if (_currentUser != null) {
      initializeUserData();
    }
  }

  Future<void> initializeUserData() async {
    _currentUser = FirebaseAuth.instance.currentUser;
    if (_currentUser != null) {
      await fetchUserStats();
      await fetchTasks();
    }
  }

  Future<void> fetchTasks() async {
    if (_currentUser == null) return;
    final snapshot = await _firestore
        .collection('users')
        .doc(_currentUser!.uid)
        .collection('tasks')
        .get();
    _tasks = snapshot.docs.map((doc) => Task.fromMap(doc.data())).toList();
    notifyListeners();
  }

  Future<void> fetchUserStats() async {
    if (_currentUser == null) return;
    final userSnapshot = await _firestore
        .collection('users')
        .doc(_currentUser!.uid)
        .get();
    if (userSnapshot.exists) {
      final userData = userSnapshot.data()!;
      _totalExp = userData['exp'] ?? 0;
      _level = userData['level'] ?? 1;
      notifyListeners();
    }
  }

  Future<void> addTask(Task task) async {
    if (_currentUser == null) return;
    await _firestore
        .collection('users')
        .doc(_currentUser!.uid)
        .collection('tasks')
        .doc(task.id)
        .set(task.toMap());
    _tasks.add(task);
    notifyListeners();
  }

  Future<void> markTaskAsCompleted(String taskId) async {
    if (_currentUser == null) return;
    final taskIndex = _tasks.indexWhere((task) => task.id == taskId);
    if (taskIndex != -1) {
      _totalExp += _tasks[taskIndex].exp;
      await _firestore
          .collection('users')
          .doc(_currentUser!.uid)
          .collection('tasks')
          .doc(taskId)
          .delete();
      _tasks.removeAt(taskIndex);
      _calculateExpAndLevel();
      notifyListeners();
      await _updateUserStats();
    }
  }

  Future<void> unfinishedTask(String taskId) async {
    if (_currentUser == null) return;
    final taskIndex = _tasks.indexWhere((task) => task.id == taskId);
    if (taskIndex != -1) {
      await _firestore
          .collection('users')
          .doc(_currentUser!.uid)
          .collection('tasks')
          .doc(taskId)
          .delete();
      _tasks.removeAt(taskIndex);
      _calculateExpAndLevel();
      notifyListeners();
      await _updateUserStats();
    }
  }

  Future<void> deleteTask(String taskId) async {
    if (_currentUser == null) return;
    await _firestore
        .collection('users')
        .doc(_currentUser!.uid)
        .collection('tasks')
        .doc(taskId)
        .delete();
    _tasks.removeWhere((task) => task.id == taskId);
    notifyListeners();
  }

  void _calculateExpAndLevel() {
    int expForNextLevel = _level * 100;
    while (_totalExp >= expForNextLevel) {
      _totalExp -= expForNextLevel;
      _level++;
      expForNextLevel = _level * 100;
    }
  }

  Future<void> _updateUserStats() async {
    if (_currentUser == null) return;
    await _firestore
        .collection('users')
        .doc(_currentUser!.uid)
        .update({'exp': _totalExp, 'level': _level});
  }

  void setUserStats(int exp, int level) {
    _totalExp = exp;
    _level = level;
    notifyListeners();
  }

  void resetUserStats() {
    _tasks = [];
    _totalExp = 0;
    _level = 1;
    notifyListeners();
  }
}
