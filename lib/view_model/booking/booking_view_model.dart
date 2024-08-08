import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:untitled2/model/salon_model.dart';
import '../../model/barber_model.dart';
import '../../model/city_model.dart';
import '../../model/service_model.dart';

abstract class BookingViewModel {
  // Город
  Future<List<CityModel>> displayCities();
  void onSelectedCity(WidgetRef ref, BuildContext context, CityModel cityModel);
  bool isCitySelected(WidgetRef ref, BuildContext context, CityModel cityModel);

  // Салон
  Future<List<SalonModel>> displaySalonByCity(WidgetRef ref, String cityName);
  void onSelectedSalon(WidgetRef ref, BuildContext context, SalonModel salonModel);
  bool isSalonSelected(WidgetRef ref, BuildContext context, SalonModel salonModel);

  // Парикмахер
  Future<List<BarberModel>> displayBarbersBySalon(WidgetRef ref, SalonModel salonModel);
  void onSelectedBarber(WidgetRef ref, BuildContext context, BarberModel barberModel);
  bool isBarberSelected(WidgetRef ref, BuildContext context, BarberModel barberModel);

  // Услуги
  double calculateTotalPrice(List<ServiceModel> serviceSelected);
  Future<List<ServiceModel>> displayServices(WidgetRef ref, BuildContext context);
  bool isSelectedService(WidgetRef ref, BuildContext context, ServiceModel serviceModel);
  void onSelectedChip(WidgetRef ref, BuildContext context, bool isSelected, ServiceModel e);
  List<ServiceModel> changeSalon(WidgetRef ref, BuildContext context);

  // Временные слоты
  Future<int> displayMaxAvailableTimeslot(DateTime dt);
  Future<List<int>> displayTimeSlotOfBarber(BarberModel barberModel, String date);
  bool isAvailableForTapTimeSlot(int maxTime, int index, List<int> listTimeSlot);
  void onSelectedTimeSlot(WidgetRef ref, BuildContext context, int index);
  Color displayColorTimeSlot(WidgetRef ref, BuildContext context, List<int> listTimeSlot, int index, int maxTimeSlot);

  void confirmBooking(WidgetRef ref, BuildContext context, GlobalKey<ScaffoldState> scaffoldKey);
}
