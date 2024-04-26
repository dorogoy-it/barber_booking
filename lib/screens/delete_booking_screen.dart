import 'package:untitled2/screens/reschedule_booking_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker_plus/flutter_datetime_picker_plus.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:untitled2/cloud_firestore/all_salon_ref.dart';
import 'package:untitled2/state/state_management.dart';
import 'package:untitled2/model/salon_model.dart';
import 'package:untitled2/utils/utils.dart';
import '../model/barber_model.dart';

class DeleteBooking extends ConsumerWidget {
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey();

  DeleteBooking({super.key});

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
                            onPressed: () {
                              ref.read(currentStep.notifier).state = 1;
                              Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => DeleteBooking()));
                            },
                            child: const Text('Удалить запись'),
                          ),
                        ),
                        const SizedBox(
                          width: 30,
                        ),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              ref.read(currentStep.notifier).state = 1;
                              Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => RescheduleBooking()));
                            },
                            child: const Text('Записать клиента'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              //Screen
              Expanded(
                flex: 10,
                child: step == 1
                    ? displayBarber(ref, salonWatch)
                    : step == 2
                    ? displayTimeSlot(ref, context)
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
                                    : () =>
                                ref.read(currentStep.notifier)
                                    .state--,
                                child: const Text('Предыдущая'),
                              )),
                          const SizedBox(
                            width: 30,
                          ),
                          Expanded(
                              child: ElevatedButton(
                                onPressed: (step == 1 &&
                                    ref.read(selectedBarber.notifier)
                                        .state
                                        .docId == '') ||
                                    (step == 2 &&
                                        ref.read(selectedTimeSlot.notifier)
                                            .state == -1)
                                    ? null
                                    : step == 3
                                    ? null
                                    : () =>
                                ref.read(currentStep.notifier)
                                    .state++,
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
                      onTap: () =>
                      ref.read(selectedBarber.notifier).state = barbers[index],
                      child: Card(
                        child: ListTile(
                          leading: const Icon(
                            Icons.person,
                            color: Colors.black,
                          ),
                          trailing: ref.read(selectedBarber.notifier).state.docId ==
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

  displayTimeSlot(WidgetRef ref, BuildContext context) {
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
                ),
              ),
              GestureDetector(
                onTap: () {
                  DatePicker.showDatePicker(context,
                      locale: LocaleType.ru,
                      showTitleActions: true,
                      minTime: DateTime(2022), // Fix can't select current date
                      maxTime: DateTime(DateTime.now().year, 12, 31),
                      onConfirm: (date) =>
                      ref.read(selectedDate.notifier).state = date); //next time you can choose is 31 days next
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
          child: FutureBuilder<int>(
            future: getMaxAvailableTimeSlot(ref.read(selectedDate.notifier).state),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              } else if (snapshot.hasError) {
                return Center(
                  child: Text('Ошибка: ${snapshot.error}'),
                );
              }
              else if (snapshot.data == null) {
                return const Center(
                  child: Text('Данных нет'),
                );
              } // Check if data is null
              else {
                var maxTimeSlot = snapshot.data as int;
                return FutureBuilder(
                  future: getBookingSlotOfBarberToAdmin(
                    ref, context,
                    DateFormat('dd_MM_yyyy', 'ru')
                        .format(ref.read(selectedDate.notifier).state),
                  ),
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
                              crossAxisCount: 4),
                          itemBuilder: (context, index) => GestureDetector(
                            onTap:
                            !listTimeSlot.contains(index)
                                ? null
                                : () => processDoneDeleting(ref, context, index),
                            child: Card(
                              color: listTimeSlot.contains(index)
                                  ? Colors.white10 :
                              maxTimeSlot > index ? Colors.white60
                                  : ref.read(selectedTime.notifier).state ==
                                  TIME_SLOT.elementAt(index)
                                  ? Colors.white54
                                  : Colors.white,
                              child: GridTile(
                                header:
                                ref.read(selectedTime.notifier).state ==
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
                                      Text(
                                          TIME_SLOT.elementAt(index)),
                                      Text(

                                          listTimeSlot.contains(index)
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
            },
          ),
        ),
      ],
    );
  }

  processDoneDeleting(WidgetRef ref, BuildContext context, int index) {
    ref.read(selectedTimeSlot.notifier).state =
        index;
    Navigator.of(context).pushNamed('/doneDeleting');
  }
}
