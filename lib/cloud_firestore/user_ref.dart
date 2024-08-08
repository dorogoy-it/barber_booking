import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../model/booking_model.dart';
import '../model/user_model.dart';
import '../state/state_management.dart';

Future<UserModel> getUserProfiles(WidgetRef ref, BuildContext context, String phone) async {
  CollectionReference userRef = FirebaseFirestore.instance.collection('User');
  DocumentSnapshot snapshot = await userRef.doc(phone).get();
  if (snapshot.exists) {
    final data = snapshot.data() as Map<String,dynamic>;
    var userModel = UserModel.fromJson(data);
    ref.read(userInformation.notifier).state = userModel;

    // Сохраняем роль пользователя в SharedPreferences
    await saveUserRole(userModel);

    return userModel;
  }
  else {
    return UserModel(name: '', address: '', phone: '', id: '');
  }
}

Future<void> saveUserRole(UserModel userModel) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setBool('isStaff', userModel.isStaff);
  await prefs.setBool('isAdmin', userModel.isAdmin);
}

Future<List<UserModel>> getUserProfilesToAdmin(BuildContext context, String phone) async {
  var users = List<UserModel>.empty(growable: true);
  var usersRef = FirebaseFirestore.instance.collection('User');
  var snapshot = await usersRef.get();
  for (var element in snapshot.docs) {
    var user = UserModel.fromJson(element.data());
    // Проверяем, что пользователь не является администратором или модератором
    if (user.isStaff == false && user.isAdmin == false) {
      users.add(user);
    }
  }
  return users;
}

Future<List<BookingModel>> getUserHistory() async{
  var listBooking = List<BookingModel>.empty(growable: true);
  var userRef = FirebaseFirestore.instance.collection('User')
  .doc(FirebaseAuth.instance.currentUser!.phoneNumber)
  .collection('Booking_${FirebaseAuth.instance.currentUser!.uid}');
  var snapshot = await userRef.orderBy('timeStamp', descending: true).get();
  for (var element in snapshot.docs) {
    var booking = BookingModel.fromJson(element.data());
    booking.docId = element.id;
    booking.reference = element.reference;
    listBooking.add(booking);
  }
  return listBooking;
}