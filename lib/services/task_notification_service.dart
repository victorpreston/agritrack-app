import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/task_model.dart';
import 'task_storage_service.dart';

class NotificationItem {
  final int id;
  final String title;
  final String message;
  final String time;
  final String type; // 'alert', 'update', etc.
  bool isRead;
  final Task? task; // Reference to the original task

  NotificationItem({
    required this.id,
    required this.title,
    required this.message,
    required this.time,
    required this.type,
    this.isRead = false,
    this.task,
  });

  // Convert to JSON for storage
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'message': message,
      'time': time,
      'type': type,
      'isRead': isRead,
      'taskId': task?.id,
    };
  }

  // Create from JSON
  factory NotificationItem.fromJson(Map<String, dynamic> json, {required List<Task> tasks}) {
    // Find the original task if taskId exists
    Task? relatedTask;
    if (json['taskId'] != null) {
      relatedTask = tasks.firstWhere(
            (task) => task.id == json['taskId'],
        orElse: () => null as Task,
      );
    }

    return NotificationItem(
      id: json['id'],
      title: json['title'],
      message: json['message'],
      time: json['time'],
      type: json['type'],
      isRead: json['isRead'] ?? false,
      task: relatedTask,
    );
  }
}

class NotificationService {
  static const String _notificationsKey = 'app_notifications';
  static final NotificationService _instance = NotificationService._internal();

  // Stream controller for broadcasting notification updates
  final ValueNotifier<List<NotificationItem>> notificationsNotifier = ValueNotifier<List<NotificationItem>>([]);

  factory NotificationService() {
    return _instance;
  }

  NotificationService._internal();

  // Initialize the service
  Future<void> initialize() async {
    await loadNotifications();
  }

  // Get the count of unread notifications
  int get unreadCount {
    return notificationsNotifier.value.where((notification) => !notification.isRead).length;
  }

  // Save notifications to shared preferences
  Future<void> saveNotifications() async {
    final prefs = await SharedPreferences.getInstance();
    final notificationsJson = notificationsNotifier.value
        .map((notification) => jsonEncode(notification.toJson()))
        .toList();
    await prefs.setStringList(_notificationsKey, notificationsJson);
  }

  // Load notifications from shared preferences
  Future<void> loadNotifications() async {
    final prefs = await SharedPreferences.getInstance();
    final notificationsJson = prefs.getStringList(_notificationsKey) ?? [];

    // Load tasks to reconnect with stored notifications
    final tasks = await TaskStorageService.loadTasks();

    final notifications = notificationsJson
        .map((json) => NotificationItem.fromJson(jsonDecode(json), tasks: tasks))
        .toList();

    notificationsNotifier.value = notifications;
  }

  // Generate task notifications and only add new ones
  Future<void> refreshTaskNotifications() async {
    // Load tasks
    final tasks = await TaskStorageService.loadTasks();

    // Generate new notifications from tasks
    final newTaskNotifications = generateTaskNotifications(tasks);

    // Get current notifications
    final currentNotifications = List<NotificationItem>.from(notificationsNotifier.value);

    // Only add notifications that don't already exist
    for (final notification in newTaskNotifications) {
      final exists = currentNotifications.any((n) =>
      n.id == notification.id &&
          n.title == notification.title &&
          n.message == notification.message
      );

      if (!exists) {
        currentNotifications.add(notification);
      }
    }

    // Update the notification list and save
    notificationsNotifier.value = currentNotifications;
    await saveNotifications();
  }

  // Mark a notification as read
  Future<void> markAsRead(int notificationId) async {
    final currentNotifications = List<NotificationItem>.from(notificationsNotifier.value);

    for (int i = 0; i < currentNotifications.length; i++) {
      if (currentNotifications[i].id == notificationId) {
        currentNotifications[i].isRead = true;
        break;
      }
    }

    notificationsNotifier.value = currentNotifications;
    await saveNotifications();
  }

  // Mark all notifications as read
  Future<void> markAllAsRead() async {
    final currentNotifications = List<NotificationItem>.from(notificationsNotifier.value);

    for (int i = 0; i < currentNotifications.length; i++) {
      currentNotifications[i].isRead = true;
    }

    notificationsNotifier.value = currentNotifications;
    await saveNotifications();
  }

