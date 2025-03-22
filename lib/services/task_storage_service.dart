import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/task_model.dart';

class TaskStorageService {
  static const String _tasksKey = 'tasks';
  static const String _firstRunKey = 'first_run';

  // Save tasks to local storage
  static Future<void> saveTasks(List<Task> tasks) async {
    final prefs = await SharedPreferences.getInstance();
    final tasksJson = tasks.map((task) => jsonEncode(task.toJson())).toList();
    await prefs.setStringList(_tasksKey, tasksJson);
  }

  // Load tasks from local storage
  static Future<List<Task>> loadTasks() async {
    final prefs = await SharedPreferences.getInstance();

    // Check if it's the first run of the app
    final isFirstRun = prefs.getBool(_firstRunKey) ?? true;

    // Not first run - load saved tasks
    final tasksJson = prefs.getStringList(_tasksKey) ?? [];

    if (tasksJson.isEmpty) {
      return [];
    }

    return tasksJson
        .map((taskJson) => Task.fromJson(jsonDecode(taskJson)))
        .toList();
  }

  // Clear all tasks (for testing or reset functionality)
  static Future<void> clearTasks() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tasksKey);
  }

  // Reset to first run (for testing or reset functionality)
  static Future<void> resetFirstRun() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_firstRunKey, true);
  }
}