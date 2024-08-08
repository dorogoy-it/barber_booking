import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:untitled2/view_model/main/main_view_model.dart';
import '../../decorations.dart';
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
        // Открываем экран ввода номера телефона
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                PhoneInputScreen(
                  actions: [
                    SMSCodeRequestedAction((context, action, flowKey, phone) {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) =>
                              SMSCodeInputScreen(
                                actions: [
                                  AuthStateChangeAction<SignedIn>((context,
                                      state) async {
                                    // После успешной аутентификации
                                    user = FirebaseAuth.instance.currentUser;
                                    if (user != null) {
                                      // Обновляем состояние
                                      ref
                                          .read(userLogged.notifier)
                                          .state = user;

                                      // Проверяем, существует ли пользователь в коллекции 'User'
                                      CollectionReference userRef = FirebaseFirestore
                                          .instance.collection('User');
                                      DocumentSnapshot snapshotUser = await userRef
                                          .doc(user?.phoneNumber).get();

                                      if (snapshotUser.exists) {
                                        // Пользователь существует, переходим на домашнюю страницу
                                        UserModel userModel = UserModel
                                            .fromJson(
                                            snapshotUser.data() as Map<
                                                String,
                                                dynamic>);
                                        ref
                                            .read(userInformation.notifier)
                                            .state = userModel;

                                        Navigator.of(context)
                                            .pushAndRemoveUntil(
                                          MaterialPageRoute(
                                              builder: (context) => HomePage()),
                                              (Route<dynamic> route) => false,
                                        );

                                        FirebaseMessaging.instance
                                            .subscribeToTopic(user!.uid)
                                            .then((value) => print('Успех'));
                                      } else {
                                        // Пользователь не существует, показываем диалог регистрации
                                        showRegisterDialog(
                                            context, userRef, scaffoldState);
                                      }
                                    }
                                  })
                                ],
                                flowKey: flowKey,
                                action: action,
                              ),
                        ),
                      );
                    }),
                  ],
                  headerBuilder: headerIcon(Icons.phone),
                  sideBuilder: sideIcon(Icons.phone),
                ),
          ),
        );
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