  // Remove a notification
  Future<void> removeNotification(int notificationId) async {
    final currentNotifications = List<NotificationItem>.from(notificationsNotifier.value);
    currentNotifications.removeWhere((notification) => notification.id == notificationId);

    notificationsNotifier.value = currentNotifications;
    await saveNotifications();
  }

  // Clear all notifications
  Future<void> clearAllNotifications() async {
    notificationsNotifier.value = [];
    await saveNotifications();
  }

  // Remove notifications for completed tasks
  Future<void> cleanUpCompletedTaskNotifications() async {
    final tasks = await TaskStorageService.loadTasks();
    final completedTaskIds = tasks
        .where((task) => task.isCompleted)
        .map((task) => task.id)
        .toSet();

    final currentNotifications = List<NotificationItem>.from(notificationsNotifier.value);
    currentNotifications.removeWhere((notification) =>
    notification.task != null &&
        completedTaskIds.contains(notification.task!.id)
    );

    notificationsNotifier.value = currentNotifications;
    await saveNotifications();
  }

  // Generate notifications based on upcoming and overdue tasks
  List<NotificationItem> generateTaskNotifications(List<Task> tasks) {
    final List<NotificationItem> notifications = [];
    final now = DateTime.now();

    // Process each task
    for (final task in tasks) {
      // Skip completed tasks
      if (task.isCompleted) continue;

      // Check for overdue tasks
      if (task.isOverdue) {
        notifications.add(
          NotificationItem(
            id: int.parse(task.id),
            title: 'Task Overdue: ${task.title}',
            message: 'This task was due on ${DateFormat('MMM d, yyyy').format(task.dueDate)}.',
            time: _getTimeAgo(task.dueDate),
            type: 'alert',
            task: task,
          ),
        );
      }
      // Check for tasks due today
      else if (task.dueDate.year == now.year &&
          task.dueDate.month == now.month &&
          task.dueDate.day == now.day) {
        notifications.add(
          NotificationItem(
            id: int.parse(task.id),
            title: 'Task Due Today: ${task.title}',
            message: 'This task is due today at ${DateFormat('h:mm a').format(task.dueDate)}.',
            time: 'Today',
            type: 'alert',
            task: task,
          ),
        );
      }
      // Check for tasks due tomorrow
      else if (task.dueDate.difference(now).inDays == 1) {
        notifications.add(
          NotificationItem(
            id: int.parse(task.id),
            title: 'Task Due Tomorrow: ${task.title}',
            message: 'This task is due tomorrow at ${DateFormat('h:mm a').format(task.dueDate)}.',
            time: 'Tomorrow',
            type: 'update',
            task: task,
          ),
        );
      }
      // Check for tasks due within the next 3 days
      else if (task.dueDate.difference(now).inDays <= 3 &&
          task.dueDate.difference(now).inDays > 0) {
        notifications.add(
          NotificationItem(
            id: int.parse(task.id),
            title: 'Upcoming Task: ${task.title}',
            message: 'This task is due in ${task.dueDate.difference(now).inDays} days.',
            time: DateFormat('MMM d').format(task.dueDate),
            type: 'update',
            task: task,
          ),
        );
      }

      // For high priority tasks, we might want to add additional notifications
      if (task.priority == TaskPriority.high &&
          task.dueDate.difference(now).inDays <= 5 &&
          !task.isOverdue) {
        notifications.add(
          NotificationItem(
            id: int.parse('${task.id}0'),  // Append 0 to create a different ID
            title: 'High Priority Task: ${task.title}',
            message: 'Remember to complete this high priority task by ${DateFormat('MMM d').format(task.dueDate)}.',
            time: '${task.dueDate.difference(now).inDays} days remaining',
            type: 'alert',
            task: task,
          ),
        );
      }
    }

    // Sort notifications by due date (most urgent first)
    notifications.sort((a, b) {
      if (a.task == null || b.task == null) return 0;
      return a.task!.dueDate.compareTo(b.task!.dueDate);
    });

    return notifications;
  }

  // Helper method to format time ago
  String _getTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 7) {
      return DateFormat('MMM d').format(dateTime);
    } else if (difference.inDays > 1) {
      return '${difference.inDays} days ago';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inHours >= 1) {
      return '${difference.inHours} hours ago';
    } else if (difference.inMinutes >= 1) {
      return '${difference.inMinutes} minutes ago';
    } else {
      return 'Just now';
    }
  }
}