import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:chopdirect/api/firebase_api.dart';

class Notifications extends StatefulWidget {
  const Notifications({Key? key}) : super(key: key);

  @override
  State<Notifications> createState() => _NotificationsState();
}

class _NotificationsState extends State<Notifications> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Notifications"),
        centerTitle: true,
      ),
      body: ValueListenableBuilder<List<RemoteMessage>>(
        valueListenable: FirebaseApi.notificationsNotifier,
        builder: (context, notifications, _) {
          if (notifications.isEmpty) {
            return const Center(child: Text("No notification data found"));
          } else {
            return ListView.builder(
              itemCount: notifications.length,
              itemBuilder: (context, index) {
                final message = notifications[index];
                return ListTile(
                  title: Text(message.notification?.title ?? "No Title"),
                  subtitle: Text(message.notification?.body ?? "No Body"),
                );
              },
            );
          }
        },
      ),
    );
  }
}
