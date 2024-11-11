import 'dart:developer';
import 'package:mongo_dart/mongo_dart.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class MongoDatabase {
  static connect() async {
    await dotenv.load(fileName: ".env");
    var DB_URL = dotenv.env['DB_URL'];
    var userCollection = dotenv.env['USERS_COLLECTION'];

    var db = await Db.create(DB_URL!);
    try {
      await db.open();
      inspect(db);
      print('Connected to database: ${db.databaseName}');

      var collection = db.collection(userCollection!);
      var information = await collection.findOne(where.eq('username', 'test'));

      // Check if user is found
      if (information != null) {
        print('User found: $information');
      } else {
        print('No user found with username "test"');
      }


    } catch (e) {
      print('Error: $e');
    } finally {
      await db.close();
    }
  }

  static signUserIn() async {


  }




}