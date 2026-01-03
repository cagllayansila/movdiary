import 'package:flutter/material.dart';
import '../models/notification_model.dart';

class NotificationsScreen extends StatelessWidget {
  final List<AppNotification> notifications;
  final VoidCallback onRead;

  NotificationsScreen({required this.notifications, required this.onRead});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Bildirimler'),
        elevation: 0,
        actions: [
          TextButton(
            onPressed: () {
              onRead();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Tüm bildirimler okundu olarak işaretlendi')),
              );
            },
            child: Text(
              'Tümünü Okundu İşaretle',
              style: TextStyle(color: Colors.purple),
            ),
          ),
        ],
      ),
      body: notifications.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.notifications_none, size: 80, color: Colors.grey),
                  SizedBox(height: 16),
                  Text('Henüz bildirim yok', style: TextStyle(color: Colors.grey, fontSize: 16)),
                ],
              ),
            )
          : ListView.builder(
              padding: EdgeInsets.all(8),
              itemCount: notifications.length,
              itemBuilder: (context, index) {
                final notification = notifications[index];
                return Card(
                  color: notification.isRead ? null : Colors.purple.withOpacity(0.05),
                  margin: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.purple,
                      child: Text(
                        notification.user[0],
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ),
                    title: RichText(
                      text: TextSpan(
                        style: TextStyle(
                          color: Theme.of(context).textTheme.bodyLarge?.color,
                          fontSize: 14,
                        ),
                        children: [
                          TextSpan(
                            text: notification.user,
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          TextSpan(text: ' ${notification.action}'),
                          if (notification.movieTitle.isNotEmpty)
                            TextSpan(
                              text: ' "${notification.movieTitle}"',
                              style: TextStyle(fontStyle: FontStyle.italic),
                            ),
                        ],
                      ),
                    ),
                    subtitle: Text(
                      notification.time,
                      style: TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                    trailing: !notification.isRead
                        ? Container(
                            width: 10,
                            height: 10,
                            decoration: BoxDecoration(
                              color: Colors.purple,
                              shape: BoxShape.circle,
                            ),
                          )
                        : null,
                  ),
                );
              },
            ),
    );
  }
}