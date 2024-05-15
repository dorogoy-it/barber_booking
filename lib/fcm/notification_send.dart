import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:untitled2/cloud_firestore/app_data_ref.dart';

import '../model/notification_payload_model.dart';

Future<bool> sendNotification(
    NotificationPayloadModel notificationPayloadModel) async {
  var dataSubmit = jsonEncode(notificationPayloadModel);

  AccessTokenFirebase accessTokenGetter = AccessTokenFirebase();
  String newToken = await accessTokenGetter.getAccessToken();
  print("Современный $newToken");

  var result = await Dio().post('https://fcm.googleapis.com/v1/projects/lastchance-ec817/messages:send',
      options: Options(
          headers: {
            Headers.acceptHeader: 'application/json',
            Headers.contentTypeHeader: 'application/json',
            'Authorization': 'Bearer $newToken'
          },
          sendTimeout: const Duration(milliseconds: 30000),
          receiveTimeout: const Duration(milliseconds: 30000),
          followRedirects: false,
          validateStatus: (status) => status! < 500),
      data: dataSubmit);
  return result.statusCode == 200 ? true : false;
}
