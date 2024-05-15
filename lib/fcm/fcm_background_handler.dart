import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

Future<void> firebaseBackgroundHandler(RemoteMessage message)
async {
  await Firebase.initializeApp();
  print('Пиши тут всё, что хочешь');
}