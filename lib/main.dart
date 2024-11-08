import 'package:flutter/material.dart';
import 'package:mobile/mainwrapper.dart';
import 'package:mobile/views/login/login_view.dart';
import 'mongodb.dart';

Future<void> main() async {
  //WidgetsFlutterBinding.ensureInitialized();
  //await MongoDatabase.connect();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: LoginView(),
    );
  }
}

