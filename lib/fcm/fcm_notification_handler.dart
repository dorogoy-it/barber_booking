import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:untitled2/main.dart';

void initFirebaseMessagingHandler(AndroidNotificationChannel channel) {
  FirebaseMessaging.onMessage.listen((RemoteMessage remoteMessage) {
    RemoteNotification? notification = remoteMessage.notification;
    AndroidNotification? android = remoteMessage.notification?.android;
    if (notification != null && android != null) {
      flutterLocalNotificationsPlugin!.show(
          notification.hashCode,
          notification.title,
          notification.body,
          NotificationDetails(
              android: AndroidNotificationDetails(
                channel.id,
                channel.name,
                icon: 'launch_background',
          )));
    }
  });

  FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage remoteMessage) {
    //here you can add navigation code to push with message
    //Navigation...Куда-нибудь

  });
}
