import 'package:flutter/material.dart';
import '../../widgets/crop_price_chart.dart';

class PriceTab extends StatefulWidget {
  const PriceTab({super.key});

  @override
  State<PriceTab> createState() => _PriceTabState();
}

class _PriceTabState extends State<PriceTab> {
  String _selectedTimeRange = '1W';
  String _selectedCrop = 'Corn';

  final List<String> _timeRanges = ['1D', '1W', '1M', '3M', '1Y', 'All'];
  final List<String> _crops = ['Corn', 'Wheat', 'Soybeans', 'Rice', 'Cotton'];

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Crop Selector
          _buildCropSelector(),
          const SizedBox(height: 24),

          // Price Overview
          _buildPriceOverview(),
          const SizedBox(height: 24),

          // Time Range Selector
          _buildTimeRangeSelector(),
          const SizedBox(height: 16),

          // Price Chart
          _buildPriceChart(),
          const SizedBox(height: 24),

          // Market Stats
          _buildMarketStats(),
          const SizedBox(height: 24),

          // Price Comparison
          _buildPriceComparison(),
        ],
      ),
    );
  }

  Widget _buildCropSelector() {
    return Container(
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
    );
  }

  Widget _buildPriceOverview() {
    return Row(
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
    );
  }

  Widget _buildTimeRangeSelector() {
    return SingleChildScrollView(
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
    );
  }

  Widget _buildPriceChart() {
    return Container(
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
    );
  }

  Widget _buildMarketStats() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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
      ],
    );
  }

  Widget _buildPriceComparison() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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
}