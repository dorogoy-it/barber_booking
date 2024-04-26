import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../model/barber_model.dart';
import '../model/booking_model.dart';
import '../model/city_model.dart';
import '../model/salon_model.dart';
import '../state/state_management.dart';


Future<BookingModel> getDetailBooking(WidgetRef ref, BuildContext context, int timeSlot) async{
  CollectionReference userRef = FirebaseFirestore.instance
      .collection('AllSalon')
      .doc(ref.read(selectedCity.notifier).state.name)
      .collection('Branch')
      .doc(ref.read(selectedSalon.notifier).state.docId)
      .collection('Barber')
      .doc(FirebaseAuth.instance.currentUser!.uid)
      .collection(DateFormat('dd_MM_yyyy').format(ref.read(selectedDate.notifier).state));
  DocumentSnapshot snapshot = await userRef.doc(timeSlot.toString()).get();
  if (snapshot.exists)
    {
      var bookingModel = BookingModel.fromJson(json.decode(json.encode(snapshot.data())));
      bookingModel.docId = snapshot.id;
      bookingModel.reference = snapshot.reference;
      ref.read(selectedBooking.notifier).state = bookingModel;
      return bookingModel;
    }
  else {
    return BookingModel(
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
      totalPrice: 0);
  }
}

Future<BookingModel> getDetailBookingToAdmin(WidgetRef ref, BuildContext context, int timeSlot) async{
  CollectionReference userRef = FirebaseFirestore.instance
      .collection('AllSalon')
      .doc(ref.read(selectedCity.notifier).state.name)
      .collection('Branch')
      .doc(ref.read(selectedSalon.notifier).state.docId)
      .collection('Barber')
      .doc(ref.read(selectedBarber.notifier).state.docId)
      .collection(DateFormat('dd_MM_yyyy').format(ref.read(selectedDate.notifier).state));
  DocumentSnapshot snapshot = await userRef.doc(timeSlot.toString()).get();
  if (snapshot.exists)
  {
    var bookingModel = BookingModel.fromJson(json.decode(json.encode(snapshot.data())));
    bookingModel.docId = snapshot.id;
    bookingModel.reference = snapshot.reference;
    ref.read(selectedBooking.notifier).state = bookingModel;
    return bookingModel;
  }
  else {
    return BookingModel(
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
        totalPrice: 0);
  }
}

Future<List<CityModel>> getCities() async {
  var cities = List<CityModel>.empty(growable: true);
  var cityRef = FirebaseFirestore.instance.collection('AllSalon');
  var snapshot = await cityRef.get();
  for (var element in snapshot.docs) {
    cities.add(CityModel.fromJson(element.data()));
  }
  return cities;
}

Future<List<SalonModel>> getSalonByCity(String cityName) async {
  var salons = List<SalonModel>.empty(growable: true);
  var salonRef = FirebaseFirestore.instance
      .collection('AllSalon')
      .doc(cityName.replaceAll(' ', ''))
      .collection('Branch');
  var snapshot = await salonRef.get();
  for (var element in snapshot.docs) {
    var salon = SalonModel.fromJson(element.data());
    salon.docId = element.id;
    salon.reference = element.reference;
    salons.add(salon);
  }
  return salons;
}

Future<List<BarberModel>> getBarbersBySalon(SalonModel salon) async {
  var barbers = List<BarberModel>.empty(growable: true);
  var barberRef = salon.reference!.collection('Barber');
  var snapshot = await barberRef.get();
  for (var element in snapshot.docs) {
    var barber = BarberModel.fromJson(element.data());
    barber.docId = element.id;
    barber.reference = element.reference;
    barbers.add(barber);
  }
  return barbers;
}

