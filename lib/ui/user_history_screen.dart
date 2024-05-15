import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:untitled2/state/state_management.dart';
import 'package:untitled2/utils/utils.dart';
import 'package:untitled2/view_model/user_history/user_history_view_model_imp.dart';
import '../model/booking_model.dart';

class UserHistory extends ConsumerWidget {
  final scaffoldKey = GlobalKey<ScaffoldState>();
  final userHistoryViewModel = UserHistoryViewModelImp();

  UserHistory({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    var watchRefresh = ref.watch(deleteFlagRefresh);
    return SafeArea(
        child: Scaffold(
      key: scaffoldKey,
          appBar: AppBar(
            title: const Text(
              'История записи',
              style: TextStyle(
                color: Colors.white, // Здесь указывается цвет текста
              ),
            ),
            backgroundColor: const Color(0xFF383838),
            iconTheme: const IconThemeData(color: Colors.white),
          ),
      resizeToAvoidBottomInset: true,
      backgroundColor: const Color(0xFFFDF9EE),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: FutureBuilder(
            future: userHistoryViewModel.displayUserHistory(),
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
                    child: Text('Не удалось загрузить историю записи'),
                  );
                } else {
                  return FutureBuilder(
                      future: syncTime(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        } else {
                          var syncTime = snapshot.data as DateTime;
                          return ListView.builder(
                              itemCount: userBookings.length,
                              itemBuilder: (context, index) {
                                var isExpired = DateTime.fromMillisecondsSinceEpoch(
                                    userBookings[index].timeStamp)
                                    .isBefore(syncTime);
                                return Card(
                                  elevation: 8,
                                  shape: const RoundedRectangleBorder(
                                      borderRadius:
                                      BorderRadius.all(Radius.circular(22))),
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
                                              MainAxisAlignment.spaceBetween,
                                              children: [
                                                Column(
                                                  children: [
                                                    Text(
                                                      'Дата',
                                                      style:
                                                      GoogleFonts.robotoMono(),
                                                    ),
                                                    Text(
                                                      DateFormat("dd/MM/yy").format(
                                                          DateTime
                                                              .fromMillisecondsSinceEpoch(
                                                              userBookings[
                                                              index]
                                                                  .timeStamp)),
                                                      style: GoogleFonts.robotoMono(
                                                          fontSize: 22,
                                                          fontWeight:
                                                          FontWeight.bold),
                                                    ),
                                                  ],
                                                ),
                                                Column(
                                                  children: [
                                                    Text(
                                                      'Время',
                                                      style:
                                                      GoogleFonts.robotoMono(),
                                                    ),
                                                    Text(
                                                      TIME_SLOT.elementAt(
                                                          userBookings[index].slot),
                                                      style: GoogleFonts.robotoMono(
                                                          fontSize: 22,
                                                          fontWeight:
                                                          FontWeight.bold),
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
                                              MainAxisAlignment.spaceAround,
                                              crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                              children: [
                                                Row(
                                                  mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                                  children: [
                                                    Text(
                                                      userBookings[index].salonName,
                                                      style: GoogleFonts.robotoMono(
                                                          fontSize: 20,
                                                          fontWeight:
                                                          FontWeight.bold),
                                                    ),
                                                    Text(
                                                      userBookings[index].barberName,
                                                      style:
                                                      GoogleFonts.robotoMono(),
                                                    ),
                                                  ],
                                                ),
                                                Text(
                                                  userBookings[index].salonAddress,
                                                  style: GoogleFonts.robotoMono(),
                                                ),
                                              ],
                                            ),
                                            const Divider(
                                              thickness: 1,
                                            ),
                                            Text(
                                              'Услуги:',
                                              style: GoogleFonts.robotoMono(
                                                  fontSize: 20,
                                                  fontWeight: FontWeight.bold),
                                            ),

                                            // Display services and prices
                                            for (var service
                                            in userBookings[index].services)
                                              Row(
                                                mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                                children: [
                                                  Text(
                                                    service.name,
                                                    style: GoogleFonts.robotoMono(),
                                                  ),
                                                  Text(
                                                    '${service.price} руб.',
                                                    style: GoogleFonts.robotoMono(),
                                                  ),
                                                ],
                                              ),
                                            const Divider(
                                              thickness: 1,
                                            ),
                                            // Display total price
                                            Row(
                                              mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                              children: [
                                                Text(
                                                  'Окончательная цена:',
                                                  style: GoogleFonts.robotoMono(fontSize: 16,
                                                      fontWeight: FontWeight.bold),
                                                ),
                                                Text(
                                                  '${userBookings[index].totalPrice} руб.',
                                                  style: GoogleFonts.robotoMono(),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                      GestureDetector(
                                        onTap: (userBookings[index].done ||
                                            isExpired)
                                            ? null
                                            : () {
                                          Alert(
                                            context: context,
                                            type: AlertType.warning,
                                            title: 'Удалить запись',
                                            desc:
                                            'Пожалуйста, удалите ещё и запись из календаря',
                                            buttons: [
                                              DialogButton(
                                                onPressed: () =>
                                                    Navigator.of(context)
                                                        .pop(),
                                                color: Colors.white,
                                                child: Text(
                                                  'Отмена',
                                                  style:
                                                  GoogleFonts.robotoMono(
                                                      color:
                                                      Colors.black),
                                                ),
                                              ),
                                              DialogButton(
                                                onPressed: () {
                                                  Navigator.of(context)
                                                      .pop(); // ok
                                                  userHistoryViewModel.userCancelBooking(ref, context, userBookings[index]);
                                                },
                                                color: Colors.white,
                                                child: Text(
                                                  'Удалить',
                                                  style:
                                                  GoogleFonts.robotoMono(
                                                      color: Colors.red),
                                                ),
                                              ),
                                            ],
                                          ).show();
                                        },
                                        child: Container(
                                          decoration: const BoxDecoration(
                                            color: Colors.blue,
                                            borderRadius: BorderRadius.only(
                                                bottomRight: Radius.circular(22),
                                                bottomLeft: Radius.circular(22)),
                                          ),
                                          child: Row(
                                            mainAxisAlignment:
                                            MainAxisAlignment.center,
                                            children: [
                                              Padding(
                                                padding: const EdgeInsets.symmetric(
                                                    vertical: 10),
                                                child: Text(
                                                  userBookings[index].done
                                                      ? 'Завершена'
                                                      : isExpired
                                                      ? 'Просрочена'
                                                      : 'Отмена',
                                                  style: GoogleFonts.robotoMono(
                                                      color: isExpired
                                                          ? Colors.grey
                                                          : Colors.white),
                                                ),
                                              )
                                            ],
                                          ),
                                        ),
                                      )
                                    ],
                                  ),
                                );
                              });
                        }
                      });
                }
              }
            }),
      ),
    ));
  }
}
