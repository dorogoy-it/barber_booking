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
  GlobalKey<ScaffoldState> scaffoldKey = new GlobalKey();

  @override
  Widget build(BuildContext context, watch) {
    var step = watch(currentStep).state;
    var cityWatch = watch(selectedCity).state;
    var salonWatch = watch(selectedSalon).state;
    var barberWatch = watch(selectedBarber).state;
    var dateWatch = watch(selectedDate).state;
    var timeWatch = watch(selectedTime).state;
    var timeSlotWatch = watch(selectedTimeSlot).state;
    var selectedServicesList = watch(selectedServices).state;
    return SafeArea(
        child: Scaffold(
      key: scaffoldKey,
      appBar: AppBar(
        title: Text(
          'Запись',
          style: TextStyle(
            color: Colors.white, // Здесь указывается цвет текста
          ),
        ),
        backgroundColor: Color(0xFF383838),
        iconTheme: IconThemeData(color: Colors.white),
      ),
      resizeToAvoidBottomInset: true,
      backgroundColor: Color(0xFFFDF9EE),
      body: Column(
        children: [
          //Step
          NumberStepper(
            activeStep: step - 1,
            direction: Axis.horizontal,
            enableNextPreviousButtons: false,
            enableStepTapping: false,
            numbers: [1, 2, 3, 4, 5, 6],
            stepColor: Colors.black,
            activeStepColor: Colors.grey,
            numberStyle: TextStyle(color: Colors.white),
          ),
          //Screen
          Expanded(
            flex: 10,
            child: step == 1
                ? displayCityList()
                : step == 2
                    ? displaySalon(cityWatch.name)
                    : step == 3
                        ? displayBarber(salonWatch)
                        : step == 4
                            ? displayServices(context, watch)
                            : step == 5
                                ? displayTimeSlot(context, barberWatch)
                                : step == 6
                                    ? displayConfirm(context)
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
                        : () => context.read(currentStep).state--,
                    child: Text('Предыдущая'),
                  )),
                  SizedBox(
                    width: 30,
                  ),
                  Expanded(
                      child: ElevatedButton(
                    onPressed: (step == 1 &&
                                context.read(selectedCity).state.name == '') ||
                            (step == 2 &&
                                context.read(selectedSalon).state.docId ==
                                    '') ||
                            (step == 3 &&
                                context.read(selectedBarber).state.docId ==
                                    '') ||
                            (step == 4 &&
                                context.read(selectedServices).state.isEmpty) ||
                            (step == 5 &&
                                context.read(selectedTimeSlot).state == -1)
                        ? null
                        : step == 6
                            ? null
                            : () => context.read(currentStep).state++,
                    child: Text('Следующая'),
                  )),
                ],
              ),
            ),
          ))
        ],
      ),
    ));
  }

  displayCityList() {
    return FutureBuilder(
        future: getCities(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting)
            return Center(
              child: CircularProgressIndicator(),
            );
          else {
            var cities = snapshot.data as List<CityModel>;
            if (cities.length == 0)
              return Center(
                child: Text('Не удалось загрузить список городов'),
              );
            else
              return ListView.builder(
                  itemCount: cities.length,
                  itemBuilder: (context, index) {
                    return GestureDetector(
                      onTap: () => context.read(selectedCity).state =
                          CityModel(name: cities[index].name),
                      child: Card(
                        child: ListTile(
                          leading: Icon(
                            Icons.home_work,
                            color: Colors.black,
                          ),
                          trailing: context.read(selectedCity).state.name ==
                                  cities[index].name
                              ? Icon(Icons.check)
                              : null,
                          title: Text(
                            '${cities[index].name}',
                            style: GoogleFonts.robotoMono(),
                          ),
                        ),
                      ),
                    );
                  });
          }
        });
  }

  displaySalon(String cityName) {
    return FutureBuilder(
      future: getSalonByCity(cityName),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting)
          return Center(
            child: CircularProgressIndicator(),
          );
        else {
          var salons = snapshot.data as List<SalonModel>;
          if (salons.length == 0)
            return Center(
              child: Text('Не удалось загрузить список салонов'),
            );
          else
            return ListView.builder(
              itemCount: salons.length,
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () {
                    // Опустошаем список услуг при выборе нового салона
                    context.read(selectedServices).state = [];
                    // Устанавливаем выбранный салон
                    context.read(selectedSalon).state = salons[index];
                  },
                  child: Card(
                    child: ListTile(
                      leading: Icon(
                        Icons.home_outlined,
                        color: Colors.black,
                      ),
                      trailing: context.read(selectedSalon).state.docId ==
                          salons[index].docId
                          ? Icon(Icons.check)
                          : null,
                      title: Text(
                        '${salons[index].name}',
                        style: GoogleFonts.robotoMono(),
                      ),
                      subtitle: Text(
                        '${salons[index].address}',
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
      },
    );
  }

  displayBarber(SalonModel salonModel) {
    return FutureBuilder(
        future: getBarbersBySalon(salonModel),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting)
            return Center(
              child: CircularProgressIndicator(),
            );
          else {
            var barbers = snapshot.data != null
                ? List<BarberModel>.from(snapshot.data as Iterable)
                : [];
            if (barbers.length == 0)
              return Center(
                child: Text('Список парикмахеров пуст'),
              );
            else
              return ListView.builder(
                  itemCount: barbers.length,
                  itemBuilder: (context, index) {
                    return GestureDetector(
                      onTap: () =>
                          context.read(selectedBarber).state = barbers[index],
                      child: Card(
                        child: ListTile(
                          leading: Icon(
                            Icons.person,
                            color: Colors.black,
                          ),
                          trailing: context.read(selectedBarber).state.docId ==
                                  barbers[index].docId
                              ? Icon(Icons.check)
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
                            itemBuilder: (context, _) => Icon(
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
        });
  }

  displayServices(BuildContext context, ScopedReader watch) {
    var selectedServicesList = watch(selectedServices).state;
    var totalPrice = calculateTotalPrice(selectedServicesList);

    return FutureBuilder(
      future: getServices(context),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting)
          return Center(
            child: CircularProgressIndicator(),
          );
        else {
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
                              labelStyle: TextStyle(color: Colors.white),
                              backgroundColor: Colors.teal,
                              onSelected: (isSelected) {
                                var list = selectedServicesList.toList();
                                if (isSelected) {
                                  list.add(e);
                                } else {
                                  list.remove(e);
                                }
                                context.read(selectedServices).state = list;
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

  displayTimeSlot(BuildContext context, BarberModel barberModel) {
    var now = context.read(selectedDate).state;
    return Column(
      children: [
        Container(
          color: Color(0xFF008577),
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
                        '${DateFormat.MMMM('ru').format(now)}',
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
                        '${DateFormat.EEEE('ru').format(now)}',
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
                      maxTime: now.add(Duration(days: 31)),
                      onConfirm: (date) => context.read(selectedDate).state =
                          date); //next time you can choose is 31 days next
                },
                child: Padding(
                  padding: const EdgeInsets.all(8),
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
              future: getMaxAvailableTimeSlot(context.read(selectedDate).state),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting)
                  return Center(
                    child: CircularProgressIndicator(),
                  );
                else {
                  var maxTimeSlot = snapshot.data as int;
                  return FutureBuilder(
                    future: getTimeSlotOfBarber(
                        barberModel,
                        DateFormat('dd_MM_yyyy', 'ru')
                            .format(context.read(selectedDate).state)),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting)
                        return Center(
                          child: CircularProgressIndicator(),
                        );
                      else {
                        var listTimeSlot = snapshot.data as List<int>;
                        return GridView.builder(
                            itemCount: TIME_SLOT.length,
                            gridDelegate:
                                SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 3),
                            itemBuilder: (context, index) => GestureDetector(
                                  onTap: maxTimeSlot > index ||
                                          listTimeSlot.contains(index)
                                      ? null
                                      : () {
                                          context.read(selectedTime).state =
                                              TIME_SLOT.elementAt(index);
                                          context.read(selectedTimeSlot).state =
                                              index;
                                        },
                                  child: Card(
                                    color: listTimeSlot.contains(index)
                                        ? Colors.white10
                                        : maxTimeSlot > index
                                            ? Colors.white60
                                            : context
                                                        .read(selectedTime)
                                                        .state ==
                                                    TIME_SLOT.elementAt(index)
                                                ? Colors.white54
                                                : Colors.white,
                                    child: GridTile(
                                      child: Center(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Text(
                                                '${TIME_SLOT.elementAt(index)}'),
                                            Text(listTimeSlot.contains(index)
                                                ? 'Занято'
                                                : maxTimeSlot > index
                                                    ? 'Недоступно'
                                                    : 'Доступно')
                                          ],
                                        ),
                                      ),
                                      header:
                                          context.read(selectedTime).state ==
                                                  TIME_SLOT.elementAt(index)
                                              ? Icon(Icons.check)
                                              : null,
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

  confirmBooking(BuildContext context) async {
    var hour = context.read(selectedTime).state.length <= 10
        ? int.parse(
            context.read(selectedTime).state.split(':')[0].substring(0, 1))
        : int.parse(
            context.read(selectedTime).state.split(':')[0].substring(0, 2));

    var minutes = context.read(selectedTime).state.length <= 10
        ? int.parse(
            context.read(selectedTime).state.split(':')[1].substring(0, 1))
        : int.parse(
            context.read(selectedTime).state.split(':')[1].substring(0, 2));
    var timeStamp = DateTime(
            context.read(selectedDate).state.year,
            context.read(selectedDate).state.month,
            context.read(selectedDate).state.day,
            hour, //hour
            minutes //minutes
            )
        .millisecondsSinceEpoch;

    // Check if booking exists
    bool bookingExists = await checkBookingExists(
      context.read(selectedBarber).state.docId!,
      context.read(selectedDate).state,
      FirebaseAuth.instance.currentUser!.uid,
    );

    if (bookingExists) {
      // Show error message to the user
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content:
        Text('Сначала удалите старую запись.'),
      ));
      return; // Exit the function to prevent further processing
    } else {
      var bookingModel = BookingModel(
          barberId: context.read(selectedBarber).state.docId!,
          barberName: context.read(selectedBarber).state.name,
          cityBook: context.read(selectedCity).state.name,
          customerId: FirebaseAuth.instance.currentUser!.uid,
          customerName: context.read(userInformation).state.name,
          customerPhone: FirebaseAuth.instance.currentUser!.phoneNumber!,
          done: false,
          salonAddress: context.read(selectedSalon).state.address,
          salonId: context.read(selectedSalon).state.docId!,
          salonName: context.read(selectedSalon).state.name,
          services: context.read(selectedServices).state,
          slot: context.read(selectedTimeSlot).state,
          totalPrice: calculateTotalPrice(context.read(selectedServices).state),
          timeStamp: timeStamp,
          time:
          '${context.read(selectedTime).state} - ${DateFormat('dd/MM/yyyy').format(context.read(selectedDate).state)}');

      var batch = FirebaseFirestore.instance.batch();

      DocumentReference barberBooking = context
          .read(selectedBarber)
          .state
          .reference!
          .collection(
          '${DateFormat('dd_MM_yyyy').format(context.read(selectedDate).state)}')
          .doc(context.read(selectedTimeSlot).state.toString());
      DocumentReference userBooking = FirebaseFirestore.instance
          .collection('User')
          .doc(FirebaseAuth.instance.currentUser!.phoneNumber!)
          .collection(
          'Booking_${FirebaseAuth.instance.currentUser!.uid}') //For secure info
          .doc(
          '${context.read(selectedBarber).state.docId}_${DateFormat('dd_MM_yyyy').format(context.read(selectedDate).state)}');

      //Set for batch
      batch.set(barberBooking, bookingModel.toJson());
      batch.set(userBooking, bookingModel.toJson());
      batch.commit().then((value) async {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(scaffoldKey.currentContext!).showSnackBar(SnackBar(
          content: Text('Запись оформлена'),
        ));
        final Event event = Event(
            title: 'Запись на стрижку',
            description:
            'Запись на стрижку ${context.read(selectedTime).state} - '
                '${DateFormat('dd/MMMM/yyyy', 'ru').format(context.read(selectedDate).state)}',
            location: '${context.read(selectedSalon).state.address}',
            startDate: DateTime(
                context.read(selectedDate).state.year,
                context.read(selectedDate).state.month,
                context.read(selectedDate).state.day,
                hour,
                minutes),
            endDate: DateTime(
                context.read(selectedDate).state.year,
                context.read(selectedDate).state.month,
                context.read(selectedDate).state.day,
                hour,
                minutes + 30),
            iosParams: IOSParams(reminder: Duration(minutes: 30)),
            androidParams: AndroidParams(emailInvites: []));
        Add2Calendar.addEvent2Cal(event).then((value) {});

        //Reset value
        context.read(selectedDate).state = DateTime.now();
        context.read(selectedBarber).state = BarberModel();
        context.read(selectedCity).state = CityModel(name: '');
        context.read(selectedSalon).state = SalonModel(name: '', address: '');
        context.read(selectedServices).state = List<ServiceModel>.empty(growable: true);
        context.read(currentStep).state = 1;
        context.read(selectedTime).state = '';
        context.read(selectedTimeSlot).state = -1;

        //Create Event
      });
      //Submit on FireStore
    }
  }

  displayConfirm(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.all(24),
            child: Image.asset('assets/images/logo.png'),
          ),
          Container(
            child: Container(
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
                          Icon(Icons.calendar_today),
                          SizedBox(
                            width: 10,
                          ),
                          Text(
                            '${context.read(selectedTime).state} - ${DateFormat('dd/MMMM/yyyy', 'ru').format(context.read(selectedDate).state)}'
                                .toUpperCase(),
                            style: GoogleFonts.robotoMono(),
                          ),
                        ],
                      ),
                      SizedBox(
                        width: 10,
                      ),
                      Row(
                        children: [
                          Icon(Icons.person),
                          SizedBox(
                            width: 10,
                          ),
                          Text(
                            '${context.read(selectedBarber).state.name}'
                                .toUpperCase(),
                            style: GoogleFonts.robotoMono(),
                          ),
                        ],
                      ),
                      SizedBox(
                        width: 10,
                      ),
                      Divider(
                        thickness: 1,
                      ),
                      Row(
                        children: [
                          Icon(Icons.home),
                          SizedBox(
                            width: 10,
                          ),
                          Text(
                            '${context.read(selectedSalon).state.name}'
                                .toUpperCase(),
                            style: GoogleFonts.robotoMono(),
                          ),
                        ],
                      ),
                      SizedBox(
                        width: 10,
                      ),
                      Row(
                        children: [
                          Icon(Icons.location_on),
                          SizedBox(
                            width: 10,
                          ),
                          Flexible(
                            child: Text(
                              '${context.read(selectedSalon).state.address}'
                                  .toUpperCase(),
                              style: GoogleFonts.robotoMono(),
                            ),
                          )
                        ],
                      ),
                      Row(
                        children: [
                          Icon(Icons.content_cut),
                          SizedBox(
                            width: 10,
                          ),
                          Flexible(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                for (var selectedService
                                    in context.read(selectedServices).state)
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
                          Icon(Icons.money),
                          SizedBox(
                            width: 10,
                          ),
                          Flexible(
                            child: Text(
                              'Общая стоимость: ${calculateTotalPrice(context.read(selectedServices).state)} руб.',
                              style: GoogleFonts.robotoMono(),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 8,
                      ),
                      ElevatedButton(
                        onPressed: () => confirmBooking(context),
                        child: Text('Подтвердить'),
                        style: ButtonStyle(
                            backgroundColor:
                                MaterialStateProperty.all(Colors.black26)),
                      )
                    ],
                  ),
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
        .doc(
        '${barberId}_${DateFormat('dd_MM_yyyy').format(date)}');

    var userBookingSnapshot = await userBookingReference.get();

    return userBookingSnapshot.exists;
  }
}
