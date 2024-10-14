import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker_plus/flutter_datetime_picker_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:untitled2/view_model/staff_home/staff_home_view_model.dart';

import '../../../state/state_management.dart';
import '../../../string/strings.dart';
import '../../../utils/utils.dart';

displayAppointment(WidgetRef ref, StaffHomeViewModel staffHomeViewModel, BuildContext context) {
  // Проверяем, является ли пользователь сотрудником выбранного салона
  return FutureBuilder(
      future: staffHomeViewModel.isStaffOfThisSalon(ref, context),
      builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else {
          var result = snapshot.data as bool;
          if (result) {
            return displaySlot(ref, staffHomeViewModel, context);
          } else {
            return const Center(
                child: Text('Простите! Вы в этом салоне не работаете'));
          }
        }
      });
}

displaySlot(WidgetRef ref, StaffHomeViewModel staffHomeViewModel, BuildContext context) {
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
                    minTime: DateTime.now(), // исправление невозможности выбора текущей даты
                    maxTime: now.add(const Duration(days: 31)),
                    onConfirm: (date) => ref.read(selectedDate.notifier).state =
                        date); // в следующем месяце можно выбрать любой из 31 дня
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
            future: staffHomeViewModel.displayMaxAvailableTimeSlot(ref.read(selectedDate.notifier).state),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              } else {
                var maxTimeSlot = snapshot.data as int;
                return FutureBuilder(
                  future: staffHomeViewModel.displayBookingSlotOfBarber(
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
                        key: const PageStorageKey('keep'),
                          itemCount: timeSlot.length,
                          gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 4),
                          itemBuilder: (context, index) => GestureDetector(
                            onTap:
                            !listTimeSlot.contains(index)
                                ? null
                                : () => staffHomeViewModel.processDoneServices(ref, context, index),
                            child: Card(
                              color: staffHomeViewModel.getColorOfThisSlot(ref, context, listTimeSlot, index, maxTimeSlot),
                              child: GridTile(
                                header:
                                ref.read(selectedTime.notifier).state ==
                                    timeSlot.elementAt(index)
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
                                          timeSlot.elementAt(index)),
                                      Text(

                                          listTimeSlot.contains(index)
                                              ? fullText
                                              : maxTimeSlot > index
                                              ? notAvailableText
                                              : availableText)
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