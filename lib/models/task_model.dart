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

  // Convert Task to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'dueDate': dueDate.millisecondsSinceEpoch,
      'priority': priority.index,
      'isCompleted': isCompleted,
      'category': category,
    };
  }

  // Create Task from JSON
  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      dueDate: DateTime.fromMillisecondsSinceEpoch(json['dueDate']),
      priority: TaskPriority.values[json['priority']],
      isCompleted: json['isCompleted'],
      category: json['category'],
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