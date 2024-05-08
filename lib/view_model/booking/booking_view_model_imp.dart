import 'package:add_2_calendar/add_2_calendar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:untitled2/cloud_firestore/all_salon_ref.dart';
import 'package:untitled2/fcm/notification_send.dart';
import 'package:untitled2/model/barber_model.dart';
import 'package:untitled2/model/city_model.dart';
import 'package:untitled2/model/notification_payload_model.dart';
import 'package:untitled2/model/salon_model.dart';
import 'package:untitled2/view_model/booking/booking_view_model.dart';
import '../../model/booking_model.dart';
import '../../model/service_model.dart';
import '../../state/state_management.dart';
import '../../string/strings.dart';
import '../../utils/utils.dart';
import 'package:untitled2/cloud_firestore/services_ref.dart';

class BookingViewModelImp implements BookingViewModel {
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
    return getSalonByCity(cityName);
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
  List<ServiceModel> changeSalon(WidgetRef ref, BuildContext context) {
    return ref.read(selectedServices.notifier).state = [];
  }

  @override
  Future<List<BarberModel>> displayBarbersBySalon(WidgetRef ref, SalonModel salonModel) {
    return getBarbersBySalon(salonModel);
  }

  @override
  bool isBarberSelected(WidgetRef ref, BuildContext context, BarberModel barberModel) {
    return ref.read(selectedBarber.notifier).state.docId == barberModel.docId;
  }

  @override
  void onSelectedBarber(WidgetRef ref, BuildContext context, BarberModel barberModel) {
    ref.read(selectedBarber.notifier).state = barberModel;
  }

  @override
  Color displayColorTimeSlot(WidgetRef ref, BuildContext context, List<int> listTimeSlot, int index, int maxTimeSlot) {
    return listTimeSlot.contains(index)
        ? Colors.white10
        : maxTimeSlot > index
        ? Colors.white60
        : ref
        .read(selectedTime
        .notifier)
        .state ==
        TIME_SLOT.elementAt(index)
        ? Colors.white54
        : Colors.white;
  }

  @override
  Future<int> displayMaxAvailableTimeslot(DateTime dt) {
    return getMaxAvailableTimeSlot(dt);
  }

  @override
  Future<List<int>> displayTimeSlotOfBarber(BarberModel barberModel, String date) {
    return getTimeSlotOfBarber(barberModel, date);
  }

  @override
  bool isAvailableForTapTimeSlot(int maxTime, int index, List<int> listTimeSlot) {
    return (maxTime > index) || listTimeSlot.contains(index);
  }

  @override
  void onSelectedTimeSlot(WidgetRef ref, BuildContext context, int index) {
    ref.read(selectedTimeSlot.notifier).state = index;
    ref.read(selectedTime.notifier).state = TIME_SLOT.elementAt(index);
  }

