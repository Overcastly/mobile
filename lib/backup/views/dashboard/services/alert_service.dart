// lib/services/alert_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;

class AlertService {
  static const String baseUrl = 'https://api.weather.gov';

  Future<Map<String, dynamic>> getAlerts(double lat, double lon) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/alerts/active?point=$lat,$lon'),
        headers: {
          'User-Agent': '(Overcastly, gaming@email.com)',
          'Accept': 'application/geo+json'
        }
      );

      print('Alerts Response Status: ${response.statusCode}');
      print('Alerts Response Body: ${response.body}');

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to get alerts: ${response.statusCode}');
      }
    } catch (e) {
      print('Error in getAlerts: $e');
      rethrow;
    }
  }
}