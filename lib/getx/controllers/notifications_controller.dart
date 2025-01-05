import 'dart:convert';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:beat_rush_hour/getx/controllers/fcm_controller.dart';

class NotificationsController extends GetxController {
  late final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;
  late final AndroidNotificationChannel androidNotificationChannel;

  bool alreadyInit = false;

  Future<void> init() async {
    if(alreadyInit) return;
    alreadyInit = true;
    //ios
    await FirebaseMessaging.instance
        .setForegroundNotificationPresentationOptions(
      alert: true, // Required to display a heads up notification
      badge: true,
      sound: true,
    );

    //android
    androidNotificationChannel = AndroidNotificationChannel(
      'beatRushHour', // id
      'constants.NOTIFICATION_CHANNEL_TITLE', // title
      description: 'constants.NOTIFICATION_CHANNEL_DESCRIPTION', // description
      importance: Importance.max,
    );

    flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(androidNotificationChannel);

    FCMController fcmController = Get.find<FCMController>();
    final InitializationSettings initializationSettings = InitializationSettings(
        android: AndroidInitializationSettings('splash'),
        iOS: DarwinInitializationSettings(),
    );

    await flutterLocalNotificationsPlugin.initialize(initializationSettings,
        onDidReceiveNotificationResponse: (NotificationResponse _response) {
          print('Notification tapped in foreground');
          String? _payload = _response.payload;
          if(_payload != null) {
            Map<String, dynamic> _payloadMap = (jsonDecode(_payload));

            fcmController.navigateAccordingToMessageType(RemoteMessage(data: _payloadMap));
          }
        }
    );
  }

  void displayNotification(RemoteMessage message) {
    if(message.notification == null) {
      print('Notification field is null in displayNotification');
      return;
    }

    if (!kIsWeb) {
      RemoteNotification notification = message.notification!; //should not be null due to condition above
      flutterLocalNotificationsPlugin.show(
          notification.hashCode,
          notification.title,
          notification.body,
          NotificationDetails(
            android: AndroidNotificationDetails(
              androidNotificationChannel.id,
              androidNotificationChannel.name,
              channelDescription: androidNotificationChannel.description,
              // icon: 'launch_background',
              importance: Importance.max,
              priority: Priority.max,
            ),
            iOS: DarwinNotificationDetails(
              presentSound: true,
              interruptionLevel:InterruptionLevel.timeSensitive,
            ),
          ),
        payload: jsonEncode(message.data),
      );
    } else {
      print('Web push notifications not supported yet');
    }
  }
}
