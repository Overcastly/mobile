import 'package:http/http.dart' as http;
import 'dart:convert';

class LocationService {
  Future<List<dynamic>> searchLocation(String query) async {
    try {
      final response = await http.get(
        Uri.parse('https://nominatim.openstreetmap.org/search')
            .replace(queryParameters: {
          'q': query,
          'countrycodes': 'us',
          'format': 'json',
        }),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to search location');
      }
    } catch (e) {
      print('Error searching location: $e');
      rethrow;
    }
  }
}