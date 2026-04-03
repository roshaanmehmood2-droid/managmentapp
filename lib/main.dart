import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:flutter_timezone/flutter_timezone.dart';
import 'providers/task_provider.dart';
import 'screens/home_screen.dart';
import 'services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize timezone database
  tz.initializeTimeZones();

  try {
    // In flutter_timezone ^5.0.2, getLocalTimezone() returns a TimezoneInfo object
    // which has a property 'id' or 'identifier'
    final timezoneInfo = await FlutterTimezone.getLocalTimezone();
    // According to current documentation, it's often a String directly or has .id
    // But error said it's TimezoneInfo. We try 'id' or cast to dynamic to check.
    final String currentTimeZone = (timezoneInfo as dynamic).id ?? (timezoneInfo as dynamic).name ?? 'UTC';
    
    tz.setLocalLocation(tz.getLocation(currentTimeZone));
    
    await NotificationService().init();
  } catch (e) {
    debugPrint("Initialization Error: $e");
    try {
      tz.setLocalLocation(tz.getLocation('UTC'));
    } catch (_) {}
  }

  runApp(
    ChangeNotifierProvider(
      create: (context) => TaskProvider()..loadTasks(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CORE_TASK',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF0A0A0A),
        primaryColor: const Color(0xFF00E5FF),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF00E5FF),
          secondary: Color(0xFF00E5FF),
          surface: Color(0xFF121212),
        ),
        textTheme: const TextTheme(
          displayLarge: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, letterSpacing: 1.5),
          bodyLarge: TextStyle(color: Colors.white70),
        ),
      ),
      home: const HomeScreen(),
    );
  }
}
