import 'package:mongo_dart/mongo_dart.dart';
import '../mongoconsts.dart';

class MongoDatabase {
  static connect() async {
    var db = await Db.create(DB_URL);
    await db.open();
  }
}