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
        actions: [
          IconButton(
            icon: const Icon(Icons.clear_all),
            onPressed: () {
              // Clear the notifications list and update notifiers
              FirebaseApi.notificationsList.clear();
              FirebaseApi.notificationsNotifier.value =
                  List.from(FirebaseApi.notificationsList);
              FirebaseApi.hasUnreadNotifications = false;
              FirebaseApi.unreadNotifier.value = false;
            },
          ),
        ],
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
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                  child: ListTile(
                    leading: const Icon(Icons.notifications),
                    title: Text(message.notification?.title ?? "No Title"),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(message.notification?.body ?? "No Body"),
                        if (message.data.isNotEmpty)
                          Text(
                            "Data: ${message.data}",
                            style: const TextStyle(fontSize: 12),
                          ),
                      ],
                    ),
                    isThreeLine: message.data.isNotEmpty,
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }
}
