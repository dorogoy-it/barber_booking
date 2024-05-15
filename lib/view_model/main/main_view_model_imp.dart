import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_auth_ui/flutter_auth_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:untitled2/view_model/main/main_view_model.dart';
import '../../model/user_model.dart';
import '../../state/state_management.dart';
import '../../ui/components/user_widgets/register_dialog.dart';
import '../../ui/home_screen.dart';

class MainViewModelImp implements MainViewModel {
  @override
  processLogin(WidgetRef ref, BuildContext context,
      GlobalKey<ScaffoldState> scaffoldState) async {
    var user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      try {
        await FlutterAuthUi.startUi(
            items: [AuthUiProvider.phone],
            tosAndPrivacyPolicy: const TosAndPrivacyPolicy(
                tosUrl: 'https://google.com',
                privacyPolicyUrl: 'https://google.com'),
            androidOption: const AndroidOption(
                enableSmartLock: false, showLogo: true, overrideTheme: true));

        // refresh state
        ref.read(userLogged.notifier).state = FirebaseAuth.instance.currentUser;

        // check if the user exists in the 'User' collection
        CollectionReference userRef = FirebaseFirestore.instance.collection('User');
        DocumentSnapshot snapshotUser = await userRef.doc(FirebaseAuth.instance.currentUser!.phoneNumber).get();

        if (snapshotUser.exists) {
          // user exists, navigate to home
          UserModel userModel = UserModel.fromJson(snapshotUser.data() as Map<String, dynamic>);

          // Сохраните userModel в провайдере userInformation
          ref.read(userInformation.notifier).state = userModel;

          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => HomePage()),
                (Route<dynamic> route) => false,
          );

          if (FirebaseAuth.instance.currentUser != null) {
            FirebaseMessaging.instance.subscribeToTopic(FirebaseAuth.instance.currentUser!.uid)
                .then((value) => print('Успех'));
          } else {
            print('Пользователь не авторизован');
          }
        } else {
          // user does not exist, show Alert Dialog for user input
          showRegisterDialog(context, userRef, scaffoldState);
        }
      } catch (e) {
        ScaffoldMessenger.of(scaffoldState.currentContext!)
            .showSnackBar(SnackBar(content: Text('$e')));
      }
    } else {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => HomePage()),
            (Route<dynamic> route) => false,
      );
    }
  }
}
