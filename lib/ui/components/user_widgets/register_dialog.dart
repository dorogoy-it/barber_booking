import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

void showRegisterDialog(BuildContext context, CollectionReference userRef,
    GlobalKey<ScaffoldState> scaffoldState) {
  var nameController = TextEditingController();
  var addressController = TextEditingController();

  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return PopScope<Object?>(
        canPop: true,
        onPopInvokedWithResult: (bool didPop, Object? result) async {
          if (nameController.text.trim().isEmpty || addressController.text.trim().isEmpty) {
            ScaffoldMessenger.of(scaffoldState.currentContext!).showSnackBar(
              const SnackBar(
                content: Text('Нельзя закрывать окно, если не хочешь вводить данные'),
              ),
            );
          } else {
            Navigator.of(context).pop();
          }
        },
        child: AlertDialog(
          title: const Text('Обновить данные'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                decoration: const InputDecoration(
                  icon: Icon(Icons.account_circle),
                  labelText: 'Имя',
                ),
                controller: nameController,
              ),
              TextField(
                decoration: const InputDecoration(
                  icon: Icon(Icons.home),
                  labelText: 'Адрес',
                ),
                controller: addressController,
              ),
            ],
          ),
          actions: [
            TextButton(
              child: const Text('Обновить'),
              onPressed: () {
                if (nameController.text.trim().isEmpty || addressController.text.trim().isEmpty) {
                  ScaffoldMessenger.of(scaffoldState.currentContext!).showSnackBar(
                    const SnackBar(
                      content: Text('Пожалуйста, введите корректные данные!'),
                    ),
                  );
                } else {
                  userRef.doc(FirebaseAuth.instance.currentUser?.phoneNumber).set({
                    'name': nameController.text.trim(),
                    'address': addressController.text.trim(),
                    'phone': FirebaseAuth.instance.currentUser!.phoneNumber,
                    'id': FirebaseAuth.instance.currentUser!.uid,
                  }).then((value) async {
                    if (context.mounted) {
                      Navigator.pop(context);
                    }
                    ScaffoldMessenger.of(scaffoldState.currentContext!).showSnackBar(
                      const SnackBar(
                        content: Text('Данные успешно обновлены!'),
                      ),
                    );
                    await Future.delayed(const Duration(seconds: 1));
                    Navigator.of(scaffoldState.currentContext!).pushNamedAndRemoveUntil('/home', (route) => false);
                  }).catchError((e) {
                    if (context.mounted) {
                      Navigator.pop(context);
                    }
                    ScaffoldMessenger.of(scaffoldState.currentContext!).showSnackBar(
                      SnackBar(content: Text('$e')),
                    );
                  });
                }
              },
            ),
          ],
        ),
      );
    },
  );
}