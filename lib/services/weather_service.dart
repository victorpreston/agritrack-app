import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../models/farm.dart';

class WeatherData {
  final double temperature;
  final String condition;
  final String location;
  final int humidity;
  final double windSpeed;
  final int uvIndex;

  WeatherData({
    required this.temperature,
    required this.condition,
    required this.location,
    required this.humidity,
    required this.windSpeed,
    this.uvIndex = 0,
  });

  factory WeatherData.empty() {
    return WeatherData(
      temperature: 0,
      condition: 'Unknown',
      location: 'Unknown',
      humidity: 0,
      windSpeed: 0,
      uvIndex: 0,
    );
  }
}

class WeatherService {
  static const String _apiKey = '74b8d92016fea55ff827b35e7e2e9423';
  static const String _baseUrl = 'https://api.agromonitoring.com/agro/1.0';

  Future<WeatherData> getCurrentWeather(double lat, double lon, String locationName) async {
    try {
      final url = Uri.parse('$_baseUrl/weather?lat=$lat&lon=$lon&appid=$_apiKey&units=metric');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        final weather = data['weather'][0];
        final main = data['main'];
        final wind = data['wind'];

        return WeatherData(
          temperature: main['temp'].toDouble(),
          condition: weather['main'],
          location: locationName,
          humidity: main['humidity'],
          windSpeed: wind['speed'].toDouble(),
          uvIndex: 0,
        );
      } else {
        print('Error fetching weather: ${response.statusCode}');
        print('Response: ${response.body}');
        throw Exception('Failed to load weather data');
      }
    } catch (e) {
      print('Exception in weather service: $e');
      return WeatherData.empty();
    }
  }

  // Get the weather forecast by coordinates
  Future<List<WeatherData>> getWeatherForecast(double lat, double lon, String locationName) async {
    try {
      final url = Uri.parse('$_baseUrl/weather/forecast?lat=$lat&lon=$lon&appid=$_apiKey&units=metric');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final List<dynamic> forecastList = json.decode(response.body);

        return forecastList.map((data) {
          final weather = data['weather'][0];
          final main = data['main'];
          final wind = data['wind'];

          return WeatherData(
            temperature: main['temp'].toDouble(),
            condition: weather['main'],
            location: locationName,
            humidity: main['humidity'],
            windSpeed: wind['speed'].toDouble(),
            uvIndex: 0,
          );
        }).toList();
      } else {
        print('Error fetching forecast: ${response.statusCode}');
        throw Exception('Failed to load forecast data');
      }
    } catch (e) {
      print('Exception in weather forecast service: $e');
      return [];
    }
  }

  Future<(double, double)> resolveLocationCoordinates(Farm farm, BuildContext context) async {
    // Simple mapping of known locations

    final Map<String, (double, double)> knownLocations = {
      'tharaka-nithi': (-0.3031, 38.0526),
      'tharaka nithi': (-0.3031, 38.0526),
      'nairobi': (-1.2921, 36.8219),
      'mombasa': (-4.0435, 39.6682),
      'kisumu': (-0.1022, 34.7617),
      'nakuru': (-0.3031, 36.0800),
      'eldoret': (0.5143, 35.2698),
      // + known locations
    };

    final locationLower = farm.location.toLowerCase().trim();

    for (final entry in knownLocations.entries) {
      if (locationLower.contains(entry.key)) {
        return entry.value;
      }
    }

    return (-0.0236, 37.9062);
  }
}