  @override
  void confirmBooking(WidgetRef ref, BuildContext context, GlobalKey<ScaffoldState> scaffoldKey) async {
    var hour = ref.read(selectedTime.notifier).state.length <= 10
        ? int.parse(
        ref.read(selectedTime.notifier).state.split(':')[0].substring(0, 1))
        : int.parse(ref
        .read(selectedTime.notifier)
        .state
        .split(':')[0]
        .substring(0, 2));

    var minutes = ref.read(selectedTime.notifier).state.length <= 10
        ? int.parse(
        ref.read(selectedTime.notifier).state.split(':')[1].substring(0, 1))
        : int.parse(ref
        .read(selectedTime.notifier)
        .state
        .split(':')[1]
        .substring(0, 2));
    var timeStamp = DateTime(
        ref.read(selectedDate.notifier).state.year,
        ref.read(selectedDate.notifier).state.month,
        ref.read(selectedDate.notifier).state.day,
        hour, //hour
        minutes //minutes
    )
        .millisecondsSinceEpoch;

    // Check if booking exists
    bool bookingExists = await checkBookingExists(
      ref.read(selectedBarber.notifier).state.docId!,
      ref.read(selectedDate.notifier).state,
      FirebaseAuth.instance.currentUser!.uid,
    );

    if (bookingExists) {
      // Show error message to the user
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Сначала удалите старую запись.'),
      ));
      return; // Exit the function to prevent further processing
    } else {
      //Submit on FireStore
      var bookingModel = BookingModel(
          barberId: ref.read(selectedBarber.notifier).state.docId!,
          barberName: ref.read(selectedBarber.notifier).state.name,
          cityBook: ref.read(selectedCity.notifier).state.name,
          customerId: FirebaseAuth.instance.currentUser!.uid,
          customerName: ref.read(userInformation.notifier).state.name,
          customerPhone: FirebaseAuth.instance.currentUser!.phoneNumber!,
          done: false,
          salonAddress: ref.read(selectedSalon.notifier).state.address,
          salonId: ref.read(selectedSalon.notifier).state.docId!,
          salonName: ref.read(selectedSalon.notifier).state.name,
          services: ref.read(selectedServices.notifier).state,
          slot: ref.read(selectedTimeSlot.notifier).state,
          totalPrice:
          calculateTotalPrice(ref.read(selectedServices.notifier).state),
          timeStamp: timeStamp,
          time:
          '${ref.read(selectedTime.notifier).state} - ${DateFormat('dd/MM/yyyy').format(ref.read(selectedDate.notifier).state)}');

      var batch = FirebaseFirestore.instance.batch();

      DocumentReference barberBooking = ref
          .read(selectedBarber.notifier)
          .state
          .reference!
          .collection(DateFormat('dd_MM_yyyy')
          .format(ref.read(selectedDate.notifier).state))
          .doc(ref.read(selectedTimeSlot.notifier).state.toString());
      DocumentReference userBooking = FirebaseFirestore.instance
          .collection('User')
          .doc(FirebaseAuth.instance.currentUser!.phoneNumber!)
          .collection(
          'Booking_${FirebaseAuth.instance.currentUser!.uid}') //For secure info
          .doc(
          '${ref.read(selectedBarber.notifier).state.docId}_${DateFormat('dd_MM_yyyy').format(ref.read(selectedDate.notifier).state)}');

      //Set for batch
      batch.set(barberBooking, bookingModel.toJson());
      batch.set(userBooking, bookingModel.toJson());
      batch.commit().then((value) {
        
        ref.read(isLoading.notifier).state = true;
        var notificationPayload = NotificationPayloadModel(to: '/topics/${ref.read(selectedBarber.notifier).state.docId!}',
            notification: NotificationContent(title: 'Новая запись', body: 'К вам записался пользователь с номером ${FirebaseAuth.instance.currentUser!.phoneNumber!}'));

        sendNotification(notificationPayload).then((value) {
          ref.read(isLoading.notifier).state = false;
          Navigator.of(context).pop();
          ScaffoldMessenger.of(scaffoldKey.currentContext!)
              .showSnackBar(const SnackBar(
            content: Text('Запись оформлена'),
          ));
          //Create Event
          final Event event = Event(
              title: titleText,
              description:
              'Запись на стрижку ${ref.read(selectedTime.notifier).state} - '
                  '${DateFormat('dd/MMMM/yyyy', 'ru').format(ref.read(selectedDate.notifier).state)}',
              location: ref.read(selectedSalon.notifier).state.address,
              startDate: DateTime(
                  ref.read(selectedDate.notifier).state.year,
                  ref.read(selectedDate.notifier).state.month,
                  ref.read(selectedDate.notifier).state.day,
                  hour,
                  minutes),
              endDate: DateTime(
                  ref.read(selectedDate.notifier).state.year,
                  ref.read(selectedDate.notifier).state.month,
                  ref.read(selectedDate.notifier).state.day,
                  hour,
                  minutes + 30),
              iosParams: const IOSParams(reminder: Duration(minutes: 30)),
              androidParams: const AndroidParams(emailInvites: []));
          Add2Calendar.addEvent2Cal(event).then((value) {});
        });
        //Reset value
        ref.read(selectedDate.notifier).state = DateTime.now();
        ref.read(selectedBarber.notifier).state = BarberModel();
        ref.read(selectedCity.notifier).state = CityModel(name: '');
        ref.read(selectedSalon.notifier).state =
            SalonModel(name: '', address: '');
        ref.read(selectedServices.notifier).state =
        List<ServiceModel>.empty(growable: true);
        ref.read(currentStep.notifier).state = 1;
        ref.read(selectedTime.notifier).state = '';
        ref.read(selectedTimeSlot.notifier).state = -1;
      });
    }
  }

  Future<bool> checkBookingExists(
      String barberId, DateTime date, String userId) async {
    var userBookingReference = FirebaseFirestore.instance
        .collection('User')
        .doc(FirebaseAuth.instance.currentUser!.phoneNumber!)
        .collection('Booking_$userId')
        .doc('${barberId}_${DateFormat('dd_MM_yyyy').format(date)}');

    var userBookingSnapshot = await userBookingReference.get();

    return userBookingSnapshot.exists;
  }

  @override
  double calculateTotalPrice(List<ServiceModel> selectedServicesList) {
    return selectedServicesList.map((item) => item.price).fold(0.0, (value, element) => double.parse(value.toString()) + element);
  }

  @override
  Future<List<ServiceModel>> displayServices(WidgetRef ref, BuildContext context) {
    return getServices(ref, context);
  }

  @override
  bool isSelectedService(WidgetRef ref, BuildContext context, ServiceModel serviceModel) {
    return ref.read(selectedServices.notifier).state.contains(serviceModel);
  }

  @override
  void onSelectedChip(WidgetRef ref, BuildContext context, bool isSelected, ServiceModel e) {
    final selectedServicesList = ref.read(selectedServices.notifier).state;

    if (selectedServicesList.contains(e)) {
      // Если услуга уже выбрана, удалить ее из списка
      ref.read(selectedServices.notifier).state = [
        for (final service in selectedServicesList)
          if (service != e) service,
      ];
    } else {
      // Если услуга не выбрана, добавить ее в список
      ref.read(selectedServices.notifier).state = [...selectedServicesList, e];
    }
  }

}