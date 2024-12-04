import 'dart:convert';
import 'dart:developer';
import 'package:mongo_dart/mongo_dart.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class MongoDatabase {
  static Db? _db;
  static String? _userCollection;
  static String? _postsCollection;
  static String? _baseUrl;

  static connect() async {
    await dotenv.load(fileName: ".env");
    var dbUrl = dotenv.env['DB_URL'];
    _userCollection = dotenv.env['USERS_COLLECTION'];
    _postsCollection = dotenv.env['POSTS_COLLECTION'];
    _baseUrl = dotenv.env['BASE_URL'];
    print('Connecting to MongoDB with URL: $dbUrl');
    print('Base URL set to: $_baseUrl');
    _db = await Db.create(dbUrl!);

    try {
      await _db?.open();
      inspect(_db);
      print('Connected to database: ${_db?.databaseName}');
    } catch (e) {
      print('Error: $e');
    }
  }

  static Future<String?> doLogin(String username, String password) async {
    await dotenv.load(fileName: ".env");
    print('Making login request to: ${dotenv.env['BASE_URL']}/login');
    
    if (_db == null || !_db!.isConnected) {
      print('Database is not connected. Please initialize the connection first.');
      return 'An unexpected error has occurred.';
    }

    final url = Uri.parse('${dotenv.env['BASE_URL']}/login');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'login': username,
          'password': password,
        }),
      );

      if (response.statusCode == 200) {
        final responseBody = jsonDecode(response.body);
        final token = responseBody['token'] as String?;
        final userId = responseBody['userId'] as String?;

        if (token != null && userId != null) {
          await saveAuthData(token, userId);
          print('Login successful.');
          return null;
        } else {
          print('Token or userId not found in response.');
          return 'Token or userId missing from server response.';
        }
      } else {
        final error = jsonDecode(response.body)['error'] as String?;
        print(error);
        return error;
      }
    } catch (e) {
      print('Error during login: $e');
      return 'An unexpected error has occurred.';
    }
  }

  static Future<String?> doRegister(String firstname, String lastname, String email,
      String username, String password) async {
    await dotenv.load(fileName: ".env");
    
    if (_db == null || !_db!.isConnected) {
      print('Database is not connected. Please initialize the connection first.');
      return 'An unexpected error has occurred.';
    }

    final url = Uri.parse('${dotenv.env['BASE_URL']}/registeruser');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'username': username,
          'password': password,
          'firstName': firstname,
          'lastName': lastname,
          'email': email,
        }),
      );

      if (response.statusCode == 200) {
        print('Registration successful');
        return null;
      } else {
        final error = jsonDecode(response.body)['error'] as String?;
        print(error);
        return error;
      }
    } catch (e) {
      print('Error during registration: $e');
      return 'An unexpected error has occurred.';
    }
  }

  static Future<String?> doCreatePost(String title, String description,
      List<String> tags, double lat, double lng, String? imageUrl) async {
    await dotenv.load(fileName: ".env");
    
    try {
      final token = await getToken();
      final String roundedLat = lat.toStringAsFixed(2);
      final String roundedLng = lng.toStringAsFixed(2);

      final url = Uri.parse('${dotenv.env['BASE_URL']}/createpost');

      Map<String, dynamic> requestBody = {
        'title': title,
        'body': description,
        'tags': tags,
        'latitude': roundedLat,
        'longitude': roundedLng,
      };

      if (imageUrl != null && imageUrl.isNotEmpty) {
        requestBody['image'] = imageUrl;
      }

      final headers = {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer: $token',
      };

      final response = await http.post(
        url,
        headers: headers,
        body: jsonEncode(requestBody),
      );

      if (response.statusCode == 200) {
        print('Post creation successful');
        return null;
      } else {
        final error = jsonDecode(response.body)['error'] as String?;
        print(error);
        return error;
      }
    } catch (e) {
      print('Error creating post: $e');
      return 'An unexpected error has occurred.';
    }
  }

  static Future<void> saveAuthData(String token, String userId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('userToken', token);
    await prefs.setString('userId', userId);
    print('Token and userId saved locally.');
  }

  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('userToken');
  }

  static Future<String?> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('userId');
  }

  static Future<void> clearAuthData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('userToken');
    await prefs.remove('userId');
    print('Token and userId cleared.');
  }
}