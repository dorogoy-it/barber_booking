import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker_plus/flutter_datetime_picker_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:untitled2/view_model/barber_booking_history/barber_booking_history_view_model_imp.dart';
import '../model/booking_model.dart';
import '../state/staff_user_history_state.dart';
import '../utils/utils.dart';

class BarberHistoryScreen extends ConsumerWidget {
  BarberHistoryScreen({super.key});

  final barberHistoryViewModel = BarberBookingHistoryViewModelImp();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    var dateWatch = ref.watch(barberHistorySelectedDate);
    return SafeArea(
        child: Scaffold(
      backgroundColor: const Color(0xFFDFDFDF),
      appBar: AppBar(
        title: const Text('История парикмахера',
            style: TextStyle(
              color: Colors.white, // Здесь указывается цвет текста
            ),
        ),
        backgroundColor: const Color(0xFF383838),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Column(
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
                          DateFormat.MMMM('ru').format(dateWatch),
                          style: GoogleFonts.robotoMono(color: Colors.white54),
                        ),
                        Text(
                          '${dateWatch.day}',
                          style: GoogleFonts.robotoMono(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 22),
                        ),
                        Text(
                          DateFormat.EEEE('ru').format(dateWatch),
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
                        onConfirm: (date) => ref
                                .read(barberHistorySelectedDate.notifier)
                                .state =
                            date);
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
                  future: barberHistoryViewModel.getBarberBookingHistory(
                      ref, context, dateWatch),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    } else if (snapshot.hasError) {
                      return Center(
                        child: Text('Error: ${snapshot.error}'),
                      );
                    } else if (snapshot.data == null) {
                      return const Center(
                        child: Text('Data is null'),
                      );
                    } else {
                      var userBookings = snapshot.data as List<BookingModel>;
                      if (userBookings.isEmpty) {
                        return const Center(
                          child: Text('У вас нет записей на эту дату'),
                        );
                      } else {
                        return FutureBuilder(
                            future: syncTime(),
                            builder: (context, snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return const Center(
                                  child: CircularProgressIndicator(),
                                );
                              } else {
                                var syncTime = snapshot.data as DateTime;
                                return ListView.builder(
                                    itemCount: userBookings.length,
                                    itemBuilder: (context, index) {
                                      return Card(
                                        elevation: 8,
                                        shape: const RoundedRectangleBorder(
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(22))),
                                        child: Column(
                                          children: [
                                            Padding(
                                              padding: const EdgeInsets.all(12),
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceBetween,
                                                    children: [
                                                      Column(
                                                        children: [
                                                          Text(
                                                            'Дата',
                                                            style: GoogleFonts
                                                                .robotoMono(),
                                                          ),
                                                          Text(
                                                            DateFormat(
                                                                    "dd/MM/yy")
                                                                .format(DateTime.fromMillisecondsSinceEpoch(
                                                                    userBookings[
                                                                            index]
                                                                        .timeStamp)),
                                                            style: GoogleFonts
                                                                .robotoMono(
                                                                    fontSize:
                                                                        22,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold),
                                                          ),
                                                        ],
                                                      ),
                                                      Column(
                                                        children: [
                                                          Text(
                                                            'Время',
                                                            style: GoogleFonts
                                                                .robotoMono(),
                                                          ),
                                                          Text(
                                                            TIME_SLOT.elementAt(
                                                                userBookings[
                                                                        index]
                                                                    .slot),
                                                            style: GoogleFonts
                                                                .robotoMono(
                                                                    fontSize:
                                                                        22,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold),
                                                          ),
                                                        ],
                                                      )
                                                    ],
                                                  ),
                                                  const Divider(
                                                    thickness: 1,
                                                  ),
                                                  Column(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceAround,
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .spaceBetween,
                                                        children: [
                                                          Text(
                                                            userBookings[index]
                                                                .salonName,
                                                            style: GoogleFonts
                                                                .robotoMono(
                                                                    fontSize:
                                                                        20,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold),
                                                          ),
                                                          Text(
                                                            userBookings[index]
                                                                .barberName,
                                                            style: GoogleFonts
                                                                .robotoMono(),
                                                          ),
                                                        ],
                                                      ),
                                                      Text(
                                                        userBookings[index]
                                                            .salonAddress,
                                                        style: GoogleFonts
                                                            .robotoMono(),
                                                      ),
                                                    ],
                                                  ),
                                                  const Divider(
                                                    thickness: 1,
                                                  ),
                                                  Text(
                                                    'Услуги:',
                                                    style:
                                                        GoogleFonts.robotoMono(
                                                            fontSize: 20,
                                                            fontWeight:
                                                                FontWeight
                                                                    .bold),
                                                  ),

                                                  // Display services and prices
                                                  for (var service
                                                      in userBookings[index]
                                                          .services)
                                                    Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .spaceBetween,
                                                      children: [
                                                        Text(
                                                          service.name,
                                                          style: GoogleFonts
                                                              .robotoMono(),
                                                        ),
                                                        Text(
                                                          '${service.price} руб.',
                                                          style: GoogleFonts
                                                              .robotoMono(),
                                                        ),
                                                      ],
                                                    ),
                                                  const Divider(
                                                    thickness: 1,
                                                  ),
                                                  // Display total price
                                                  Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceBetween,
                                                    children: [
                                                      Text(
                                                        'Окончательная цена:',
                                                        style: GoogleFonts
                                                            .robotoMono(
                                                                fontSize: 20,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold),
                                                      ),
                                                      Text(
                                                        '${userBookings[index].totalPrice} руб.',
                                                        style: GoogleFonts
                                                            .robotoMono(),
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      );
                                    });
                              }
                            });
                      }
                    }
                  }))
        ],
      ),
    ));
  }
}
