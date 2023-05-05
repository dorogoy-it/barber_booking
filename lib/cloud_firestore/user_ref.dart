import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:untitled2/model/booking_model.dart';
import 'package:untitled2/model/user_model.dart';
import 'package:untitled2/state/state_management.dart';

Future<UserModel> getUserProfiles(BuildContext context, String phone) async {
  CollectionReference userRef = FirebaseFirestore.instance.collection('User');
  DocumentSnapshot snapshot = await userRef.doc(phone).get();
  if (snapshot.exists) {
    final data = snapshot.data() as Map<String,dynamic>;
    var userModel = UserModel.fromJson(data);
    context.read(userInformation).state = userModel;
    return userModel;
  }
  else 
    return UserModel(name: '', address: '');
}

Future<List<BookingModel>> getUserHistory() async{
  var listBooking = new List<BookingModel>.empty(growable: true);
  var userRef = FirebaseFirestore.instance.collection('User')
  .doc(FirebaseAuth.instance.currentUser!.phoneNumber)
  .collection('Booking_${FirebaseAuth.instance.currentUser!.uid}');
  var snapshot = await userRef.orderBy('timeStamp', descending: true).get();
  snapshot.docs.forEach((element) {
    var booking = BookingModel.fromJson(element.data());
    booking.docId = element.id;
    booking.reference = element.reference;
    listBooking.add(booking);
  });
  return listBooking;
}