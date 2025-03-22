import 'dart:async';
import 'dart:math';

class CropPriceData {
  final String crop;
  final String units;
  final double currentPrice;
  final double priceChange;
  final double percentChange;
  final String lastUpdated;
  final String contract;
  final Map<String, double> dayStats;
  final List<Map<String, dynamic>> historicalData;
  final String currency; // Added currency field

  CropPriceData({
    required this.crop,
    required this.units,
    required this.currentPrice,
    required this.priceChange,
    required this.percentChange,
    required this.lastUpdated,
    required this.contract,
    required this.dayStats,
    required this.historicalData,
    this.currency = 'USD', // Default currency
  });

  // Create a new instance with converted prices based on currency
  CropPriceData withCurrency(String targetCurrency, double conversionRate) {
    // Apply conversion to all price-related fields
    return CropPriceData(
      crop: this.crop,
      units: _getUnitsWithCurrency(targetCurrency),
      currentPrice: this.currentPrice * conversionRate,
      priceChange: this.priceChange * conversionRate,
      percentChange: this.percentChange, // Percent remains the same
      lastUpdated: this.lastUpdated,
      contract: this.contract,
      dayStats: {
        'open': (this.dayStats['open'] ?? 0) * conversionRate,
        'high': (this.dayStats['high'] ?? 0) * conversionRate,
        'low': (this.dayStats['low'] ?? 0) * conversionRate,
        'close': (this.dayStats['close'] ?? 0) * conversionRate,
      },
      historicalData: this.historicalData.map((data) => {
        'date': data['date'],
        'price': (data['price'] as double) * conversionRate,
      }).toList(),
      currency: targetCurrency,
    );
  }

  // Helper to format units with currency
  String _getUnitsWithCurrency(String currency) {
    // Extract the unit type (bushel, lb, etc.)
    final unitParts = this.units.split('/');
    if (unitParts.length < 2) return '$currency/unit';
    return '$currency/${unitParts[1]}';
  }
}

class CommoditiesService {
  // Base dummy data for crops
  final Map<String, Map<String, dynamic>> _dummyBasePrices = {
    'Corn': {'price': 3.85, 'volatility': 0.05},
    'Wheat': {'price': 5.42, 'volatility': 0.07},
    'Soybean': {'price': 10.15, 'volatility': 0.06},
    'Cotton': {'price': 0.72, 'volatility': 0.08},
    'Cocoa': {'price': 3.65, 'volatility': 0.09},
    'Coffee': {'price': 1.85, 'volatility': 0.1},
    'Sugar': {'price': 0.18, 'volatility': 0.06},
    'Oats': {'price': 2.95, 'volatility': 0.05},
    'Orange Juice': {'price': 1.42, 'volatility': 0.07},
  };

  // Currency conversion rates (relative to USD)
  final Map<String, double> _currencyRates = {
    'USD': 1.0,
    'EUR': 0.92,
    'KES': 130.45,
    'GBP': 0.78,
    'JPY': 152.30,
  };

  // Active streams for each crop
  final Map<String, StreamController<CropPriceData>> _activeStreams = {};

  // Currently selected currency
  String _selectedCurrency = 'USD';

  // Getter and setter for currency
  String get selectedCurrency => _selectedCurrency;

  set selectedCurrency(String currency) {
    if (_currencyRates.containsKey(currency) && _selectedCurrency != currency) {
      _selectedCurrency = currency;

      // Update all active streams with the new currency
      _activeStreams.forEach((crop, controller) {
        if (!controller.isClosed) {
          _simulatePriceUpdate(crop, controller);
        }
      });
    }
  }

  // Get all available currencies
  List<String> get availableCurrencies => _currencyRates.keys.toList();

  // Get all available crops
  List<String> get availableCrops => _dummyBasePrices.keys.toList();

  // Clean up resources
  void dispose() {
    // Close all active streams
    _activeStreams.forEach((_, controller) {
      controller.close();
    });
    _activeStreams.clear();
  }

  // Get dummy data for all crops
  Future<Map<String, CropPriceData>> getAllCropPrices() async {
    // Simulate network delay
    await Future.delayed(Duration(milliseconds: 800));

    final Map<String, CropPriceData> result = {};

    for (final cropName in _dummyBasePrices.keys) {
      result[cropName] = _generateCropData(cropName);
    }

    return result;
  }

  // Get a specific crop's price data
  Future<CropPriceData> getCropPriceData(String cropName) async {
    // Simulate network delay
    await Future.delayed(Duration(milliseconds: 500));

    if (!_dummyBasePrices.containsKey(cropName)) {
      throw Exception('Crop not found: $cropName');
    }

    return _generateCropData(cropName);
  }

