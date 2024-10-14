import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:untitled2/cloud_firestore/app_data_ref.dart';

import '../model/notification_payload_model.dart';

Future<Map<String, dynamic>> sendNotification(NotificationPayloadModel notificationPayloadModel) async {
  try {
    var dataSubmit = jsonEncode(notificationPayloadModel);

    AccessTokenFirebase accessTokenGetter = AccessTokenFirebase();
    String newToken = await accessTokenGetter.getAccessToken();
    if (kDebugMode) {
      print("Современный $newToken");
    }

    var result = await Dio().post(
        '${dotenv.env["RESULT"]}',
        options: Options(
            headers: {
              Headers.acceptHeader: 'application/json',
              Headers.contentTypeHeader: 'application/json',
              'Authorization': 'Bearer $newToken'
            },
            sendTimeout: const Duration(milliseconds: 30000),
            receiveTimeout: const Duration(milliseconds: 30000),
            followRedirects: false,
            validateStatus: (status) => true // Позволяет получить ответ с любым статусом
        ),
        data: dataSubmit
    );

    if (result.statusCode == 200) {
      return {'success': true};
    } else {
      if (kDebugMode) {
        print('Full response: ${result.data}');
      }
      return {
        'success': false,
        'error': 'HTTP Error ${result.statusCode}: ${result.statusMessage}',
        'details': result.data.toString()
      };
    }
  } catch (e) {
    if (kDebugMode) {
      print('Exception details: $e');
    }
    return {'success': false, 'error': e.toString()};
  }
}

