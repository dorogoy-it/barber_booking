import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../model/barber_model.dart';
import '../model/booking_model.dart';
import '../model/city_model.dart';
import '../model/salon_model.dart';
import '../model/service_model.dart';
import '../model/user_model.dart';

final userLogged = StateProvider<User?>((ref) => FirebaseAuth.instance.currentUser);
final userToken = StateProvider<String>((ref) => '');
final forceReload = StateProvider<bool>((ref) => false);

final userInformation = StateProvider<UserModel>((ref) => UserModel(name: '', address: '', phone: '', id: ''));

// Состояние записи
final currentStep = StateProvider<int>((ref) => 1);
final selectedCity = StateProvider<CityModel>((ref) => CityModel(name: ''));
final selectedSalon = StateProvider<SalonModel>((ref) => SalonModel(address: '', name: ''));
final selectedBarber = StateProvider<BarberModel>((ref) => BarberModel());
final selectedDate = StateProvider<DateTime>((ref) => DateTime.now());
final selectedTimeSlot = StateProvider<int>((ref) => -1);
final selectedTime = StateProvider<String>((ref) => '');

final selectedUser = StateProvider<UserModel>((ref) => UserModel(name: '', address: '', phone: '', id: ''));

// Удаление записи
final deleteFlagRefresh = StateProvider<bool>((ref) => false);

// Сотрудник
final staffStep = StateProvider<int>((ref) => 1);
final selectedBooking = StateProvider<BookingModel>((ref) => BookingModel(
    barberId: '',
    barberName: '',
    cityBook: '',
    customerName: '',
    customerPhone: '',
    salonAddress: '',
    salonId: '',
    salonName: '',
    services: [],
    time: '',
    done: false,
    slot: 0,
    timeStamp: 0,
    customerId: '',
    totalPrice: 0));
final selectedServices =
    StateProvider<List<ServiceModel>>((ref) => List<ServiceModel>.empty(growable: true));

// Загрузка
final isLoading = StateProvider((ref) => false);