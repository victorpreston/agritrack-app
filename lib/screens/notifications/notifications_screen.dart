import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../treatments/treatment_shop_screen.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
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
              Icons.check_circle_outline, // Flutter icon replacement
              size: 24,
              color: AppTheme.primaryColor,
            ),
            onPressed: () {
              // Mark all as read
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
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildNotificationsList(allNotifications),
          _buildNotificationsList(allNotifications.where((n) => n.type == 'alert').toList()),
          _buildNotificationsList(allNotifications.where((n) => n.type == 'update').toList()),
        ],
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
              Icons.notifications_none, // Flutter icon replacement
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

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: notifications.length,
      separatorBuilder: (context, index) => const Divider(),
      itemBuilder: (context, index) {
        final notification = notifications[index];
        return _buildNotificationItem(notification);
      },
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
      onDismissed: (direction) {
        // Remove notification
        setState(() {
          allNotifications.removeWhere((n) => n.id == notification.id);
        });
      },
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(vertical: 8),
        leading: CircleAvatar(
          backgroundColor: _getNotificationColor(notification.type).withOpacity(0.1),
          child: Icon(
            _getNotificationIcon(notification.type), // Flutter icon replacement
            size: 24,
            color: _getNotificationColor(notification.type),
          ),
        ),
        title: Text(
          notification.title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(notification.message),
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
        onTap: () {
          // Mark as read and handle notification
          setState(() {
            notification.isRead = true;
          });

          // Handle notification based on type
          if (notification.type == 'alert' && notification.title.contains('Disease')) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const TreatmentShopScreen(),
              ),
            );
          }
        },
      ),
    );
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

class NotificationItem {
  final int id;
  final String title;
  final String message;
  final String time;
  final String type; // 'alert', 'update', etc.
  bool isRead;

  NotificationItem({
    required this.id,
    required this.title,
    required this.message,
    required this.time,
    required this.type,
    this.isRead = false,
  });
}

// Sample notifications data
List<NotificationItem> allNotifications = [
  NotificationItem(
    id: 1,
    title: 'Disease Detected in Corn Field',
    message: 'Our AI has detected signs of Northern Leaf Blight in your corn field. View recommended treatments.',
    time: '2 hours ago',
    type: 'alert',
  ),
  NotificationItem(
    id: 2,
    title: 'Weather Alert',
    message: 'Heavy rain expected in your area in the next 24 hours. Consider protecting sensitive crops.',
    time: '5 hours ago',
    type: 'alert',
  ),
  NotificationItem(
    id: 3,
    title: 'Market Price Update',
    message: 'Corn prices have increased by 5% in the last week. Check the market tab for details.',
    time: 'Yesterday',
    type: 'update',
  ),
  NotificationItem(
    id: 4,
    title: 'Treatment Delivered',
    message: 'Your order #12345 has been delivered to your farm. Check your orders for details.',
    time: '2 days ago',
    type: 'update',
    isRead: true,
  ),
  NotificationItem(
    id: 5,
    title: 'New Feature Available',
    message: 'We\'ve added new crop prediction features. Check it out in the Analytics section!',
    time: '3 days ago',
    type: 'update',
    isRead: true,
  ),
  NotificationItem(
    id: 6,
    title: 'Soil Moisture Low',
    message: 'Soil moisture levels in Field B are below optimal levels. Consider irrigation.',
    time: '4 days ago',
    type: 'alert',
    isRead: true,
  ),
];
