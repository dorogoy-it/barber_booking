import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:untitled2/state/state_management.dart';
import '../cloud_firestore/all_salon_ref.dart';
import '../model/city_model.dart';
import '../model/salon_model.dart';
import '../utils/utils.dart';

class StaffHome extends ConsumerWidget {
  @override
  Widget build(BuildContext context, watch) {
    var currentStaffStep = watch(staffStep).state;
    var cityWatch = watch(selectedCity).state;
    var salonWatch = watch(selectedSalon).state;
    var dateWatch = watch(selectedDate).state;
    var selectTimeWatch = watch(selectedTime).state;
    return SafeArea(
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        backgroundColor: Color(0xFFDFDFDF),
        appBar: AppBar(
          title: Text(currentStaffStep == 1
              ? 'Выберите город'
              : currentStaffStep == 2
                  ? 'Выберите салон'
                  : currentStaffStep == 3
                      ? 'Ваша запись'
                      : 'Домашняя страница сотрудника'),
          backgroundColor: Color(0xFF383838),
        ),
        body: Column(
          children: [
            //Area
            Expanded(
              child: currentStaffStep == 1
                  ? displayCity()
                  : currentStaffStep == 2
                      ? displaySalon(cityWatch.name)
                      : currentStaffStep == 3
                          ? displayAppointment(context)
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
                          : () => context.read(staffStep).state--,
                      child: Text('Предыдущая'),
                    )),
                    SizedBox(
                      width: 30,
                    ),
                    Expanded(
                        child: ElevatedButton(
                      onPressed: (currentStaffStep == 1 &&
                                  context.read(selectedCity).state.name ==
                                      '') ||
                              (currentStaffStep == 2 &&
                                  context.read(selectedSalon).state.docId ==
                                      '') ||
                              currentStaffStep == 3
                          ? null
                          : () => context.read(staffStep).state++,
                      child: Text('Следующая'),
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

  displayCity() {
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
              return GridView.builder(
                  itemCount: cities.length,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2),
                  itemBuilder: (context, index) {
                    return GestureDetector(
                      onTap: () =>
                          context.read(selectedCity).state = cities[index],
                      child: Padding(
                        padding: const EdgeInsets.all(8),
                        child: Card(
                          shape: context.read(selectedCity).state.name ==
                                  cities[index].name
                              ? RoundedRectangleBorder(
                                  side:
                                      BorderSide(color: Colors.green, width: 4),
                                  borderRadius: BorderRadius.circular(5))
                              : null,
                          child: Center(
                            child: Text('${cities[index].name}'),
                          ),
                        ),
                      ),
                    );
                  });
          }
        });
  }

  displaySalon(String name) {
    return FutureBuilder(
        future: getSalonByCity(name),
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
                      onTap: () =>
                          context.read(selectedSalon).state = salons[index],
                      child: Card(
                        child: ListTile(
                          shape: context.read(selectedSalon).state.name ==
                                  salons[index].name
                              ? RoundedRectangleBorder(
                                  side:
                                      BorderSide(color: Colors.green, width: 4),
                                  borderRadius: BorderRadius.circular(5))
                              : null,
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
                                fontStyle: FontStyle.italic),
                          ),
                        ),
                      ),
                    );
                  });
          }
        });
  }

  displayAppointment(BuildContext context) {
    //First, we need check is this user a staff of this salon
    return FutureBuilder(
        future: checkStaffOfThisSalon(context),
        builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else {
            var result = snapshot.data as bool;
            if (result) {
              return displaySlot(context);
            } else {
              return Center(
                  child: Text('Простите! Вы в этом салоне не работаете'));
            }
          }
        });
  }

  displaySlot(BuildContext context) {
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
                            '${DateFormat.MMMM().format(now)}',
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
                            '${DateFormat.EEEE().format(now)}',
                            style: GoogleFonts.robotoMono(color: Colors.white54),
                          ),
                        ],
                      ),
                    ),
                  )),
              GestureDetector(
                onTap: () {
                  DatePicker.showDatePicker(context,
                      showTitleActions: true,
                      minTime: DateTime.now(), // Fix can't select current date
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
                    future: getBookingSlotOfBarber(
                      context,
                        DateFormat('dd_MM_yyyy')
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
                              onTap:
                                  !listTimeSlot.contains(index)
                                  ? null
                                  : () => processDoneServices(context, index),
                              child: Card(
                                color: listTimeSlot.contains(index)
                                    ? Colors.white10 :
                                maxTimeSlot > index ? Colors.white60
                                    : context.read(selectedTime).state ==
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
                                        Text(

                                            listTimeSlot.contains(index)
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

  processDoneServices(BuildContext context, int index) {
      context.read(selectedTimeSlot).state =
          index;
      Navigator.of(context).pushNamed('/doneService');
  }
}
