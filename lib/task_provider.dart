import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'model/taskModel.dart';

class TaskProvider with ChangeNotifier {
  List<Task> _tasks = [];

  List<Task> get tasks => _tasks;

  TaskProvider() {
    loadTasks();
  }

  void addTask(String title) {
    _tasks.add(Task(title: title));
    saveTasks();
    notifyListeners();
  }

  void deleteTask(int index) {
    _tasks.removeAt(index);
    saveTasks();
    notifyListeners();
  }

  void toggleTaskStatus(int index) {
    _tasks[index].isCompleted = !_tasks[index].isCompleted;
    saveTasks();
    notifyListeners();
  }

  Future<void> loadTasks() async {
    final prefs = await SharedPreferences.getInstance();
    final String? tasksString = prefs.getString('tasks');
    if (tasksString != null) {
      final List decodedList = jsonDecode(tasksString);
      _tasks = decodedList.map((task) => Task.fromJson(task)).toList();
      notifyListeners();
    }
  }

  Future<void> saveTasks() async {
    final prefs = await SharedPreferences.getInstance();
    final String tasksString = jsonEncode(_tasks.map((task) => task.toJson()).toList());
    await prefs.setString('tasks', tasksString);
  }
}
