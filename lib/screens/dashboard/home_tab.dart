import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import '../../services/profile_service.dart';
import '../../widgets/app_drawer.dart';
import '../../widgets/weather_card.dart';
import '../notifications/notifications_screen.dart';
import 'home/farm_health.dart';
import 'market_tab.dart';
import 'dart:async';
import '../../services/commodities_service.dart';
import '../../services/task_notification_service.dart';
import '../../services/auth_service.dart';
import '../../models/user_profile.dart';
import 'home/price_card.dart';
import 'home/upcoming_tasks.dart';

class HomeTab extends StatefulWidget {
  const HomeTab({super.key});

  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {
  // Initialize Services
  final CommoditiesService _commoditiesService = CommoditiesService();
  final NotificationService _notificationService = NotificationService();
  final UserProfileService _profileService = UserProfileService();
  final AuthService _authService = AuthService();

  // User profile
  UserProfile? _userProfile;

  // Keep track of subscriptions to cancel them when widget is disposed
  final List<StreamSubscription> _subscriptions = [];

  // Store crop data
  final Map<String, CropPriceData> _cropData = {};

  // Selected crops to display
  final List<String> _selectedCrops = ['Corn', 'Wheat', 'Soybean'];

  @override
  void initState() {
    super.initState();
    // Subscribe to price streams for selected crops
    for (final crop in _selectedCrops) {
      _subscribeToPrice(crop);
    }

    // Initialize notification service
    _notificationService.initialize();

    // Load user profile
    _loadUserProfile();
  }

  // Load user profile
  Future<void> _loadUserProfile() async {
    final userId = _authService.currentUser?.id;
    if (userId != null) {
      final profile = await _profileService.getUserProfile(userId, context);
      if (mounted) {
        setState(() {
          _userProfile = profile;
        });
      }
    }
  }

  @override
  void dispose() {
    // Cancel all subscriptions
    for (final subscription in _subscriptions) {
      subscription.cancel();
    }
    _subscriptions.clear();

    // Dispose commodities service
    _commoditiesService.dispose();
    super.dispose();
  }

  // Subscribe to price stream for a crop
  void _subscribeToPrice(String crop) {
    final subscription = _commoditiesService
        .getPriceStream(crop)
        .listen((data) {
      setState(() {
        _cropData[crop] = data;
      });
    });

    _subscriptions.add(subscription);
  }

  // Get user initials for avatar fallback
  String _getUserInitials() {
    if (_userProfile == null || _userProfile!.fullName.isEmpty) {
      return ''; // Just return empty string if no name available
    }

    final nameParts = _userProfile!.fullName.split(' ');
    if (nameParts.length >= 2) {
      return '${nameParts[0][0]}${nameParts[1][0]}';
    } else if (nameParts.isNotEmpty) {
      return nameParts[0][0];
    }

    return '';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const AppDrawer(), // Attach the AppDrawer here
      body: Builder(
        builder: (context) => SafeArea(
          child: Column(
            children: [
              // Custom AppBar with Menu Button
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Menu Icon with square background
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.green.shade100,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.menu, size: 24),
                        color: Colors.green.shade800,
                        onPressed: () {
                          Scaffold.of(context).openDrawer();
                        },
                      ),
                    ),
                    const Text(
                      'Dashboard',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    Row(
                      children: [
                        // Notification Icon with Badge and circular background
                        ValueListenableBuilder<List<NotificationItem>>(
                          valueListenable: _notificationService.notificationsNotifier,
                          builder: (context, notifications, _) {
                            final unreadCount = _notificationService.unreadCount;

                            return Container(
                              decoration: BoxDecoration(
                                color: Colors.grey.shade200,
                                shape: BoxShape.circle,
                              ),
                              child: Stack(
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.notifications_outlined),
                                    onPressed: () async {
                                      await Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => const NotificationsScreen(),
                                        ),
                                      );
                                      // Force refresh when returning from notifications
                                      setState(() {});
                                    },
                                  ),
                                  if (unreadCount > 0)
                                    Positioned(
                                      right: 8,
                                      top: 8,
                                      child: Container(
                                        padding: const EdgeInsets.all(2),
                                        decoration: BoxDecoration(
                                          color: Colors.red,
                                          borderRadius: BorderRadius.circular(10),
                                        ),
                                        constraints: const BoxConstraints(
                                          minWidth: 16,
                                          minHeight: 16,
                                        ),
                                        child: Text(
                                          unreadCount > 9 ? '9+' : '$unreadCount',
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 10,
                                            fontWeight: FontWeight.bold,
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            );
                          },
                        ),
                        const SizedBox(width: 8),
                        // User profile avatar with image or initials - matched size with notifications
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.grey.shade200,
                            shape: BoxShape.circle,
                          ),
                          child: _userProfile?.profilePicture.isNotEmpty == true
                              ? ClipOval(
                            child: Image.network(
                              _userProfile!.profilePicture,
                              width: 48,
                              height: 48,
                              fit: BoxFit.cover,
                            ),
                          )
                              : SizedBox(
                            width: 48,
                            height: 48,
                            child: Center(
                              child: Text(
                                _getUserInitials(),
                                style: TextStyle(
                                  color: Colors.blue,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Main Content Area
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Weather Card
                      const WeatherCard(
                        temperature: 28,
                        condition: 'Sunny',
                        location: 'Farm Location',
                        humidity: 65,
                        windSpeed: 10,
                      ),
                      const SizedBox(height: 24),

                      // Farm Health Overview (now using the extracted widget)
                      const FarmHealthWidget(),

                      const SizedBox(height: 24),

                      const UpcomingTasksWidget(),

                      const SizedBox(height: 24),

                      // Market Prices
                      _buildMarketPricesHeader(context),
                      const SizedBox(height: 8),
                      _buildMarketPrices(),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Build Market Prices Header with Navigation
  Widget _buildMarketPricesHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Market Prices',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        TextButton.icon(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const MarketTab(),
              ),
            );
          },
          icon: const Icon(HugeIcons.strokeRoundedLinkCircle02, size: 16),
          label: const Text('View All'),
          style: TextButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            minimumSize: Size.zero,
          ),
        ),
      ],
    );
  }

  // Build Market Prices
  Widget _buildMarketPrices() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: _selectedCrops.map((crop) {
          final cropData = _cropData[crop];
          if (cropData == null) {
            return Padding(
              padding: const EdgeInsets.only(right: 12),
              child: LoadingMarketPriceCard(cropName: crop),
            );
          }

          return Padding(
            padding: const EdgeInsets.only(right: 12),
            child: MarketPriceCard(data: cropData),
          );
        }).toList(),
      ),
    );
  }
}