import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tzdata;
import 'package:flutter/material.dart'; // Used for the BuildContext

class LocalNotificationService {
  final FlutterLocalNotificationsPlugin _localNotifications =
  FlutterLocalNotificationsPlugin();

  Future<void> initialize(BuildContext context, Function(String) onNotificationTap) async {
    // 1. Initialize Time Zones
    tzdata.initializeTimeZones();
    // Set the local location (important for accurate scheduling)
    tz.setLocalLocation(tz.getLocation('Europe/Skopje')); // Use your local timezone

    // 2. Platform-Specific Initialization Settings
    const initializationSettingsAndroid =
    AndroidInitializationSettings('@mipmap/ic_launcher');
    const initializationSettingsIOS = DarwinInitializationSettings();
    const initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );

    // 3. Handle Notification Tap (When the app is opened from the notification)
    await _localNotifications.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        if (response.payload != null) {
          // The payload will contain a simple command, e.g., 'open_random'
          onNotificationTap(response.payload!);
        }
      },
    );
  }

  // --- CORE FUNCTION: SCHEDULE DAILY REPEATING NOTIFICATION ---
  Future<void> scheduleDailyRecipeReminder({
    required TimeOfDay time,
    required String payload,
  }) async {
    const int notificationId = 1; // Unique ID for this specific daily reminder

    final now = tz.TZDateTime.now(tz.local);

    // Calculate the next target time for the notification
    var scheduledDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      time.hour,
      time.minute,
    );

    // If the scheduled time is already past today, schedule it for tomorrow
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    const androidDetails = AndroidNotificationDetails(
      'daily_recipe_channel',
      'Daily Recipe Reminder',
      channelDescription: 'Reminds you to check out a random recipe.',
      importance: Importance.max,
      priority: Priority.high,
    );
    const notificationDetails = NotificationDetails(android: androidDetails);

    await _localNotifications.zonedSchedule(
      notificationId,
      '🎉 Рецепт на Денот!',
      'Кликнете за да го видите денешниот рандом рецепт!',
      scheduledDate,
      notificationDetails,
      uiLocalNotificationDateInterpretation:
      UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time, // Key for daily repeat!
      payload: payload,
    );

    print('Daily reminder scheduled for ${time.hour}:${time.minute}');
  }
}