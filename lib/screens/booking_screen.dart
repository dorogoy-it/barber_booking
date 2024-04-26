import 'package:add_2_calendar/add_2_calendar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker_plus/flutter_datetime_picker_plus.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:im_stepper/stepper.dart';
import 'package:intl/intl.dart';
import 'package:untitled2/cloud_firestore/all_salon_ref.dart';
import 'package:untitled2/state/state_management.dart';
import 'package:untitled2/model/city_model.dart';
import 'package:untitled2/model/salon_model.dart';
import 'package:untitled2/utils/utils.dart';
import '../cloud_firestore/services_ref.dart';
import '../model/barber_model.dart';
import '../model/booking_model.dart';
import '../model/service_model.dart';

class BookingScreen extends ConsumerWidget {
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey();

  BookingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    var step = ref.watch(currentStep);
    var cityWatch = ref.watch(selectedCity);
    var salonWatch = ref.watch(selectedSalon);
    var barberWatch = ref.watch(selectedBarber);
    var dateWatch = ref.watch(selectedDate);
    var timeWatch = ref.watch(selectedTime);
    var timeSlotWatch = ref.watch(selectedTimeSlot);
    var selectedServicesList = ref.watch(selectedServices);
    return SafeArea(
        child: Scaffold(
      key: scaffoldKey,
      appBar: AppBar(
        title: const Text(
          'Запись',
          style: TextStyle(
            color: Colors.white, // Здесь указывается цвет текста
          ),
        ),
        backgroundColor: const Color(0xFF383838),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      resizeToAvoidBottomInset: true,
      backgroundColor: const Color(0xFFFDF9EE),
      body: Column(
        children: [
          //Step
          NumberStepper(
            activeStep: step - 1,
            direction: Axis.horizontal,
            enableNextPreviousButtons: false,
            enableStepTapping: false,
            numbers: const [1, 2, 3, 4, 5, 6],
            stepColor: Colors.black,
            activeStepColor: Colors.grey,
            numberStyle: const TextStyle(color: Colors.white),
          ),
          //Screen
          Expanded(
            flex: 10,
            child: step == 1
                ? displayCityList(ref)
                : step == 2
                    ? displaySalon(ref, cityWatch.name)
                    : step == 3
                        ? displayBarber(ref, salonWatch)
                        : step == 4
                            ? displayServices(ref, context)
                            : step == 5
                                ? displayTimeSlot(ref, context, barberWatch)
                                : step == 6
                                    ? displayConfirm(ref, context)
                                    : Container(),
          ),
          //Button
          Expanded(
              child: Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              padding: const EdgeInsets.all(8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                      child: ElevatedButton(
                    onPressed: step == 1
                        ? null
                        : () => ref.read(currentStep.notifier).state--,
                    child: const Text('Предыдущая'),
                  )),
                  const SizedBox(
                    width: 30,
                  ),
                  Expanded(
                      child: ElevatedButton(
                    onPressed: (step == 1 &&
                                ref.read(selectedCity.notifier).state.name ==
                                    '') ||
                            (step == 2 &&
                                ref
                                        .read(selectedSalon.notifier)
                                        .state
                                        .docId ==
                                    '') ||
                            (step == 3 &&
                                ref.read(selectedBarber.notifier).state.docId ==
                                    '') ||
                            (step == 4 &&
                                ref
                                    .read(selectedServices.notifier)
                                    .state
                                    .isEmpty) ||
                            (step == 5 &&
                                ref.read(selectedTimeSlot.notifier).state == -1)
                        ? null
                        : step == 6
                            ? null
                            : () => ref.read(currentStep.notifier).state++,
                    child: const Text('Следующая'),
                  )),
                ],
              ),
            ),
          ))
        ],
      ),
    ));
  }

  displayCityList(WidgetRef ref) {
    return FutureBuilder(
        future: getCities(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          } else {
            var cities = snapshot.data as List<CityModel>;
            if (cities.isEmpty) {
              return const Center(
                child: Text('Не удалось загрузить список городов'),
              );
            } else {
              return ListView.builder(
                  itemCount: cities.length,
                  itemBuilder: (context, index) {
                    return GestureDetector(
                      onTap: () => ref.read(selectedCity.notifier).state =
                          CityModel(name: cities[index].name),
                      child: Card(
                        child: ListTile(
                          leading: const Icon(
                            Icons.home_work,
                            color: Colors.black,
                          ),
                          trailing:
                              ref.read(selectedCity.notifier).state.name ==
                                      cities[index].name
                                  ? const Icon(Icons.check)
                                  : null,
                          title: Text(
                            cities[index].name,
                            style: GoogleFonts.robotoMono(),
                          ),
                        ),
                      ),
                    );
                  });
            }
          }
        });
  }

  displaySalon(WidgetRef ref, String cityName) {
    return FutureBuilder(
      future: getSalonByCity(cityName),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        } else {
          var salons = snapshot.data as List<SalonModel>;
          if (salons.isEmpty) {
            return const Center(
              child: Text('Не удалось загрузить список салонов'),
            );
          } else {
            return ListView.builder(
              itemCount: salons.length,
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () {
                    // Опустошаем список услуг при выборе нового салона
                    ref.read(selectedServices.notifier).state = [];
                    // Устанавливаем выбранный салон
                    ref.read(selectedSalon.notifier).state = salons[index];
                  },
                  child: Card(
                    child: ListTile(
                      leading: const Icon(
                        Icons.home_outlined,
                        color: Colors.black,
                      ),
                      trailing: ref.read(selectedSalon.notifier).state.docId ==
                              salons[index].docId
                          ? const Icon(Icons.check)
                          : null,
                      title: Text(
                        salons[index].name,
                        style: GoogleFonts.robotoMono(),
                      ),
                      subtitle: Text(
                        salons[index].address,
                        style: GoogleFonts.robotoMono(
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),
                  ),
                );
              },
            );
          }
        }
      },
    );
  }

  displayBarber(WidgetRef ref, SalonModel salonModel) {
    return FutureBuilder(
        future: getBarbersBySalon(salonModel),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          } else {
            var barbers = snapshot.data != null
                ? List<BarberModel>.from(snapshot.data as Iterable)
                : [];
            if (barbers.isEmpty) {
              return const Center(
                child: Text('Список парикмахеров пуст'),
              );
            } else {
              return ListView.builder(
                  itemCount: barbers.length,
                  itemBuilder: (context, index) {
                    return GestureDetector(
                      onTap: () => ref.read(selectedBarber.notifier).state =
                          barbers[index],
                      child: Card(
                        child: ListTile(
                          leading: const Icon(
                            Icons.person,
                            color: Colors.black,
                          ),
                          trailing:
                              ref.read(selectedBarber.notifier).state.docId ==
                                      barbers[index].docId
                                  ? const Icon(Icons.check)
                                  : null,
                          title: Text(
                            '${barbers[index].name}',
                            style: GoogleFonts.robotoMono(),
                          ),
                          subtitle: RatingBar.builder(
                            itemSize: 16,
                            allowHalfRating: true,
                            initialRating: barbers[index].rating,
                            ignoreGestures: true,
                            direction: Axis.horizontal,
                            itemCount: 5,
                            onRatingUpdate: (double value) {},
                            itemBuilder: (context, _) => const Icon(
                              Icons.star,
                              color: Colors.amber,
                            ),
                            itemPadding: const EdgeInsets.all(4),
                          ),
                        ),
                      ),
                    );
                  });
            }
          }
        });
  }

  displayServices(WidgetRef ref, BuildContext context) {
    var selectedServicesList = ref.watch(selectedServices);
    var totalPrice = calculateTotalPrice(selectedServicesList);

    return FutureBuilder(
      future: getServices(ref, context),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        } else {
          var services = snapshot.data as List<ServiceModel>;

          return SingleChildScrollView(
            child: Column(
              children: [
                Wrap(
                  children: services
                      .map((e) => Padding(
                            padding: const EdgeInsets.all(4),
                            child: ChoiceChip(
                              selected: selectedServicesList.contains(e),
                              selectedColor: Colors.blue,
                              label: Text('${e.name}: ${e.price} руб.'),
                              labelStyle: const TextStyle(color: Colors.white),
                              backgroundColor: Colors.teal,
                              onSelected: (isSelected) {
                                var list = selectedServicesList.toList();
                                if (isSelected) {
                                  list.add(e);
                                } else {
                                  list.remove(e);
                                }
                                ref.read(selectedServices.notifier).state =
                                    list;
                              },
                            ),
                          ))
                      .toList(),
                ),
              ],
            ),
          );
        }
      },
    );
  }

  double calculateTotalPrice(List<ServiceModel> selectedServicesList) {
    return selectedServicesList.map((item) => item.price).fold(
        0.0, (value, element) => double.parse(value.toString()) + element);
  }

  displayTimeSlot(
      WidgetRef ref, BuildContext context, BarberModel barberModel) {
    var now = ref.read(selectedDate.notifier).state;
    return Column(
      children: [
        Container(
          color: const Color(0xFF008577),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                  child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    children: [
                      Text(
                        DateFormat.MMMM('ru').format(now),
                        style: GoogleFonts.robotoMono(color: Colors.white54),
                      ),
                      Text(
                        '${now.day}',
                        style: GoogleFonts.robotoMono(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 22),
                      ),
                      Text(
                        DateFormat.EEEE('ru').format(now),
                        style: GoogleFonts.robotoMono(color: Colors.white54),
                      ),
                    ],
                  ),
                ),
              )),
              GestureDetector(
                onTap: () {
                  DatePicker.showDatePicker(context,
                      locale: LocaleType.ru,
                      showTitleActions: true,
                      minTime: DateTime.now(),
                      // Fix can't select current date
                      maxTime: now.add(const Duration(days: 31)),
                      onConfirm: (date) =>
                          ref.read(selectedDate.notifier).state =
                              date); //next time you can choose is 31 days next
                },
                child: const Padding(
                  padding: EdgeInsets.all(8),
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: Icon(
                      Icons.calendar_today,
                      color: Colors.white,
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
        Expanded(
          child: FutureBuilder(
              future: getMaxAvailableTimeSlot(
                  ref.read(selectedDate.notifier).state),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                } else {
                  var maxTimeSlot = snapshot.data as int;
                  return FutureBuilder(
                    future: getTimeSlotOfBarber(
                        barberModel,
                        DateFormat('dd_MM_yyyy', 'ru')
                            .format(ref.read(selectedDate.notifier).state)),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(
                          child: CircularProgressIndicator(),
                        );
                      } else {
                        var listTimeSlot = snapshot.data as List<int>;
                        return GridView.builder(
                            itemCount: TIME_SLOT.length,
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 3),
                            itemBuilder: (context, index) => GestureDetector(
                                  onTap: maxTimeSlot > index ||
                                          listTimeSlot.contains(index)
                                      ? null
                                      : () {
                                          ref
                                                  .read(selectedTime.notifier)
                                                  .state =
                                              TIME_SLOT.elementAt(index);
                                          ref
                                              .read(selectedTimeSlot.notifier)
                                              .state = index;
                                        },
                                  child: Card(
                                    color: listTimeSlot.contains(index)
                                        ? Colors.white10
                                        : maxTimeSlot > index
                                            ? Colors.white60
                                            : ref
                                                        .read(selectedTime
                                                            .notifier)
                                                        .state ==
                                                    TIME_SLOT.elementAt(index)
                                                ? Colors.white54
                                                : Colors.white,
                                    child: GridTile(
                                      header: ref
                                                  .read(selectedTime.notifier)
                                                  .state ==
                                              TIME_SLOT.elementAt(index)
                                          ? const Icon(Icons.check)
                                          : null,
                                      child: Center(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Text(TIME_SLOT.elementAt(index)),
                                            Text(listTimeSlot.contains(index)
                                                ? 'Занято'
                                                : maxTimeSlot > index
                                                    ? 'Недоступно'
                                                    : 'Доступно')
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ));
                      }
                    },
                  );
                }
              }),
        )
      ],
    );
  }

  confirmBooking(WidgetRef ref, BuildContext context) async {
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
      batch.commit().then((value) async {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(scaffoldKey.currentContext!)
            .showSnackBar(const SnackBar(
          content: Text('Запись оформлена'),
        ));
        //Create Event
        final Event event = Event(
            title: 'Запись на стрижку',
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

  displayConfirm(WidgetRef ref, BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.all(24),
            child: Image.asset('assets/images/logo.png'),
          ),
          SizedBox(
            width: MediaQuery.of(context).size.width,
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Text(
                      'Спасибо, что воспользовались нашими услугами!'
                          .toUpperCase(),
                      style:
                          GoogleFonts.robotoMono(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      'Информация о записи'.toUpperCase(),
                      style: GoogleFonts.robotoMono(),
                    ),
                    Row(
                      children: [
                        const Icon(Icons.calendar_today),
                        const SizedBox(
                          width: 10,
                        ),
                        Text(
                          '${ref.read(selectedTime.notifier).state} - ${DateFormat('dd/MMMM/yyyy', 'ru').format(ref.read(selectedDate.notifier).state)}'
                              .toUpperCase(),
                          style: GoogleFonts.robotoMono(),
                        ),
                      ],
                    ),
                    const SizedBox(
                      width: 10,
                    ),
                    Row(
                      children: [
                        const Icon(Icons.person),
                        const SizedBox(
                          width: 10,
                        ),
                        Text(
                          ref
                              .read(selectedBarber.notifier)
                              .state
                              .name
                              .toUpperCase(),
                          style: GoogleFonts.robotoMono(),
                        ),
                      ],
                    ),
                    const SizedBox(
                      width: 10,
                    ),
                    const Divider(
                      thickness: 1,
                    ),
                    Row(
                      children: [
                        const Icon(Icons.home),
                        const SizedBox(
                          width: 10,
                        ),
                        Text(
                          ref
                              .read(selectedSalon.notifier)
                              .state
                              .name
                              .toUpperCase(),
                          style: GoogleFonts.robotoMono(),
                        ),
                      ],
                    ),
                    const SizedBox(
                      width: 10,
                    ),
                    Row(
                      children: [
                        const Icon(Icons.location_on),
                        const SizedBox(
                          width: 10,
                        ),
                        Flexible(
                          child: Text(
                            ref
                                .read(selectedSalon.notifier)
                                .state
                                .address
                                .toUpperCase(),
                            style: GoogleFonts.robotoMono(),
                          ),
                        )
                      ],
                    ),
                    Row(
                      children: [
                        const Icon(Icons.content_cut),
                        const SizedBox(
                          width: 10,
                        ),
                        Flexible(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              for (var selectedService
                                  in ref.read(selectedServices.notifier).state)
                                Text(
                                  '${selectedService.name}: ${selectedService.price} руб.',
                                  style: GoogleFonts.robotoMono(),
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        const Icon(Icons.money),
                        const SizedBox(
                          width: 10,
                        ),
                        Flexible(
                          child: Text(
                            'Общая стоимость: ${calculateTotalPrice(ref.read(selectedServices.notifier).state)} руб.',
                            style: GoogleFonts.robotoMono(),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 8,
                    ),
                    ElevatedButton(
                      onPressed: () => confirmBooking(ref, context),
                      style: ButtonStyle(
                          backgroundColor:
                              MaterialStateProperty.all(Colors.black26)),
                      child: const Text('Подтвердить',
                          style: TextStyle(color: Colors.white)),
                    )
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
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
}
