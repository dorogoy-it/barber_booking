import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:untitled2/cloud_firestore/all_salon_ref.dart';
import 'package:untitled2/model/booking_model.dart';
import 'package:untitled2/view_model/done_services/done_services_view_model.dart';
import '../../state/state_management.dart';

class DoneServicesViewModelImp implements DoneServicesViewModel {
  @override
  Future<BookingModel> displayDetailBooking(WidgetRef ref, BuildContext context, int timeSlot) {
    return getDetailBooking(ref, context, timeSlot);
  }

  @override
  void finishService(WidgetRef ref, BuildContext context, GlobalKey<ScaffoldState> scaffoldKey) {
    var batch = FirebaseFirestore.instance.batch();
    var barberBook = ref.read(selectedBooking.notifier).state;

    var userBook = FirebaseFirestore.instance
        .collection('User')
        .doc(barberBook.customerPhone)
        .collection('Booking_${barberBook.customerId}')
        .doc(
        '${barberBook.barberId}_${DateFormat('dd_MM_yyyy').format(DateTime.fromMillisecondsSinceEpoch(barberBook.timeStamp))}');
    Map<String, dynamic> updateDone = {};
    updateDone['done'] = true;

    batch.update(userBook, updateDone);
    batch.update(barberBook.reference!, updateDone);

    batch.commit().then((value) {
      ScaffoldMessenger.of(scaffoldKey.currentContext!)
          .showSnackBar(const SnackBar(content: Text('Процесс успешно завершён')))
          .closed
          .then((v) => context.mounted ? Navigator.of(context).pop() : '');
    });
  }

  @override
  bool isDone(WidgetRef ref, BuildContext context) {
    return ref.read(selectedBooking.notifier).state.done;
  }
}