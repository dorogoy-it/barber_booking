import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../model/city_model.dart';
import '../../model/salon_model.dart';

abstract class StaffHomeViewModel {
  // Город
  Future<List<CityModel>> displayCities();
  void onSelectedCity(WidgetRef ref, BuildContext context, CityModel cityModel);
  bool isCitySelected(WidgetRef ref, BuildContext context, CityModel cityModel);

  // Салон
  Future<List<SalonModel>> displaySalonByCity(WidgetRef ref, String cityName);
  void onSelectedSalon(WidgetRef ref, BuildContext context, SalonModel salonModel);
  bool isSalonSelected(WidgetRef ref, BuildContext context, SalonModel salonModel);

  // Запись
  Future<bool> isStaffOfThisSalon(WidgetRef ref, BuildContext context);
  Future<int> displayMaxAvailableTimeSlot(DateTime dt);
  Future<List<int>> displayBookingSlotOfBarber(WidgetRef ref, BuildContext context, String date);
  bool isTimeSlotBooked(List<int> listTimeSlot, int index);
  void processDoneServices(WidgetRef ref, BuildContext context, int index);
  Color getColorOfThisSlot(WidgetRef ref, BuildContext context, List<int> listTimeSlot, int index, int maxTimeSlot);

}