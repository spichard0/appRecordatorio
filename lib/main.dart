import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;
import 'screen/task_screen.dart'; // Ajusta la ruta según tu estructura de proyecto

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializar la librería de notificaciones locales
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  var initializationSettingsAndroid =
      AndroidInitializationSettings('app_icon');
  var initializationSettingsIOS = IOSInitializationSettings();
  var initializationSettingsMacOS = MacOSInitializationSettings();
  var initializationSettings = InitializationSettings(
    android: initializationSettingsAndroid,
    iOS: initializationSettingsIOS,
    macOS: initializationSettingsMacOS,
  );
  flutterLocalNotificationsPlugin.initialize(initializationSettings);

  // Inicializar zonas horarias
  tzdata.initializeTimeZones();
  tz.setLocalLocation(tz.getLocation('America/New_York')); // Ajusta la zona horaria según tu ubicación

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Recordatorios App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: TaskScreen(),
    );
  }
}
