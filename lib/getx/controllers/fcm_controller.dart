import 'dart:convert';
import 'dart:io';

import 'package:beat_rush_hour/getx/controllers/routes/home_page_controller.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:beat_rush_hour/general/constants.dart' as constants;
import 'package:beat_rush_hour/getx/controllers/notifications_controller.dart';

typedef void OnTokenRefresh(String token);

class FCMController extends GetxController {
  FirebaseMessaging messaging = FirebaseMessaging.instance;
  NotificationsController notificationsController =
      Get.find<NotificationsController>();

  @override
  Future<void> onInit() async {
    super.onInit();
    await notificationsController.init();
    setUpAndlistenToForegroundMessages();
  }

  Future<AuthorizationStatus> requestPermission() async {
    NotificationSettings settings = await messaging.requestPermission(
      criticalAlert: true,
    );

    return settings.authorizationStatus;
  }

  Future<String?> getDeviceToken() async {
    String? token;

    token = await messaging.getToken(); //TODO: vapidkey required for web

    //TODO: remove print statement
    print(token);
    return token;
  }

  Future<void> setUpAndlistenToForegroundMessages() async {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
      print('Got a message whilst in the foreground!');

      RemoteNotification? notification = message.notification;
      Map<String, dynamic> data = message.data;
      AndroidNotification? android = message.notification?.android;

      //logic for heads up notifications
      if (!kIsWeb) {
        if (notification != null) {
          if (android != null) {
            notificationsController.displayNotification(message);
          } else {
            print('IOS should show the notification automatically.');
          }
        } else if (data.length > 0) {
          //TODO: handle this case
          print('Not implemented for data only notification case');
          // //show notification manually
          // String? title = data[constants.TITLE_IN_NOTIFICATION_DATA];
          // String? body = data[constants.MESSAGE_IN_NOTIFICATION_DATA];

          // if (title != null && body != null) {
          //   RemoteNotification remoteNotification = RemoteNotification(
          //     title: title,
          //     body: body,
          //     android: AndroidNotification(
          //         priority: AndroidNotificationPriority.maximumPriority,
          //         clickAction: 'DEFAULT'),
          //     apple: AppleNotification(),
          //   );

          //   notificationsController.displayNotification(message);
          // } else {
          //   print('No title and no body for notification given from backend!');
          // }
        } else {
          print('There is nothing to show as notification');
        }
      } else {
        print('Web push notifications not supported yet');
      }
    });
  }

  Future<void> checkIfAppOpenedFromNotificationAndAct() async {
    RemoteMessage? initialMessage =
        await FirebaseMessaging.instance.getInitialMessage();
    if (initialMessage != null) {
      print(
          'FCM Notification clicked with id ${initialMessage.messageId} while app was terminated');
      navigateAccordingToMessageType(initialMessage);
    } else {
      FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
        print(
            'FCM Notification clicked with id ${message.messageId} while app was in background');
        navigateAccordingToMessageType(message);
      });
    }
  }

  void navigateAccordingToMessageType(RemoteMessage message) {
    HomePageController homePageController = Get.find<HomePageController>();
    homePageController.setCurrentDuration(
      value: int.tryParse(message.data['duration']),
    );
    homePageController.showDurationDialog();
  }

  void onTokenRefresh(OnTokenRefresh onTokenRefreshCallback) {
    messaging.onTokenRefresh.listen(onTokenRefreshCallback);
  }
}
