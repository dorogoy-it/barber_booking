import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_riverpod/src/consumer.dart';
import 'package:intl/intl.dart';
import 'package:untitled2/cloud_firestore/user_ref.dart';
import 'package:untitled2/model/booking_model.dart';
import 'package:untitled2/view_model/user_history/user_history_view_model.dart';

import '../../state/state_management.dart';

class UserHistoryViewModelImp implements UserHistoryViewModel {
  @override
  Future<List<BookingModel>> displayUserHistory() {
    return getUserHistory();
  }

  @override
  void userCancelBooking(WidgetRef ref, BuildContext context, BookingModel bookingModel) {
    var batch = FirebaseFirestore.instance.batch();
    var barberBooking = FirebaseFirestore.instance
        .collection('AllSalon')
        .doc(bookingModel.cityBook)
        .collection('Branch')
        .doc(bookingModel.salonId)
        .collection('Barber')
        .doc(bookingModel.barberId) // Fixed
        .collection(DateFormat('dd_MM_yyyy').format(
        DateTime.fromMillisecondsSinceEpoch(bookingModel.timeStamp)))
        .doc(bookingModel.slot.toString());
    var userBooking = bookingModel.reference;

    // Удаление
    batch.delete(userBooking!);
    batch.delete(barberBooking);

    batch.commit().then((value) {
      // Обновление данных
      ref.read(deleteFlagRefresh.notifier).state =
      !ref.read(deleteFlagRefresh.notifier).state;
    });
  }
  
}