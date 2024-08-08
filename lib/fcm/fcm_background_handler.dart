import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

Future<void> firebaseBackgroundHandler(RemoteMessage message)
async {
  await Firebase.initializeApp();
  if (kDebugMode) {
    print('Пиши тут всё, что хочешь');
  }
}