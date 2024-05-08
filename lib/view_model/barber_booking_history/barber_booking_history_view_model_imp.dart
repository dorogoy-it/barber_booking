import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:untitled2/model/booking_model.dart';
import 'package:untitled2/view_model/barber_booking_history/barber_booking_history_view_model.dart';

import '../../state/state_management.dart';

class BarberBookingHistoryViewModelImp implements BarberBookingHistoryViewModel {
  @override
  Future<List<BookingModel>> getBarberBookingHistory(WidgetRef ref, BuildContext context, DateTime dateTime) async {
    var listBooking = List<BookingModel>.empty(growable: true);
    var barberDocument = FirebaseFirestore.instance
        .collection('AllSalon')
        .doc(ref.read(selectedCity.notifier).state.name)
        .collection('Branch')
        .doc(ref.read(selectedSalon.notifier).state.docId)
        .collection('Barber')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .collection(DateFormat('dd_MM_yyyy').format(dateTime));
    var snapshot = await barberDocument.get();
    for (var element in snapshot.docs) {
      var barberBooking = BookingModel.fromJson(element.data());
      barberBooking.docId = element.id;
      barberBooking.reference = element.reference;
      listBooking.add(barberBooking);
    }
    return listBooking;
  }
  
}