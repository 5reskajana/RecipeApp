import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

import 'screens/categories_screen.dart';
import 'screens/meal_detail_screen.dart';
import 'services/api_service.dart';

final FlutterLocalNotificationsPlugin notificationsPlugin = FlutterLocalNotificationsPlugin();

Future<void> _backgroundMessageHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  FirebaseMessaging.onBackgroundMessage(_backgroundMessageHandler);

  tz.initializeTimeZones();

  const AndroidInitializationSettings androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
  const InitializationSettings initSettings = InitializationSettings(android: androidInit);

  await notificationsPlugin.initialize(
    initSettings,
    onDidReceiveNotificationResponse: (NotificationResponse response) async {
      _openRandomRecipe();
    },
  );

  await _scheduleDailyRecipeNotification();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  static final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
      title: 'Recipes App',
      theme: ThemeData(primarySwatch: Colors.deepOrange),
      home: const CategoriesScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

Future<void> _openRandomRecipe() async {
  final meal = await ApiService.randomMeal();
  final context = MyApp.navigatorKey.currentState?.context;
  if (meal != null && context != null) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => MealDetailScreen(mealDetail: meal)),
    );
  }
}

Future<void> _scheduleDailyRecipeNotification() async {
  final androidDetails = AndroidNotificationDetails(
    'daily_recipe_channel',
    'Daily Recipe',
    channelDescription: 'Daily meal discovery',
    importance: Importance.max,
    priority: Priority.high,
  );

  await notificationsPlugin.zonedSchedule(
    0,
    '🍲 Recipe of the Day',
    'Tap to discover a random meal!',
    _scheduleTime(10, 0),
    NotificationDetails(android: androidDetails),
    uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
    matchDateTimeComponents: DateTimeComponents.time,
  );
}

tz.TZDateTime _scheduleTime(int hour, int minute) {
  tz.setLocalLocation(tz.getLocation('Europe/Berlin'));
  final now = tz.TZDateTime.now(tz.local);
  var scheduled = tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, minute);
  if (scheduled.isBefore(now)) {
    scheduled = scheduled.add(const Duration(days: 1));
  }
  return scheduled;
}
