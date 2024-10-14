import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:googleapis_auth/auth_io.dart';

class AccessTokenFirebase {
  static String firebaseMessagingScope = "${dotenv.env["FIREBASE_MESSAGING_SCOPE"]}";

  Future<String> getAccessToken() async {
    final client = await clientViaServiceAccount(
        ServiceAccountCredentials.fromJson(
            {
              "type": "${dotenv.env["TYPE"]}",
              "project_id": "${dotenv.env["PROJECT_ID"]}",
              "private_key_id": "${dotenv.env["PRIVATE_KEY_ID"]}",
              "private_key": "-----BEGIN PRIVATE KEY-----\n${dotenv.env["PRIVATE_KEY_1"]}\n${dotenv.env["PRIVATE_KEY_2"]}\n${dotenv.env["PRIVATE_KEY_3"]}\n${dotenv.env["PRIVATE_KEY_4"]}\n${dotenv.env["PRIVATE_KEY_5"]}\n${dotenv.env["PRIVATE_KEY_6"]}\n${dotenv.env["PRIVATE_KEY_7"]}\n${dotenv.env["PRIVATE_KEY_8"]}\n${dotenv.env["PRIVATE_KEY_9"]}\n${dotenv.env["PRIVATE_KEY_10"]}\n${dotenv.env["PRIVATE_KEY_11"]}\n${dotenv.env["PRIVATE_KEY_12"]}\n${dotenv.env["PRIVATE_KEY_13"]}\n${dotenv.env["PRIVATE_KEY_14"]}\n${dotenv.env["PRIVATE_KEY_15"]}\n${dotenv.env["PRIVATE_KEY_16"]}\n${dotenv.env["PRIVATE_KEY_17"]}\n${dotenv.env["PRIVATE_KEY_18"]}\n${dotenv.env["PRIVATE_KEY_19"]}\n${dotenv.env["PRIVATE_KEY_20"]}\n${dotenv.env["PRIVATE_KEY_21"]}\n${dotenv.env["PRIVATE_KEY_22"]}\n${dotenv.env["PRIVATE_KEY_23"]}\n${dotenv.env["PRIVATE_KEY_24"]}\n${dotenv.env["PRIVATE_KEY_25"]}\n${dotenv.env["PRIVATE_KEY_26"]}\n-----END PRIVATE KEY-----\n",
              "client_email": "${dotenv.env["CLIENT_EMAIL"]}",
              "client_id": "${dotenv.env["CLIENT_ID"]}",
              "auth_uri": "${dotenv.env["AUTH_URI"]}",
              "token_uri": "${dotenv.env["TOKEN_URI"]}",
              "auth_provider_x509_cert_url": "${dotenv.env["AUTH_PROVIDER_X509_CERT_URL"]}",
              "client_x509_cert_url": "${dotenv.env["CLIENT_X509_CERT_URL"]}",
              "universe_domain": "${dotenv.env["UNIVERSE_DOMAIN"]}"
            }
        ), [firebaseMessagingScope]
    );

    final accessToken = client.credentials.accessToken.data;

    return accessToken;
  }
}
