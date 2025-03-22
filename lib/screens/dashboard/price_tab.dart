import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math';
import '../../widgets/crop_price_chart.dart';
import '../../services/commodities_service.dart';

class PriceTab extends StatefulWidget {
  const PriceTab({super.key});

  @override
  State<PriceTab> createState() => _PriceTabState();
}

class _PriceTabState extends State<PriceTab> {
  String _selectedTimeRange = '1W';
  String _selectedCrop = 'Corn';
  bool _isLoading = true;
  String _errorMessage = '';

  // Data state
  CropPriceData? _priceData;
  Map<String, CropPriceData> _allCropsData = {};

  final CommoditiesService _priceService = CommoditiesService();
  StreamSubscription<CropPriceData>? _priceStreamSubscription;

  final List<String> _timeRanges = ['1D', '1W', '1M', '3M', '1Y', 'All'];

  final List<String> _crops = ['Corn', 'Wheat', 'Soybean', 'Cotton', 'Cocoa', 'Coffee', 'Sugar', 'Oats', 'Orange Juice'];

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  @override
  void dispose() {
    // Cancel the stream subscription in dispose
    _priceStreamSubscription?.cancel();
    _priceService.dispose(); // Make sure the service is properly disposed
    super.dispose();
  }

  Future<void> _loadInitialData() async {
    if (!mounted) return; // Check if widget is still mounted

    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      // Load all crops data first
      _allCropsData = await _priceService.getAllCropPrices();

      // Setup stream for selected crop
      _setupCropStream();
    } catch (e) {
      _handleError(e);
    }
  }

  void _setupCropStream() {
    // Cancel any existing subscription first
    _priceStreamSubscription?.cancel();

    _priceStreamSubscription = _priceService
        .getPriceStream(_selectedCrop)
        .listen(_handlePriceUpdate, onError: _handleError);
  }

  void _handlePriceUpdate(CropPriceData data) {
    // Check if the widget is still mounted before calling setState
    if (!mounted) return;

    setState(() {
      _priceData = data;
      _isLoading = false;
    });
  }

  void _handleError(dynamic error) {
    // Check if the widget is still mounted before calling setState
    if (!mounted) return;

    setState(() {
      _isLoading = false;
      _errorMessage = error.toString();
    });
  }

  void _onCropChanged(String? newValue) {
    if (newValue != null && newValue != _selectedCrop) {
      if (!mounted) return; // Check if widget is still mounted

      setState(() {
        _selectedCrop = newValue;
        _isLoading = true;
      });

      // If we already have the data cached
      if (_allCropsData.containsKey(newValue)) {
        if (!mounted) return; // Check again before setState

        setState(() {
          _priceData = _allCropsData[newValue];
          _isLoading = false;
        });
      }

      // Setup stream for new crop
      _setupCropStream();
    }
  }

  void _onTimeRangeChanged(String range) {
    if (range != _selectedTimeRange && mounted) { // Check if mounted
      setState(() {
        _selectedTimeRange = range;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading && _priceData == null) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage.isNotEmpty && _priceData == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Error: $_errorMessage'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadInitialData,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

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
          const SizedBox(height: 24),

          // Last Update and Contract Info
          _buildContractInfo(),
        ],
      ),
    );
  }

  // Rest of the widget code remains unchanged
  Widget _buildCropSelector() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color ?? Colors.white,
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
        onChanged: _onCropChanged,
      ),
    );
  }

  Widget _buildPriceOverview() {
    if (_priceData == null) return const SizedBox();

    final isPositive = _priceData!.priceChange >= 0;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '\$${_priceData!.currentPrice.toStringAsFixed(2)}',
                  style: Theme.of(context).textTheme.displayMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  _priceData!.units,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(
                  isPositive ? Icons.arrow_upward : Icons.arrow_downward,
                  color: isPositive ? Colors.green : Colors.red,
                  size: 16,
                ),
                Text(
                  '${isPositive ? '+' : ''}\$${_priceData!.priceChange.toStringAsFixed(2)} (${_priceData!.percentChange.toStringAsFixed(1)}%)',
                  style: TextStyle(
                    color: isPositive ? Colors.green : Colors.red,
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
            'Last updated: ${_priceData!.lastUpdated}',
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
                  _onTimeRangeChanged(range);
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
    if (_priceData == null) return const SizedBox();

    // Filter historical data based on selected time range
    final filteredData = _getFilteredHistoricalData();

    return Container(
      height: 250,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color ?? Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: filteredData.isNotEmpty
          ? CropPriceChart(
        data: filteredData,
        timeRange: _selectedTimeRange,
      )
          : const Center(child: Text('No historical data available')),
    );
  }

  List<Map<String, dynamic>> _getFilteredHistoricalData() {
    if (_priceData == null) return [];

    final now = DateTime.now();
    final allData = _priceData!.historicalData;

    switch (_selectedTimeRange) {
      case '1D':
      // Only show data for the last 24 hours
        return allData.where((data) {
          final date = DateTime.tryParse(data['date'].toString());
          return date != null && now.difference(date).inHours <= 24;
        }).toList();

      case '1W':
      // Only show data for the last 7 days
        return allData.where((data) {
          final date = DateTime.tryParse(data['date'].toString());
          return date != null && now.difference(date).inDays <= 7;
        }).toList();

      case '1M':
      // Only show data for the last 30 days
        return allData.where((data) {
          final date = DateTime.tryParse(data['date'].toString());
          return date != null && now.difference(date).inDays <= 30;
        }).toList();

      case '3M':
      // Only show data for the last 90 days
        return allData.where((data) {
          final date = DateTime.tryParse(data['date'].toString());
          return date != null && now.difference(date).inDays <= 90;
        }).toList();

      case '1Y':
      // Only show data for the last 365 days
        return allData.where((data) {
          final date = DateTime.tryParse(data['date'].toString());
          return date != null && now.difference(date).inDays <= 365;
        }).toList();

      case 'All':
      default:
        return allData;
    }
  }

  Widget _buildMarketStats() {
    if (_priceData == null) return const SizedBox();

    final stats = _priceData!.dayStats;

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
            _buildStatCard('Open', '\$${stats['open']?.toStringAsFixed(2) ?? '--'}'),
            const SizedBox(width: 12),
            _buildStatCard('High', '\$${stats['high']?.toStringAsFixed(2) ?? '--'}'),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            _buildStatCard('Low', '\$${stats['low']?.toStringAsFixed(2) ?? '--'}'),
            const SizedBox(width: 12),
            _buildStatCard('Close', '\$${stats['close']?.toStringAsFixed(2) ?? '--'}'),
          ],
        ),
      ],
    );
  }

  Widget _buildPriceComparison() {
    if (_priceData == null || _allCropsData.isEmpty) return const SizedBox();

    final currentPrice = _priceData!.currentPrice;

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
            color: Theme.of(context).cardTheme.color ?? Colors.white,
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

              _buildCropComparisonItems(),


              const Divider(),
              _buildComparisonItem(
                  'Yesterday\'s Close',
                  '\$${_priceData!.dayStats['close']?.toStringAsFixed(2) ?? '--'}',
                  '\$${currentPrice.toStringAsFixed(2)}',
                  currentPrice > (_priceData!.dayStats['close'] ?? 0)
              ),


              const Divider(),
              _buildComparisonItem(
                  'Last Week',
                  '\$${(currentPrice * 0.95).toStringAsFixed(2)}',
                  '\$${currentPrice.toStringAsFixed(2)}',
                  true
              ),


              const Divider(),
              _buildComparisonItem(
                  'Last Month',
                  '\$${(currentPrice * 0.92).toStringAsFixed(2)}',
                  '\$${currentPrice.toStringAsFixed(2)}',
                  true
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildContractInfo() {
    if (_priceData == null) return const SizedBox();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color ?? Colors.white,
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Contract Information',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Contract:'),
              Text(
                _priceData!.contract,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 8),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Exchange:'),
              Text(
                _getCommodityExchange(_selectedCrop),
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 8),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Last Update:'),
              Text(
                _priceData!.lastUpdated,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _getCommodityExchange(String crop) {
    switch (crop.toUpperCase()) {
      case 'CORN':
      case 'WHEAT':
      case 'SOYBEAN':
      case 'OATS':
        return 'CBOT (Chicago Board of Trade)';
      case 'COCOA':
      case 'COFFEE':
      case 'SUGAR':
      case 'COTTON':
        return 'ICE (Intercontinental Exchange)';
      case 'ORANGE JUICE':
        return 'ICE (Intercontinental Exchange)';
      default:
        return 'CBOT';
    }
  }

  Widget _buildCropComparisonItems() {
    if (_allCropsData.isEmpty || _priceData == null) {
      return const SizedBox();
    }

    // Get other crops to compare (max 2 to avoid cluttering)
    final otherCrops = _allCropsData.entries
        .where((entry) => entry.key != _selectedCrop)
        .take(2)
        .toList();

    if (otherCrops.isEmpty) {
      return const SizedBox();
    }

    List<Widget> widgets = [];

    for (int i = 0; i < otherCrops.length; i++) {
      final crop = otherCrops[i].key;
      final data = otherCrops[i].value;

      widgets.add(
          _buildComparisonItem(
              crop,
              '\$${data.currentPrice.toStringAsFixed(2)}',
              '\$${_priceData!.currentPrice.toStringAsFixed(2)}',
              _priceData!.currentPrice > data.currentPrice
          )
      );

      if (i < otherCrops.length - 1) {
        widgets.add(const Divider());
      }
    }

    return Column(children: widgets);
  }

  Widget _buildStatCard(String label, String value) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).cardTheme.color ?? Colors.white,
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