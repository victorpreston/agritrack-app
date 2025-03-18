import 'package:flutter/material.dart';
import '../../widgets/weather_card.dart';
import '../../widgets/task_card.dart';
import '../../widgets/market_price_card.dart';

class HomeTab extends StatelessWidget {
  const HomeTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // App Bar
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Good Morning,',
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: Colors.grey.shade600,
                          ),
                        ),
                        Text(
                          'John Doe',
                          style: Theme.of(context).textTheme.displaySmall,
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.notifications_outlined),
                          onPressed: () {},
                        ),
                        const SizedBox(width: 8),
                        CircleAvatar(
                          radius: 20,
                          backgroundColor: Theme.of(context).colorScheme.primary,
                          child: const Text(
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
                const SizedBox(height: 24),

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
                Container(
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
                ),

                const SizedBox(height: 24),

                // Upcoming Tasks
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Upcoming Tasks',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextButton(
                      onPressed: () {},
                      child: const Text('View All'),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                const TaskCard(
                  title: 'Apply Fertilizer',
                  description: 'Apply NPK fertilizer to corn field',
                  date: 'Today',
                  isCompleted: false,
                ),
                const SizedBox(height: 12),
                const TaskCard(
                  title: 'Irrigation Check',
                  description: 'Check irrigation system in sector B',
                  date: 'Tomorrow',
                  isCompleted: false,
                ),

                const SizedBox(height: 24),

                // Market Prices
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Market Prices',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextButton(
                      onPressed: () {},
                      child: const Text('View All'),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                const SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      MarketPriceCard(
                        cropName: 'Corn',
                        price: 7.25,
                        change: 0.35,
                        isUp: true,
                      ),
                      SizedBox(width: 12),
                      MarketPriceCard(
                        cropName: 'Wheat',
                        price: 6.80,
                        change: 0.12,
                        isUp: false,
                      ),
                      SizedBox(width: 12),
                      MarketPriceCard(
                        cropName: 'Soybeans',
                        price: 14.50,
                        change: 0.75,
                        isUp: true,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

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