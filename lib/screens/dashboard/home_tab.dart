import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import '../../services/profile_service.dart';
import '../../services/farm_service.dart';
import '../../services/weather_service.dart';
import '../../models/farm.dart';
import '../../widgets/app_drawer.dart';
import '../../widgets/weather_card.dart';
import '../notifications/notifications_screen.dart';
import 'home/farm_health.dart';
import 'farm_details_screen.dart';
import 'market_tab.dart';
import 'dart:async';
import '../../services/commodities_service.dart';
import '../../services/task_notification_service.dart';
import '../../services/auth_service.dart';
import '../../models/user_profile.dart';
import 'home/price_card.dart';
import 'home/upcoming_tasks.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

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
  final FarmService _farmService = FarmService();
  final WeatherService _weatherService = WeatherService();

  // User profile and farm
  UserProfile? _userProfile;
  Farm? _farm;

  // Weather data
  WeatherData? _weatherData;
  bool _isLoadingWeather = true;

  // Keep track of subscriptions to cancel them when widget is disposed
  final List<StreamSubscription> _subscriptions = [];

  // Store crop data
  final Map<String, CropPriceData> _cropData = {};

  // Selected crops to display
  final List<String> _selectedCrops = ['Corn', 'Wheat', 'Soybean'];

  // Farm location
  LatLng _farmLocation = const LatLng(37.7749, -122.4194);

  @override
  void initState() {
    super.initState();
    // Subscribe to price streams for selected crops
    for (final crop in _selectedCrops) {
      _subscribeToPrice(crop);
    }

    // Initialize notification service
    _notificationService.initialize();

    // Load user profile and weather data
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

        // After loading profile, load farm data
        if (profile != null && profile.farmId.isNotEmpty) {
          await _loadFarmData(profile.farmId);
        }
      }
    }
  }

  // Load farm data
  Future<void> _loadFarmData(String farmId) async {
    final farm = await _farmService.getFarm(farmId, context);
    if (farm != null && mounted) {
      setState(() {
        _farm = farm;
      });

      // After loading farm data, load weather data
      await _loadWeatherData(farm);
    }
  }

  // Load weather data
  Future<void> _loadWeatherData(Farm farm) async {
    setState(() {
      _isLoadingWeather = true;
    });

    try {
      // Resolve farm location coordinates
      final (lat, lon) = await _weatherService.resolveLocationCoordinates(farm, context);

      // Update farm location for map
      setState(() {
        _farmLocation = LatLng(lat, lon);
      });

      // Get current weather data
      final weatherData = await _weatherService.getCurrentWeather(lat, lon, farm.location);

      if (mounted) {
        setState(() {
          _weatherData = weatherData;
          _isLoadingWeather = false;
        });
      }
    } catch (e) {
      print('Error loading weather data: $e');
      if (mounted) {
        setState(() {
          _isLoadingWeather = false;
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
      return 'VP'; // Default fallback
    }

    final nameParts = _userProfile!.fullName.split(' ');
    if (nameParts.length >= 2) {
      return '${nameParts[0][0]}${nameParts[1][0]}';
    } else if (nameParts.isNotEmpty) {
      return nameParts[0][0];
    }

    return 'VP';
  }

  void _navigateToFarmDetails() {
    final farmId = _userProfile?.farmId;

    if (farmId == null || farmId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No farm associated with this account')),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FarmDetailsScreen(
          farmId: farmId,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const AppDrawer(),
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
                        ValueListenableBuilder<List<NotificationItem>>(
                          valueListenable: _notificationService.notificationsNotifier,
                          builder: (context, notifications, _) {
                            final unreadCount = _notificationService.unreadCount;
                            final theme = Theme.of(context);

                            return Container(
                              decoration: BoxDecoration(
                                color: theme.brightness == Brightness.light
                                    ? Colors.grey.shade200
                                    : theme.colorScheme.surface.withOpacity(0.6),
                                shape: BoxShape.circle,
                              ),
                              child: Stack(
                                children: [
                                  IconButton(
                                    icon: Icon(
                                      Icons.notifications_outlined,
                                      color: theme.brightness == Brightness.dark
                                          ? theme.colorScheme.onSurface
                                          : null,
                                    ),
                                    onPressed: () async {
                                      await Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => const NotificationsScreen(),
                                        ),
                                      );
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
                                          color: theme.colorScheme.error,
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
                        _userProfile?.profilePicture.isNotEmpty == true
                            ? CircleAvatar(
                          radius: 20,
                          backgroundImage: NetworkImage(_userProfile!.profilePicture),
                        )
                            : CircleAvatar(
                          radius: 20,
                          backgroundColor: Colors.greenAccent.shade400,
                          child: Text(
                            _getUserInitials(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
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
                      _weatherData != null
                          ? WeatherCard(
                        temperature: _weatherData!.temperature,
                        condition: _weatherData!.condition,
                        location: _weatherData!.location,
                        humidity: _weatherData!.humidity,
                        windSpeed: _weatherData!.windSpeed,
                        uvIndex: _weatherData!.uvIndex,
                        isLoading: _isLoadingWeather,
                      )
                          : WeatherCard(
                        isLoading: _isLoadingWeather,
                      ),
                      const SizedBox(height: 24),

                      // Farm Health Overview with onViewMoreTap callback
                      FarmHealthWidget(
                        onViewMoreTap: _navigateToFarmDetails,
                      ),

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