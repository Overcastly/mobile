import 'dart:developer';
import 'package:mongo_dart/mongo_dart.dart';
import '../mongoconsts.dart';

class MongoDatabase {
  static connect() async {
    var db = await Db.create(DB_URL);
    await db.open();
    inspect(db);
    var status = db.serverStatus();
    print(status);
    var collection = db.collection(USERS_COLLECTION);
    print(await collection.find({'lastName': 'Smith'}).toList());
  }
}