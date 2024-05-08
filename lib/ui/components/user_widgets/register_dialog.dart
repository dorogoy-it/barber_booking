import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:rflutter_alert/rflutter_alert.dart';

void showRegisterDialog(BuildContext context, CollectionReference userRef,
    GlobalKey<ScaffoldState> scaffoldState) {
  var nameController = TextEditingController();
  var addressController = TextEditingController();
  Alert(
    context: context,
    title: 'Обновить данные',
    content: Column(
      children: [
        TextField(
          decoration: const InputDecoration(
              icon: Icon(Icons.account_circle), labelText: 'Имя'),
          controller: nameController,
        ),
        TextField(
          decoration:
              const InputDecoration(icon: Icon(Icons.home), labelText: 'Адрес'),
          controller: addressController,
        )
      ],
    ),
    buttons: [
      DialogButton(
        child: const Text('Отмена'),
        onPressed: () => Navigator.pop(context),
      ),
      DialogButton(
        child: const Text('Обновить'),
        onPressed: () {
          //update to server
          userRef.doc(FirebaseAuth.instance.currentUser?.phoneNumber).set({
            'name': nameController.text,
            'address': addressController.text,
            'phone': FirebaseAuth.instance.currentUser!.phoneNumber,
            'id': FirebaseAuth.instance.currentUser!.uid,
          }).then((value) async {
            Navigator.pop(context);
            ScaffoldMessenger.of(scaffoldState.currentContext!)
                .showSnackBar(const SnackBar(
              content: Text('Данные успешно обновлены!'),
            ));
            await Future.delayed(const Duration(seconds: 1), () {
              Navigator.pushNamedAndRemoveUntil(
                  context, '/home', (route) => false);
            });
          }).catchError((e) {
            Navigator.pop(context);
            ScaffoldMessenger.of(scaffoldState.currentContext!)
                .showSnackBar(SnackBar(content: Text('$e')));
          });
        },
      ),
    ],
  ).show();
}
