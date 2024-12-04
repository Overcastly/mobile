class WeatherData {
  final double temperature;
  final double windSpeed;
  final String windDirection;
  final double humidity;
  final String description;
  final double pressure;
  final double visibility;
  final double precipitation;

  WeatherData({
    required this.temperature,
    required this.windSpeed,
    required this.windDirection,
    required this.humidity,
    required this.description,
    required this.pressure,
    required this.visibility,
    required this.precipitation,
  });

  factory WeatherData.fromJson(Map<String, dynamic> json) {
    try {
      print('Parsing weather data from JSON: $json');
      
      final properties = json['properties'];
      if (properties == null) {
        throw Exception('No properties found in weather data');
      }

      return WeatherData(
        temperature: _parseDoubleValue(properties['temperature']),
        windSpeed: _parseDoubleValue(properties['windSpeed']),
        windDirection: _parseStringValue(properties['windDirection']),
        humidity: _parseDoubleValue(properties['relativeHumidity']),
        description: properties['textDescription']?.toString() ?? 'No description available',
        pressure: _parseDoubleValue(properties['barometricPressure']),
        visibility: _parseDoubleValue(properties['visibility']),
        precipitation: _parseDoubleValue(properties['precipitation']),
      );
    } catch (e) {
      print('Error parsing weather data: $e');
      rethrow;
    }
  }

  static double _parseDoubleValue(Map<String, dynamic>? measurement) {
    if (measurement == null || measurement['value'] == null) {
      return 0.0;
    }
    return (measurement['value'] as num).toDouble();
  }

  static String _parseStringValue(Map<String, dynamic>? measurement) {
    if (measurement == null || measurement['value'] == null) {
      return 'N/A';
    }
    return measurement['value'].toString();
  }
}