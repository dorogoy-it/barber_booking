import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:untitled2/model/booking_model.dart';

abstract class BarberBookingHistoryViewModel {
  Future<List<BookingModel>> getBarberBookingHistory(
      WidgetRef ref, BuildContext context, DateTime dateTime
      );
}