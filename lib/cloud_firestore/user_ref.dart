import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:untitled2/model/user_model.dart';
import 'package:untitled2/state/state_management.dart';

Future<UserModel> getUserProfiles(BuildContext context, String phone) async {
  CollectionReference userRef = FirebaseFirestore.instance.collection('User');
  DocumentSnapshot snapshot = await userRef.doc(phone).get();
  if (snapshot.exists)
    {
      var userModel = UserModel.fromJson(snapshot.data()as Map<String, dynamic>);
      context.read(userInformation).state = userModel;
      return userModel;
    }
  else 
    return UserModel();
}