import 'dart:async';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../main.dart';
import '../screens/buyer/buyer_home.dart';

class FirebaseApi {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  static final List<RemoteMessage> notificationsList = [];
  static final ValueNotifier<List<RemoteMessage>> notificationsNotifier =
      ValueNotifier<List<RemoteMessage>>([]);
  static final ValueNotifier<bool> unreadNotifier = ValueNotifier<bool>(false);
  static bool hasUnreadNotifications = false;

  StreamSubscription<RemoteMessage>? _onMessageSub;
  StreamSubscription<RemoteMessage>? _onMessageOpenedAppSub;
  StreamSubscription<QuerySnapshot>? _orderStatusSub;

  /// ✅ Initialize Notification Handling
  Future<void> initNotification() async {
    await _firebaseMessaging.requestPermission();

    // ✅ Subscribe to topic "order_updates"
    await _firebaseMessaging.subscribeToTopic("order_updates");

    // ✅ Listen for foreground notifications
    _onMessageSub = FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      _addNotification(message);
    });

    // ✅ Handle notifications tapped (background/terminated)
    _onMessageOpenedAppSub =
        FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      _addNotification(message);
      _navigateToOrders();
    });

    // ✅ Handle app opened via notification (terminated state)
    final RemoteMessage? initialMessage =
        await _firebaseMessaging.getInitialMessage();
    if (initialMessage != null) {
      _addNotification(initialMessage);
      _navigateToOrders();
    }

    // ✅ Firestore Listener: Order Status Updates
    _orderStatusSub = FirebaseFirestore.instance
        .collection('orders')
        .where('status', isEqualTo: 'paid')
        .snapshots()
        .listen((QuerySnapshot snapshot) {
      for (var doc in snapshot.docs) {
        _sendPaymentNotification(doc);
      }
    });
  }

  /// ✅ Add notifications to list and update UI state
  void _addNotification(RemoteMessage message) {
    notificationsList.insert(0, message);
    notificationsNotifier.value = List<RemoteMessage>.from(notificationsList);
    hasUnreadNotifications = true;
    unreadNotifier.value = true;
  }

  /// ✅ Navigate to Orders page when tapped
  void _navigateToOrders() {
    navigatorKey.currentState?.push(
      MaterialPageRoute(
        builder: (context) => BuyerHomeScreen(initialIndex: 2),
      ),
    );
  }

  /// ✅ Trigger notification when payment status changes in Firestore
  Future<void> _sendPaymentNotification(QueryDocumentSnapshot doc) async {
    final String? fcmToken = doc['buyerFCMToken']; // Ensure buyer token is stored
    if (fcmToken == null || fcmToken.isEmpty) return;

    final message = RemoteMessage(
      data: {
        'orderId': doc.id,
        'screen': 'order_details',
      },
      notification: RemoteNotification(
        title: "🎉 Payment Successful!",
        body: "Your payment of ${doc['total']} XAF is confirmed.",
      ),
    );

    await FirebaseMessaging.instance.sendMessage(
      to: fcmToken,
      data: message.data.map((key, value) => MapEntry(key, value.toString())),
    );
  }

  /// ✅ Cleanup resources to prevent memory leaks
  void dispose() {
    _onMessageSub?.cancel();
    _onMessageOpenedAppSub?.cancel();
    _orderStatusSub?.cancel();
  }
}
