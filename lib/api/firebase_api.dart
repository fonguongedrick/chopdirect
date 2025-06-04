import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';

import '../main.dart';
import '../screens/buyer/buyer_home.dart';
class FirebaseApi {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  // List to store notifications
  static List<RemoteMessage> notificationsList = [];

  // ValueNotifier to inform listeners that the notifications list has changed
  static final ValueNotifier<List<RemoteMessage>> notificationsNotifier = ValueNotifier([]);

  // (Optional) Unread flag and notifier if you want a dot on the nav bar
  static bool hasUnreadNotifications = false;
  static final ValueNotifier<bool> unreadNotifier = ValueNotifier<bool>(false);

  Future<void> initNotification() async {
    await _firebaseMessaging.requestPermission();

    // Subscribe to topic
    FirebaseMessaging.instance.subscribeToTopic("order_updates");

    // Foreground notifications
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print("Foreground Notification: ${message.notification?.title}");

      // Add the notification to the top of the list
      notificationsList.insert(0, message);
      notificationsNotifier.value = List.from(notificationsList);  // Force a new list for listeners

      // Mark as unread
      hasUnreadNotifications = true;
      unreadNotifier.value = true;
    });

    // When the notification is tapped in background/terminated states
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      // Also add it to the list if desired
      notificationsList.insert(0, message);
      notificationsNotifier.value = List.from(notificationsList);
      hasUnreadNotifications = true;
      unreadNotifier.value = true;

      navigatorKey.currentState?.push(MaterialPageRoute(
        builder: (context) => BuyerHomeScreen(initialIndex: 2),
      ));
    });

    FirebaseMessaging.instance.getInitialMessage().then((RemoteMessage? message) {
      if (message != null) {
        notificationsList.insert(0, message);
        notificationsNotifier.value = List.from(notificationsList);
        hasUnreadNotifications = true;
        unreadNotifier.value = true;

        navigatorKey.currentState?.push(MaterialPageRoute(
          builder: (context) => BuyerHomeScreen(initialIndex: 2),
        ));
      }
    });
  }
}
