import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:untitled2/model/city_model.dart';

import '../model/barber_model.dart';
import '../model/booking_model.dart';
import '../model/salon_model.dart';
import '../model/service_model.dart';
import '../model/user_model.dart';

final userLogged = StateProvider((ref) => FirebaseAuth.instance.currentUser);
final userToken = StateProvider((ref) => '');
final forceReload = StateProvider((ref) => false);

final userInformation = StateProvider((ref) => UserModel(name: '', address: ''));

//Booking state
final currentStep = StateProvider((ref) => 1);
final selectedCity = StateProvider((ref) => CityModel(name: ''));
final selectedSalon = StateProvider((ref) => SalonModel(address: '', name: ''));
final selectedBarber = StateProvider((ref) => BarberModel());
final selectedDate = StateProvider((ref) => DateTime.now());
final selectedTimeSlot = StateProvider((ref) => -1);
final selectedTime = StateProvider((ref) => '');

//Delete Booking
final deleteFlagRefresh = StateProvider((ref) => false);

//Staff
final staffStep = StateProvider((ref) => 1);
final selectedBooking = StateProvider((ref) => BookingModel(
    barberId: '',
    barberName: '',
    cityBook: '',
    customerName: '',
    customerPhone: '',
    salonAddress: '',
    salonId: '',
    salonName: '',
    time: '',
    done: false,
    slot: 0,
    timeStamp: 0,
    customerId: '',
    totalPrice: 0));
final selectedServices =
    StateProvider((ref) => List<ServiceModel>.empty(growable: true));
