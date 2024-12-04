import 'package:flutter/material.dart';
import 'package:mobile/views/login/login_view.dart';
import 'mongodb.dart';

void main() async {
  debugPrint('Starting app');
  WidgetsFlutterBinding.ensureInitialized();
  debugPrint('Flutter binding initialized');
  
  try {
    await MongoDatabase.connect();
    debugPrint('MongoDB connected');
  } catch (e) {
    debugPrint('MongoDB connection error: $e');
  }

  debugPrint('Running app');
  runApp(const MyApp());
  debugPrint('App started');
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: const ColorScheme.light(
          primary: Colors.black,
          secondary: Colors.black,
          tertiary: Colors.black,
          surfaceTint: Colors.transparent,
        ),
        cardTheme: CardTheme(
          color: Colors.grey[50],
          elevation: 1,
        ),
        sliderTheme: const SliderThemeData(
          activeTrackColor: Colors.black,
          thumbColor: Colors.black,
          overlayColor: Color(0x29000000),
          inactiveTrackColor: Color(0x3D000000),
        ),
        chipTheme: const ChipThemeData(
          backgroundColor: Colors.black,
          labelStyle: TextStyle(color: Colors.white),
          secondaryLabelStyle: TextStyle(color: Colors.white),
          selectedColor: Colors.black,
          disabledColor: Colors.grey,
          padding: EdgeInsets.all(2),
        ),
        progressIndicatorTheme: const ProgressIndicatorThemeData(
          color: Colors.black,
        ),
        navigationBarTheme: NavigationBarThemeData(
          indicatorColor: Colors.black,
          height: 65,
          labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
          iconTheme: WidgetStateProperty.resolveWith((states) {

            if (states.contains(WidgetState.selected)) {
              return const IconThemeData(color: Colors.white);
            }
            return const IconThemeData(color: Colors.black);
          }),
          labelTextStyle: WidgetStateProperty.all(
            const TextStyle(
              color: Colors.black, // Always black text
              fontSize: 12,
              fontWeight: FontWeight.normal,
            ),
          ),
        ),
      ),
      home: LoginView(),
    );
  }
}