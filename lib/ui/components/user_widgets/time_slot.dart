import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker_plus/flutter_datetime_picker_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:untitled2/view_model/booking/booking_view_model.dart';
import '../../../model/barber_model.dart';
import '../../../state/state_management.dart';
import '../../../utils/utils.dart';

displayTimeSlot(
    WidgetRef ref, BookingViewModel bookingViewModel, BuildContext context, BarberModel barberModel) {
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
            future: bookingViewModel.displayMaxAvailableTimeslot(
                ref.read(selectedDate.notifier).state),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              } else {
                var maxTimeSlot = snapshot.data as int;
                return FutureBuilder(
                  future: bookingViewModel.displayTimeSlotOfBarber(
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
                          key: const PageStorageKey('keep'),
                          itemCount: timeSlot.length,
                          gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 3),
                          itemBuilder: (context, index) => GestureDetector(
                            onTap: bookingViewModel.isAvailableForTapTimeSlot(maxTimeSlot, index, listTimeSlot)
                                ? null
                                : () {
                              bookingViewModel.onSelectedTimeSlot(ref, context, index);

                            },
                            child: Card(
                              color: bookingViewModel.displayColorTimeSlot(ref, context, listTimeSlot, index, maxTimeSlot),
                              child: GridTile(
                                header: ref
                                    .read(selectedTime.notifier)
                                    .state ==
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
                                      Text(timeSlot.elementAt(index)),
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