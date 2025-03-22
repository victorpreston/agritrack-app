import 'package:agritrack/services/task_notification_service.dart';
import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../tasks/task_detail_screen.dart';
import '../../models/task_model.dart';

class NotificationsScreen extends StatefulWidget {
  final Function(Task)? onTaskUpdated;

  const NotificationsScreen({
    super.key,
    this.onTaskUpdated,
  });

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final NotificationService _notificationService = NotificationService();
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // First, refresh task notifications to ensure we have the latest
      await _notificationService.refreshTaskNotifications();

      // Clean up notifications for completed tasks
      await _notificationService.cleanUpCompletedTaskNotifications();

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading notifications: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: AppTheme.primaryColor,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(
              Icons.refresh,
              size: 24,
              color: AppTheme.primaryColor,
            ),
            onPressed: _loadNotifications,
          ),
          IconButton(
            icon: const Icon(
              Icons.check_circle_outline,
              size: 24,
              color: AppTheme.primaryColor,
            ),
            onPressed: () async {
              // Mark all as read
              await _notificationService.markAllAsRead();

              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('All notifications marked as read'),
                  backgroundColor: AppTheme.primaryColor,
                ),
              );
            },
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppTheme.primaryColor,
          unselectedLabelColor: Colors.grey,
          indicatorColor: AppTheme.primaryColor,
          tabs: const [
            Tab(text: 'All'),
            Tab(text: 'Alerts'),
            Tab(text: 'Updates'),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ValueListenableBuilder<List<NotificationItem>>(
        valueListenable: _notificationService.notificationsNotifier,
        builder: (context, notifications, _) {
          return TabBarView(
            controller: _tabController,
            children: [
              _buildNotificationsList(notifications),
              _buildNotificationsList(notifications.where((n) => n.type == 'alert').toList()),
              _buildNotificationsList(notifications.where((n) => n.type == 'update').toList()),
            ],
          );
        },
      ),
    );
  }

  Widget _buildNotificationsList(List<NotificationItem> notifications) {
    if (notifications.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.notifications_none,
              size: 64,
              color: Colors.grey,
            ),
            const SizedBox(height: 16),
            Text(
              'No notifications yet',
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 16,
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadNotifications,
      child: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: notifications.length,
        separatorBuilder: (context, index) => const Divider(),
        itemBuilder: (context, index) {
          final notification = notifications[index];
          return _buildNotificationItem(notification);
        },
      ),
    );
  }

  Widget _buildNotificationItem(NotificationItem notification) {
    return Dismissible(
      key: Key(notification.id.toString()),
      background: Container(
        color: Colors.red,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 16),
        child: const Icon(
          Icons.delete,
          color: Colors.white,
        ),
      ),
      direction: DismissDirection.endToStart,
      onDismissed: (direction) async {
        // Remove notification
        await _notificationService.removeNotification(notification.id);
      },
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(vertical: 8),
        leading: CircleAvatar(
          backgroundColor: _getNotificationColor(notification.type).withOpacity(0.1),
          child: Icon(
            _getNotificationIcon(notification.type),
            size: 24,
            color: _getNotificationColor(notification.type),
          ),
        ),
        title: Text(
          notification.title,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: notification.isRead ? Colors.grey : Colors.black,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              notification.message,
              style: TextStyle(
                color: notification.isRead ? Colors.grey.shade500 : Colors.grey.shade700,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              notification.time,
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 12,
              ),
            ),
          ],
        ),
        trailing: notification.isRead
            ? null
            : Container(
          width: 10,
          height: 10,
          decoration: const BoxDecoration(
            color: AppTheme.primaryColor,
            shape: BoxShape.circle,
          ),
        ),
        onTap: () async {
          // Mark as read
          await _notificationService.markAsRead(notification.id);

          // Handle notification based on task
          if (notification.task != null) {
            _navigateToTaskDetail(notification.task!);
          }
        },
      ),
    );
  }

  void _navigateToTaskDetail(Task task) async {
    final updatedTask = await Navigator.push<Task>(
      context,
      MaterialPageRoute(
        builder: (context) => TaskDetailScreen(
          task: task,
          onTaskUpdated: (Task updated) {
            // This will be called when the task is updated in the detail screen
            if (widget.onTaskUpdated != null) {
              widget.onTaskUpdated!(updated);
            }
            // Refresh notifications after task update
            _loadNotifications();
          },
        ),
      ),
    );

    // Refresh after returning from task detail screen
    if (updatedTask != null) {
      _loadNotifications();
    }
  }

  Color _getNotificationColor(String type) {
    switch (type) {
      case 'alert':
        return Colors.red;
      case 'update':
        return AppTheme.primaryColor;
      default:
        return Colors.blue;
    }
  }

  IconData _getNotificationIcon(String type) {
    switch (type) {
      case 'alert':
        return Icons.warning_amber_rounded;
      case 'update':
        return Icons.info_outline;
      default:
        return Icons.notifications_active_outlined;
    }
  }
}