import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:untitled2/model/city_model.dart';

import '../model/barber_model.dart';
import '../model/salon_model.dart';

final userLogged = StateProvider((ref) => FirebaseAuth.instance.currentUser);
final userToken = StateProvider((ref) => '');
final forceReload = StateProvider((ref) => false);

//Booking state
final currentStep = StateProvider((ref) => 1);
final selectedCity = StateProvider((ref) => CityModel(name: ''));
final selectedSalon = StateProvider((ref) => SalonModel(address: '', name: ''));
final selectedBarber = StateProvider((ref) => BarberModel());