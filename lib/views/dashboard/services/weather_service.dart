import 'dart:convert';
import 'package:http/http.dart' as http;

class WeatherService {
  static const String baseUrl = 'https://api.weather.gov';

  Future<Map<String, dynamic>> getGridPoint(double lat, double lon) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/points/$lat,$lon'),
        headers: {
          'User-Agent': '(Overcastly, gamer@email.com)',
          'Accept': 'application/geo+json'
        }
      );

      print('Grid Point Response Status: ${response.statusCode}');
      print('Grid Point Response Body: ${response.body}');

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to get grid point: ${response.statusCode}');
      }
    } catch (e) {
      print('Error in getGridPoint: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> getCurrentConditions(String stationsUrl) async {
    try {
      print('Fetching stations from URL: $stationsUrl');
      
      final stationsResponse = await http.get(
        Uri.parse(stationsUrl),
        headers: {
          'User-Agent': '(Overcastly, videojuego@email.com)',
          'Accept': 'application/geo+json'
        }
      );

      print('Stations Response Status: ${stationsResponse.statusCode}');
      print('Stations Response Body: ${stationsResponse.body}');

      if (stationsResponse.statusCode == 200) {
        final stationsData = json.decode(stationsResponse.body);
        
        if (stationsData['features'] == null || stationsData['features'].isEmpty) {
          throw Exception('No stations found in the response');
        }

        final firstStation = stationsData['features'][0];
        if (firstStation['id'] == null) {
          throw Exception('Station ID not found');
        }

        final firstStationUrl = '$baseUrl/stations/${firstStation['properties']['stationIdentifier']}/observations/latest';
        print('Fetching weather from station URL: $firstStationUrl');

        final weatherResponse = await http.get(
          Uri.parse(firstStationUrl),
          headers: {
            'User-Agent': '(Overcastly, jugando@email.com)',
            'Accept': 'application/geo+json'
          }
        );

        print('Weather Response Status: ${weatherResponse.statusCode}');
        print('Weather Response Body: ${weatherResponse.body}');

        if (weatherResponse.statusCode == 200) {
          return json.decode(weatherResponse.body);
        }
        throw Exception('Weather data request failed: ${weatherResponse.statusCode}');
      }
      throw Exception('Stations request failed: ${stationsResponse.statusCode}');
    } catch (e) {
      print('Error in getCurrentConditions: $e');
      rethrow;
    }
  }
}