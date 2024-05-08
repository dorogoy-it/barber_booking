import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:untitled2/model/booking_model.dart';

abstract class UserHistoryViewModel {
  Future<List<BookingModel>> displayUserHistory();
  void userCancelBooking(WidgetRef ref, BuildContext context, BookingModel bookingModel);
}