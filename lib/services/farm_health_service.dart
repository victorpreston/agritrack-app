import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../models/farm.dart';

class AgromonitoringService {
  final String apiKey = '449ddcafea40e3831867f69eeed90803';
  final String baseUrl = 'http://api.agromonitoring.com/agro/1.0';

  // Get soil data for a farm based on location
  Future<Map<String, dynamic>?> getFarmHealthData(Farm farm, BuildContext context) async {
    try {
      // Parse location string to get latitude and longitude
      final List<String> locationParts = farm.location.split(',');
      if (locationParts.length < 2) {
        return _getDefaultHealthData();
      }

      final double lat = double.tryParse(locationParts[0].trim()) ?? 0;
      final double lon = double.tryParse(locationParts[1].trim()) ?? 0;

      if (lat == 0 && lon == 0) {
        return _getDefaultHealthData();
      }

      // Fetch soil data from the API
      final response = await http.get(
        Uri.parse('$baseUrl/soil?polyid=demo&appid=$apiKey&lat=$lat&lon=$lon'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return _processHealthData(data);
      } else {
        // Return default data if API call fails
        return _getDefaultHealthData();
      }
    } catch (error) {
      // Return default data in case of any errors
      return _getDefaultHealthData();
    }
  }

  // Process the API response into a format our app can use
  Map<String, dynamic> _processHealthData(Map<String, dynamic> apiData) {
    // Extract relevant data from API response
    // The exact properties will depend on the API response structure
    final Map<String, dynamic> healthData = {
      'soilMoisture': {
        'value': '${_getSoilMoisture(apiData)}%',
        'progress': _getSoilMoistureProgress(apiData),
      },
      'soilPH': {
        'value': _getSoilPH(apiData),
        'progress': _getSoilPHProgress(apiData),
      },
      'nitrogen': {
        'value': '60%', // Default value as this might not be provided by the API
        'progress': 0.6,
      },
      'cropHealth': {
        'value': '85%', // Default value as this might not be provided by the API
        'progress': 0.85,
      },
    };

    return healthData;
  }

  // Helper method to extract soil moisture from API data
  String _getSoilMoisture(Map<String, dynamic> apiData) {
    // Extract soil moisture data if available, or return a default
    try {
      if (apiData.containsKey('moisture')) {
        // Convert to percentage (this will depend on how the API returns the data)
        final double moisture = apiData['moisture'];
        return (moisture * 100).toStringAsFixed(1);
      }
    } catch (e) {
      // Return default on error
    }
    return '75';
  }

  // Convert soil moisture to progress value (0.0 to 1.0)
  double _getSoilMoistureProgress(Map<String, dynamic> apiData) {
    try {
      if (apiData.containsKey('moisture')) {
        final double moisture = apiData['moisture'];
        return moisture.clamp(0.0, 1.0);
      }
    } catch (e) {
      // Return default on error
    }
    return 0.75;
  }

  // Helper method to extract soil pH from API data
  String _getSoilPH(Map<String, dynamic> apiData) {
    try {
      if (apiData.containsKey('ph')) {
        final double ph = apiData['ph'];
        return ph.toStringAsFixed(1);
      }
    } catch (e) {
      // Return default on error
    }
    return '6.5';
  }

  // Convert soil pH to progress value (0.0 to 1.0)
  double _getSoilPHProgress(Map<String, dynamic> apiData) {
    try {
      if (apiData.containsKey('ph')) {
        // Assuming pH range of 0-14, with 7 being neutral
        // Convert to a 0-1 scale where values around 6.5-7.5 are considered optimal
        final double ph = apiData['ph'];
        // This is a simplified conversion - adjust based on your needs
        final double normalizedPh = (ph / 14.0).clamp(0.0, 1.0);
        return normalizedPh;
      }
    } catch (e) {
      // Return default on error
    }
    return 0.65;
  }

  // Get default farm health data when API fails or data is unavailable
  Map<String, dynamic> _getDefaultHealthData() {
    return {
      'soilMoisture': {
        'value': '75%',
        'progress': 0.75,
      },
      'soilPH': {
        'value': '6.5',
        'progress': 0.65,
      },
      'nitrogen': {
        'value': '60%',
        'progress': 0.6,
      },
      'cropHealth': {
        'value': '90%',
        'progress': 0.9,
      },
    };
  }
}