Future<List<SalonModel>> getSalonsWithCurrentAdmin(String cityName) async {
  String currentUserId = FirebaseAuth.instance.currentUser!.uid;

  List<SalonModel> allSalons = await getSalonByCity(cityName);
  List<SalonModel> adminSalons = [];

  for (SalonModel salon in allSalons) {
    DocumentSnapshot adminSnapshot = await FirebaseFirestore.instance
        .collection('AllSalon')
        .doc(cityName.replaceAll(' ', ''))
        .collection('Branch')
        .doc(salon.docId)
        .collection('Admin')
        .doc(currentUserId)
        .get();

    if (adminSnapshot.exists) {
      adminSalons.add(salon);
    }
  }

  return adminSalons;
}

Future<List<SalonModel>> getSalonsWithCurrentStaff(String cityName) async {
  String currentUserId = FirebaseAuth.instance.currentUser!.uid;

  List<SalonModel> allSalons = await getSalonByCity(cityName);
  List<SalonModel> staffSalons = [];

  for (SalonModel salon in allSalons) {
    DocumentSnapshot staffSnapshot = await FirebaseFirestore.instance
        .collection('AllSalon')
        .doc(cityName.replaceAll(' ', ''))
        .collection('Branch')
        .doc(salon.docId)
        .collection('Barber')
        .doc(currentUserId)
        .get();

    if (staffSnapshot.exists) {
      staffSalons.add(salon);
    }
  }

  return staffSalons;
}

Future<List<int>> getTimeSlotOfBarber(
    BarberModel barberModel, String date) async {
  List<int> result = List<int>.empty(growable: true);
  var bookingRef = barberModel.reference!.collection(date);
  QuerySnapshot snapshot = await bookingRef.get();
  for (var element in snapshot.docs) {
    result.add(int.parse(element.id));
  }
  return result;
}

Future<bool> checkStaffOfThisSalon(WidgetRef ref, BuildContext context) async {
  DocumentSnapshot barberSnapshot = await FirebaseFirestore.instance
      .collection('AllSalon')
      .doc(ref.read(selectedCity.notifier).state.name)
      .collection('Branch')
      .doc(ref.read(selectedSalon.notifier).state.docId)
      .collection('Barber')
      .doc(FirebaseAuth.instance.currentUser!.uid) //Compare uid of this staff
      .get();
  return barberSnapshot.exists;
}

Future<bool> checkAdminOfThisSalon(WidgetRef ref, BuildContext context) async {
  DocumentSnapshot adminSnapshot = await FirebaseFirestore.instance
      .collection('AllSalon')
      .doc(ref.read(selectedCity.notifier).state.name)
      .collection('Branch')
      .doc(ref.read(selectedSalon.notifier).state.docId)
      .collection('Admin')
      .doc(FirebaseAuth.instance.currentUser!.uid) //Compare uid of this staff
      .get();
  return adminSnapshot.exists;
}

Future<List<int>> getBookingSlotOfBarber(
    WidgetRef ref, BuildContext context, String date) async {
  var barberDocument = FirebaseFirestore.instance
      .collection('AllSalon')
      .doc(ref.read(selectedCity.notifier).state.name)
      .collection('Branch')
      .doc(ref.read(selectedSalon.notifier).state.docId)
      .collection('Barber')
      .doc(FirebaseAuth.instance.currentUser!.uid); //Compare uid of this staff
  List<int> result = List<int>.empty(growable: true);
  var bookingRef = barberDocument.collection(date);
  QuerySnapshot snapshot = await bookingRef.get();
  for (var element in snapshot.docs) {
    result.add(int.parse(element.id));
  }
  return result;
}

Future<List<int>> getBookingSlotOfBarberToAdmin(
    WidgetRef ref, BuildContext context, String date) async {
  var barberDocument = FirebaseFirestore.instance
      .collection('AllSalon')
      .doc(ref.read(selectedCity.notifier).state.name)
      .collection('Branch')
      .doc(ref.read(selectedSalon.notifier).state.docId)
      .collection('Barber')
      .doc(ref.read(selectedBarber.notifier).state.docId); //Compare uid of this staff
  List<int> result = List<int>.empty(growable: true);
  var bookingRef = barberDocument.collection(date);
  QuerySnapshot snapshot = await bookingRef.get();
  for (var element in snapshot.docs) {
    result.add(int.parse(element.id));
  }
  return result;
}