  // Create a stream for real-time price updates
  Stream<CropPriceData> getPriceStream(String cropName) {
    // Check if we already have an active stream for this crop
    if (_activeStreams.containsKey(cropName) && !_activeStreams[cropName]!.isClosed) {
      return _activeStreams[cropName]!.stream;
    }

    // Create a new broadcast controller
    final controller = StreamController<CropPriceData>.broadcast(
        onCancel: () {
          // Clean up timer when the last listener unsubscribes
          if (_activeStreams.containsKey(cropName)) {
            _activeStreams.remove(cropName);
          }
        }
    );

    _activeStreams[cropName] = controller;

    // Initial data
    _simulatePriceUpdate(cropName, controller);

    // Set up periodic updates (every 5 seconds for demo purposes)
    Timer.periodic(Duration(seconds: 5), (_) {
      if (controller.isClosed) return;
      _simulatePriceUpdate(cropName, controller);
    });

    return controller.stream;
  }

  // Helper method to generate and add new price data to the stream
  void _simulatePriceUpdate(String cropName, StreamController<CropPriceData> controller) {
    try {
      final data = _generateCropData(cropName);
      if (!controller.isClosed) {
        controller.add(data);
      }
    } catch (e) {
      if (!controller.isClosed) {
        controller.addError(e);
      }
    }
  }

  // Generate realistic dummy crop data
  CropPriceData _generateCropData(String cropName) {
    final random = Random();

    if (!_dummyBasePrices.containsKey(cropName)) {
      throw Exception('Crop not found: $cropName');
    }

    final baseData = _dummyBasePrices[cropName]!;
    final basePrice = baseData['price'] as double;
    final volatility = baseData['volatility'] as double;

    // Add some randomness to the current price (±volatility%)
    final randomFactor = 1.0 + (random.nextDouble() * volatility * 2 - volatility);
    final currentPrice = basePrice * randomFactor;

    // Yesterday's closing price (between -2% and +2% from the base)
    final prevCloseFactor = 1.0 + (random.nextDouble() * 0.04 - 0.02);
    final prevClosePrice = basePrice * prevCloseFactor;

    // Calculate change from previous closing
    final priceChange = currentPrice - prevClosePrice;
    final percentChange = (priceChange / prevClosePrice) * 100;

    // Create day stats
    final openPrice = prevClosePrice * (1 + (random.nextDouble() * 0.01 - 0.005));
    final highPrice = max(currentPrice, openPrice) * (1 + random.nextDouble() * 0.01);
    final lowPrice = min(currentPrice, openPrice) * (1 - random.nextDouble() * 0.01);

    final Map<String, double> dayStats = {
      'open': openPrice,
      'high': highPrice,
      'low': lowPrice,
      'close': prevClosePrice,
    };

    // Create historical data
    final historicalData = _generateHistoricalData(currentPrice);

    // Get current date and time for lastUpdated
    final now = DateTime.now();
    final timeString = '${now.hour}:${now.minute.toString().padLeft(2, '0')} ${now.hour >= 12 ? 'PM' : 'AM'}';

    // Generate crop units
    final units = _getCropUnits(cropName);

    // Create the CropPriceData object
    CropPriceData data = CropPriceData(
      crop: cropName,
      units: units,
      currentPrice: currentPrice,
      priceChange: priceChange,
      percentChange: percentChange,
      lastUpdated: timeString,
      contract: '${cropName.toUpperCase()} ${_getContractMonth(now)}',
      dayStats: dayStats,
      historicalData: historicalData,
    );


    if (_selectedCurrency != 'USD') {
      data = data.withCurrency(_selectedCurrency, _currencyRates[_selectedCurrency]!);
    }

    return data;
  }


  String _getCropUnits(String crop) {
    switch (crop.toUpperCase()) {
      case 'CORN':
      case 'WHEAT':
      case 'SOYBEAN':
      case 'OATS':
        return 'USD/bushel';
      case 'COCOA':
      case 'COFFEE':
      case 'SUGAR':
        return 'USD/lb';
      case 'COTTON':
        return 'USD/lb';
      case 'ORANGE JUICE':
        return 'USD/lb';
      default:
        return 'USD/unit';
    }
  }


  String _getContractMonth(DateTime date) {
    final months = ['JAN', 'FEB', 'MAR', 'APR', 'MAY', 'JUN', 'JUL', 'AUG', 'SEP', 'OCT', 'NOV', 'DEC'];

    final contractMonth = (date.month) % 12;
    return months[contractMonth];
  }


  List<Map<String, dynamic>> _generateHistoricalData(double currentPrice) {
    final random = Random();
    final now = DateTime.now();


    double lastPrice = currentPrice;

    return List.generate(30, (index) {
      final date = now.subtract(Duration(days: index));


      final dayFactor = index / 30;
      final volatility = currentPrice * 0.015 * (1 + dayFactor);
      final trend = -0.1 + dayFactor * 0.2;
      final randomFactor = random.nextDouble() * volatility * 2 - volatility;


      lastPrice = (lastPrice * 0.7 + currentPrice * (0.8 + trend + randomFactor) * 0.3);
      lastPrice = max(0.1, lastPrice);

      return {
        'date': date.toIso8601String().substring(0, 10),
        'price': lastPrice,
      };
    }).reversed.toList();
  }
}