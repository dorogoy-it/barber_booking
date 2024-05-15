import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:untitled2/model/city_model.dart';
import 'package:untitled2/model/salon_model.dart';
import 'package:untitled2/utils/utils.dart';
import 'package:untitled2/view_model/staff_home/staff_home_view_model.dart';
import '../../cloud_firestore/all_salon_ref.dart';
import '../../state/state_management.dart';

class StaffHomeViewModelImp implements StaffHomeViewModel {
  @override
  Future<List<CityModel>> displayCities() {
    return getCities();
  }

  @override
  bool isCitySelected(WidgetRef ref, BuildContext context, CityModel cityModel) {
    return ref.read(selectedCity.notifier).state.name == cityModel.name;
  }

  @override
  void onSelectedCity(WidgetRef ref, BuildContext context, CityModel cityModel) {
    ref.read(selectedCity.notifier).state = cityModel;
  }

  @override
  Future<List<SalonModel>> displaySalonByCity(WidgetRef ref, String cityName) {
    return getSalonsWithCurrentStaff(cityName);
  }

  @override
  bool isSalonSelected(WidgetRef ref, BuildContext context, SalonModel salonModel) {
    return ref.read(selectedSalon.notifier).state.docId == salonModel.docId;
  }

  @override
  void onSelectedSalon(WidgetRef ref, BuildContext context, SalonModel salonModel) {
    ref.read(selectedSalon.notifier).state = salonModel;
  }

  @override
  Future<List<int>> displayBookingSlotOfBarber(WidgetRef ref, BuildContext context, String date) {
    return getBookingSlotOfBarber(ref, context, date);
  }

  @override
  Future<int> displayMaxAvailableTimeSlot(DateTime dt) {
    return getMaxAvailableTimeSlot(dt);
  }

  @override
  Future<bool> isStaffOfThisSalon(WidgetRef ref, BuildContext context) {
    return checkStaffOfThisSalon(ref, context);
  }

  @override
  bool isTimeSlotBooked(List<int> listTimeSlot, int index) {
    return listTimeSlot.contains(index) ? false : true;
  }

  @override
  void processDoneServices(WidgetRef ref, BuildContext context, int index) {
    ref.read(selectedTimeSlot.notifier).state =
        index;
    Navigator.of(context).pushNamed('/doneService');
  }

  @override
  Color getColorOfThisSlot(WidgetRef ref, BuildContext context, List<int> listTimeSlot, int index, int maxTimeSlot) {
    return listTimeSlot.contains(index)
        ? Colors.white10 :
    maxTimeSlot > index ? Colors.white60
        : ref.read(selectedTime.notifier).state ==
        TIME_SLOT.elementAt(index)
        ? Colors.white54
        : Colors.white;
  }
  
}