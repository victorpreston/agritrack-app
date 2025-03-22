import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import '../../widgets/app_drawer.dart';
import '../../widgets/weather_card.dart';
import '../notifications/notifications_screen.dart';
import 'market_tab.dart';
import 'dart:async';
import '../../services/commodities_service.dart';
import 'home/price_card.dart';
import 'home/upcoming_tasks.dart';

class HomeTab extends StatefulWidget {
  const HomeTab({super.key});

  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {
  // Initialize CommoditiesService
  final CommoditiesService _commoditiesService = CommoditiesService();

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
                    // Menu Icon
                    IconButton(
                      icon: const Icon(Icons.menu, size: 28),
                      onPressed: () {
                        Scaffold.of(context).openDrawer();
                      },
                    ),
                    const Text(
                      'Dashboard',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.notifications_outlined),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const NotificationsScreen(),
                              ),
                            );
                          },
                        ),
                        const SizedBox(width: 8),
                        const CircleAvatar(
                          radius: 20,
                          backgroundColor: Colors.blue,
                          child: Text(
                            'JD',
                            style: TextStyle(
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
                      const WeatherCard(
                        temperature: 28,
                        condition: 'Sunny',
                        location: 'Farm Location',
                        humidity: 65,
                        windSpeed: 10,
                      ),
                      const SizedBox(height: 24),

                      // Farm Health Overview
                      Text(
                        'Farm Health Overview',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildHealthOverview(context),

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

  // Build Farm Health Overview
  Widget _buildHealthOverview(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              _buildHealthIndicator(
                context,
                'Soil Moisture',
                '75%',
                Icons.water_drop,
                Colors.blue,
                0.75,
              ),
              const SizedBox(width: 16),
              _buildHealthIndicator(
                context,
                'Soil pH',
                '6.5',
                Icons.science,
                Colors.green,
                0.65,
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _buildHealthIndicator(
                context,
                'Nitrogen',
                '60%',
                Icons.eco,
                Colors.amber,
                0.6,
              ),
              const SizedBox(width: 16),
              _buildHealthIndicator(
                context,
                'Crop Health',
                '90%',
                Icons.spa,
                Colors.teal,
                0.9,
              ),
            ],
          ),
        ],
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

  // Build Health Indicator
  Widget _buildHealthIndicator(
      BuildContext context,
      String title,
      String value,
      IconData icon,
      Color color,
      double progress,
      ) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 20),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              value,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: progress,
              backgroundColor: Colors.grey.shade300,
              valueColor: AlwaysStoppedAnimation<Color>(color),
              borderRadius: BorderRadius.circular(10),
            ),
          ],
        ),
      ),
    );
  }
}