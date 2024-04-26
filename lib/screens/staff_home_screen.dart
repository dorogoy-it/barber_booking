import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker_plus/flutter_datetime_picker_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:untitled2/state/state_management.dart';
import '../cloud_firestore/all_salon_ref.dart';
import '../model/city_model.dart';
import '../model/salon_model.dart';
import '../utils/utils.dart';

class StaffHome extends ConsumerWidget {
  const StaffHome({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    var currentStaffStep = ref.watch(staffStep);
    var cityWatch = ref.watch(selectedCity);
    var salonWatch = ref.watch(selectedSalon);
    var dateWatch = ref.watch(selectedDate);
    var selectTimeWatch = ref.watch(selectedTime);
    return SafeArea(
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        backgroundColor: const Color(0xFFDFDFDF),
        appBar: AppBar(
          title: Text(currentStaffStep == 1
              ? 'Выберите город'
              : currentStaffStep == 2
                  ? 'Выберите салон'
                  : currentStaffStep == 3
                      ? 'Ваша запись'
                      : 'Домашняя страница сотрудника',
            style: const TextStyle(
            color: Colors.white, // Здесь указывается цвет текста
          ),
        ),
          backgroundColor: const Color(0xFF383838),
          iconTheme: const IconThemeData(color: Colors.white),
        ),
        body: Column(
          children: [
            //Area
            Expanded(
              child: currentStaffStep == 1
                  ? displayCity(ref)
                  : currentStaffStep == 2
                      ? displaySalon(ref, cityWatch.name)
                      : currentStaffStep == 3
                          ? displayAppointment(ref, context)
                          : Container(),
              flex: 10,
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
                      onPressed: currentStaffStep == 1
                          ? null
                          : () => ref.read(staffStep.notifier).state--,
                      child: const Text('Предыдущая'),
                    )),
                    const SizedBox(
                      width: 30,
                    ),
                    Expanded(
                        child: ElevatedButton(
                      onPressed: (currentStaffStep == 1 &&
                                  ref.read(selectedCity.notifier).state.name ==
                                      '') ||
                              (currentStaffStep == 2 &&
                                  ref.read(selectedSalon.notifier).state.docId ==
                                      '') ||
                              currentStaffStep == 3
                          ? null
                          : () => ref.read(staffStep.notifier).state++,
                      child: const Text('Следующая'),
                    )),
                  ],
                ),
              ),
            ))
          ],
        ),
      ),
    );
  }

  displayCity(WidgetRef ref) {
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
              return GridView.builder(
                  itemCount: cities.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2),
                  itemBuilder: (context, index) {
                    return GestureDetector(
                      onTap: () =>
                          ref.read(selectedCity.notifier).state = cities[index],
                      child: Padding(
                        padding: const EdgeInsets.all(8),
                        child: Card(
                          shape: ref.read(selectedCity.notifier).state.name ==
                                  cities[index].name
                              ? RoundedRectangleBorder(
                                  side:
                                      const BorderSide(color: Colors.green, width: 4),
                                  borderRadius: BorderRadius.circular(5))
                              : null,
                          child: Center(
                            child: Text(cities[index].name),
                          ),
                        ),
                      ),
                    );
                  });
            }
          }
        });
  }

  displaySalon(WidgetRef ref, String name) {
    return FutureBuilder(
        future: getSalonByCity(name),
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
                      onTap: () =>
                          ref.read(selectedSalon.notifier).state = salons[index],
                      child: Card(
                        child: ListTile(
                          shape: ref.read(selectedSalon.notifier).state.name ==
                                  salons[index].name
                              ? RoundedRectangleBorder(
                                  side:
                                      const BorderSide(color: Colors.green, width: 4),
                                  borderRadius: BorderRadius.circular(5))
                              : null,
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
                                fontStyle: FontStyle.italic),
                          ),
                        ),
                      ),
                    );
                  });
            }
          }
        });
  }

  displayAppointment(WidgetRef ref, BuildContext context) {
    //First, we need check is this user a staff of this salon
    return FutureBuilder(
        future: checkStaffOfThisSalon(ref, context),
        builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else {
            var result = snapshot.data as bool;
            if (result) {
              return displaySlot(ref, context);
            } else {
              return const Center(
                  child: Text('Простите! Вы в этом салоне не работаете'));
            }
          }
        });
  }

  displaySlot(WidgetRef ref, BuildContext context) {
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
                      minTime: DateTime.now(), // Fix can't select current date
                      maxTime: now.add(const Duration(days: 31)),
                      onConfirm: (date) => ref.read(selectedDate.notifier).state =
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
              future: getMaxAvailableTimeSlot(ref.read(selectedDate.notifier).state),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                } else {
                  var maxTimeSlot = snapshot.data as int;
                  return FutureBuilder(
                    future: getBookingSlotOfBarber(
                      ref, context,
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
                                crossAxisCount: 4),
                            itemBuilder: (context, index) => GestureDetector(
                              onTap:
                                  !listTimeSlot.contains(index)
                                  ? null
                                  : () => processDoneServices(ref, context, index),
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
              }),
        )
      ],
    );
  }

  processDoneServices(WidgetRef ref, BuildContext context, int index) {
      ref.read(selectedTimeSlot.notifier).state =
          index;
      Navigator.of(context).pushNamed('/doneService');
  }
}
