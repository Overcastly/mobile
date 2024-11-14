import 'dart:convert';
import 'dart:developer';
import 'package:mongo_dart/mongo_dart.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class MongoDatabase {

  static Db? _db;
  static String? _userCollection;
  static String? _postsCollection;
  static String? _baseUrl;

  //ESTABLISH CONNECTION TO MONGO ON APP START
  static connect() async {
    await dotenv.load(fileName: ".env");
    var DB_URL = dotenv.env['DB_URL'];
    _userCollection = dotenv.env['USERS_COLLECTION']!;
    _postsCollection = dotenv.env['POSTS_COLLECTION']!;
    _baseUrl = dotenv.env['BASE_URL'];
    _db = await Db.create(DB_URL!);

    try {
      await _db?.open();
      inspect(_db);
      print('Connected to database: ${_db?.databaseName}');

    } catch (e) {
      print('Error: $e');
    }
  }

  //LOGIN
  static Future<String?> doLogin(String username, String password) async {
    if (_db == null || !_db!.isConnected) {
      print('Database is not connected. Please initialize the connection first.');
      return 'An unexpected error has occurred.';
    }

    final url = Uri.parse('$_baseUrl/login');

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
        print('Login successful');
        return null;
      } else {
        final error = jsonDecode(response.body)['error'] as String?;
        print(error);
        return error;
      }

    } catch(e) {
      print('Error during login: $e');
      return 'An unexpected error has occurred.';
    }
  }

  //REGISTER
  static Future<String?> doRegister(String firstname, String lastname, String email, String username, String password) async {
    if (_db == null || !_db!.isConnected) {
      print('Database is not connected. Please initialize the connection first.');
      return 'An unexpected error has occurred.';
    }

    final url = Uri.parse('$_baseUrl/registeruser');

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

    } catch(e) {
      print('Error during registration: $e');
      return 'An unexpected error has occurred.';
    }
  }






}