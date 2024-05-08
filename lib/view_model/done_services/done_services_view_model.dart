import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../model/booking_model.dart';

abstract class DoneServicesViewModel {
  Future<BookingModel> displayDetailBooking(WidgetRef ref, BuildContext context, int timeSlot);
  void finishService(WidgetRef ref, BuildContext context, GlobalKey<ScaffoldState> scaffoldKey);
  bool isDone(WidgetRef ref, BuildContext context);
}