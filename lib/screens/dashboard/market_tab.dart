import 'package:flutter/material.dart';
import '../../widgets/crop_price_chart.dart';
import '../../widgets/market_news_card.dart';

class MarketTab extends StatefulWidget {
  const MarketTab({super.key});

  @override
  State<MarketTab> createState() => _MarketTabState();
}

class _MarketTabState extends State<MarketTab> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _selectedTimeRange = '1W';
  String _selectedCrop = 'Corn';

  final List<String> _timeRanges = ['1D', '1W', '1M', '3M', '1Y', 'All'];
  final List<String> _crops = ['Corn', 'Wheat', 'Soybeans', 'Rice', 'Cotton'];

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
        title: const Text('Market Insights'),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Theme.of(context).colorScheme.primary,
        bottom: TabBar(
          controller: _tabController,
          labelColor: Theme.of(context).colorScheme.primary,
          unselectedLabelColor: Colors.grey,
          indicatorColor: Theme.of(context).colorScheme.primary,
          tabs: const [
            Tab(text: 'Prices'),
            Tab(text: 'News'),
            Tab(text: 'Predictions'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildPricesTab(),
          _buildNewsTab(),
          _buildPredictionsTab(),
        ],
      ),
    );
  }

  Widget _buildPricesTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Crop Selector
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Theme.of(context).cardTheme.color,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: DropdownButton<String>(
              value: _selectedCrop,
              isExpanded: true,
              underline: const SizedBox(),
              icon: const Icon(Icons.keyboard_arrow_down),
              items: _crops.map((String crop) {
                return DropdownMenuItem<String>(
                  value: crop,
                  child: Text(crop),
                );
              }).toList(),
              onChanged: (String? newValue) {
                if (newValue != null) {
                  setState(() {
                    _selectedCrop = newValue;
                  });
                }
              },
            ),
          ),

          const SizedBox(height: 24),

          // Price Overview
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '\$7.25',
                    style: Theme.of(context).textTheme.displayMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Row(
                    children: [
                      Icon(
                        Icons.arrow_upward,
                        color: Colors.green,
                        size: 16,
                      ),
                      Text(
                        '+\$0.35 (4.8%)',
                        style: TextStyle(
                          color: Colors.green,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  'Last updated: Today, 2:30 PM',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.primary,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Time Range Selector
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: _timeRanges.map((range) {
                final isSelected = range == _selectedTimeRange;
                return Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: ChoiceChip(
                    label: Text(range),
                    selected: isSelected,
                    onSelected: (selected) {
                      if (selected) {
                        setState(() {
                          _selectedTimeRange = range;
                        });
                      }
                    },
                    backgroundColor: Colors.grey.shade200,
                    selectedColor: Theme.of(context).colorScheme.primary.withOpacity(0.2),
                    labelStyle: TextStyle(
                      color: isSelected
                          ? Theme.of(context).colorScheme.primary
                          : Colors.grey.shade700,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                );
              }).toList(),
            ),
          ),

          const SizedBox(height: 16),

          // Price Chart
          Container(
            height: 250,
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
            child: const CropPriceChart(),
          ),

          const SizedBox(height: 24),

          // Market Stats
          Text(
            'Market Statistics',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _buildStatCard('Open', '\$6.90'),
              const SizedBox(width: 12),
              _buildStatCard('High', '\$7.35'),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _buildStatCard('Low', '\$6.85'),
              const SizedBox(width: 12),
              _buildStatCard('Close', '\$7.25'),
            ],
          ),

          const SizedBox(height: 24),

          // Price Comparison
          Text(
            'Price Comparison',
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
                _buildComparisonItem('Local Market', '\$7.10', '\$7.25', true),
                const Divider(),
                _buildComparisonItem('National Average', '\$6.95', '\$7.25', true),
                const Divider(),
                _buildComparisonItem('Last Year', '\$5.80', '\$7.25', true),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNewsTab() {
    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: const [
        MarketNewsCard(
          title: 'Global Corn Prices Expected to Rise Due to Supply Chain Issues',
          source: 'AgriNews',
          date: '2 hours ago',
          imageUrl: '/placeholder.svg?height=80&width=120',
        ),
        SizedBox(height: 16),
        MarketNewsCard(
          title: 'New Government Subsidies Announced for Organic Farmers',
          source: 'Farming Today',
          date: '5 hours ago',
          imageUrl: '/placeholder.svg?height=80&width=120',
        ),
        SizedBox(height: 16),
        MarketNewsCard(
          title: 'Weather Patterns Affecting Wheat Production in Major Regions',
          source: 'Climate & Agriculture',
          date: '1 day ago',
          imageUrl: '/placeholder.svg?height=80&width=120',
        ),
        SizedBox(height: 16),
        MarketNewsCard(
          title: 'Technology Innovations Driving Efficiency in Modern Farming',
          source: 'Tech in Agriculture',
          date: '2 days ago',
          imageUrl: '/placeholder.svg?height=80&width=120',
        ),
      ],
    );
  }

  Widget _buildPredictionsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.info_outline,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Our AI-powered predictions are based on historical data, current market trends, and weather forecasts.',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          Text(
            'Price Predictions',
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
                _buildPredictionItem('1 Week', '\$7.40', 'Slight increase expected'),
                const Divider(),
                _buildPredictionItem('1 Month', '\$7.65', 'Moderate increase due to seasonal demand'),
                const Divider(),
                _buildPredictionItem('3 Months', '\$7.25', 'Stabilization after harvest season'),
              ],
            ),
          ),

          const SizedBox(height: 24),

          Text(
            'Market Factors',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          _buildFactorCard(
            'Weather',
            'Favorable conditions expected in major growing regions',
            Icons.wb_sunny,
            Colors.orange,
          ),
          const SizedBox(height: 12),
          _buildFactorCard(
            'Supply',
            'Slightly lower than average due to reduced planting',
            Icons.inventory,
            Colors.blue,
          ),
          const SizedBox(height: 12),
          _buildFactorCard(
            'Demand',
            'Increasing domestic and international demand',
            Icons.trending_up,
            Colors.green,
          ),
          const SizedBox(height: 12),
          _buildFactorCard(
            'Policy',
            'New export regulations may affect international prices',
            Icons.policy,
            Colors.purple,
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String label, String value) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).cardTheme.color,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildComparisonItem(String label, String oldValue, String newValue, bool isUp) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.w500,
            ),
          ),
          Row(
            children: [
              Text(
                oldValue,
                style: TextStyle(
                  color: Colors.grey.shade600,
                  decoration: TextDecoration.lineThrough,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                newValue,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 4),
              Icon(
                isUp ? Icons.arrow_upward : Icons.arrow_downward,
                color: isUp ? Colors.green : Colors.red,
                size: 16,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPredictionItem(String timeframe, String price, String description) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              timeframe,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  price,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  description,
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFactorCard(String title, String description, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: color,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}