import 'package:flutter/material.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'screens/menu_screen.dart';
import 'screens/signup_screen.dart';
import 'screens/login_screen.dart';
import 'screens/smart_settings_screen.dart';
import 'screens/contact_us_screen.dart';
import 'screens/web_page.dart';
import 'screens/dashboard_screen.dart';
import 'screens/device_token_screen.dart';



void main() {
  WidgetsFlutterBinding.ensureInitialized();
  FlutterForegroundTask.initCommunicationPort();
  runApp(
    MyApp(),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'WiFi Drip Irrigation',
      debugShowCheckedModeBanner: false, // <-- remove debug banner
      initialRoute: '/',
      routes: {
        '/': (context) => MenuScreen(),
        '/signup': (context) => SignupScreen(),
        '/login': (context) => LoginScreen(),
        '/smart': (context) => SmartSettingsScreen(),
        '/contact': (_) => ContactUsScreen(),
        '/dashboard': (context) => DashboardScreen(),
        '/device-token': (context) => DeviceTokenScreen(),

      },
    );
  }
}
