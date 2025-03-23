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