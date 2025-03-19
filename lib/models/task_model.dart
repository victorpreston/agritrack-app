import 'package:flutter/material.dart';

enum TaskPriority { low, medium, high }

class Task {
  final String id;
  final String title;
  final String description;
  final DateTime dueDate;
  final TaskPriority priority;
  bool isCompleted;
  final String category;

  Task({
    required this.id,
    required this.title,
    required this.description,
    required this.dueDate,
    required this.priority,
    this.isCompleted = false,
    required this.category,
  });

  // Convert priority to color
  Color get priorityColor {
    switch (priority) {
      case TaskPriority.low:
        return Colors.green;
      case TaskPriority.medium:
        return Colors.orange;
      case TaskPriority.high:
        return Colors.red;
      default:
        return Colors.green;
    }
  }

  // Convert priority to string
  String get priorityText {
    switch (priority) {
      case TaskPriority.low:
        return 'Low';
      case TaskPriority.medium:
        return 'Medium';
      case TaskPriority.high:
        return 'High';
      default:
        return 'Low';
    }
  }

  // Check if task is overdue
  bool get isOverdue {
    return !isCompleted && dueDate.isBefore(DateTime.now());
  }

  // Create a copy of the task with updated fields
  Task copyWith({
    String? id,
    String? title,
    String? description,
    DateTime? dueDate,
    TaskPriority? priority,
    bool? isCompleted,
    String? category,
  }) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      dueDate: dueDate ?? this.dueDate,
      priority: priority ?? this.priority,
      isCompleted: isCompleted ?? this.isCompleted,
      category: category ?? this.category,
    );
  }
}

// Sample task categories
final List<String> taskCategories = [
  'Planting',
  'Irrigation',
  'Fertilization',
  'Pest Control',
  'Harvesting',
  'Maintenance',
  'Other',
];

// Sample tasks data
List<Task> sampleTasks = [
  Task(
    id: '1',
    title: 'Apply Fertilizer',
    description: 'Apply NPK fertilizer to corn field in sector A',
    dueDate: DateTime.now().add(const Duration(days: 1)),
    priority: TaskPriority.high,
    category: 'Fertilization',
  ),
  Task(
    id: '2',
    title: 'Check Irrigation System',
    description: 'Inspect irrigation system in sector B for leaks',
    dueDate: DateTime.now().add(const Duration(days: 2)),
    priority: TaskPriority.medium,
    category: 'Irrigation',
  ),
  Task(
    id: '3',
    title: 'Plant Soybeans',
    description: 'Plant soybeans in the eastern field',
    dueDate: DateTime.now().add(const Duration(days: 5)),
    priority: TaskPriority.medium,
    category: 'Planting',
  ),
  Task(
    id: '4',
    title: 'Repair Tractor',
    description: 'Schedule maintenance for the John Deere tractor',
    dueDate: DateTime.now().add(const Duration(days: 7)),
    priority: TaskPriority.low,
    category: 'Maintenance',
  ),
  Task(
    id: '5',
    title: 'Spray Pesticide',
    description: 'Apply organic pesticide to tomato plants',
    dueDate: DateTime.now().subtract(const Duration(days: 1)),
    priority: TaskPriority.high,
    category: 'Pest Control',
  ),
  Task(
    id: '6',
    title: 'Harvest Corn',
    description: 'Begin harvesting corn in the northern field',
    dueDate: DateTime.now().add(const Duration(days: 14)),
    priority: TaskPriority.high,
    category: 'Harvesting',
    isCompleted: true,
  ),
];