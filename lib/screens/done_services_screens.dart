import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:untitled2/model/booking_model.dart';
import 'package:untitled2/state/state_management.dart';
import '../cloud_firestore/all_salon_ref.dart';
import '../utils/utils.dart';

class DoneService extends ConsumerWidget {
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey();

  DoneService({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    //When refresh, clear servicesSelected, because ChipChoices don't hold state
    ref.read(selectedServices.notifier).state.clear();
    return SafeArea(
      child: Scaffold(
        key: scaffoldKey,
        resizeToAvoidBottomInset: true,
        backgroundColor: const Color(0xFFDFDFDF),
        appBar: AppBar(
          title: const Text(
            'Завершение оформления',
            style: TextStyle(
              color: Colors.white, // Здесь указывается цвет текста
            ),
          ),
          backgroundColor: const Color(0xFF383838),
          iconTheme: const IconThemeData(color: Colors.white),
        ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8),
              child: FutureBuilder(
                future: getDetailBooking(
                    ref, context, ref.read(selectedTimeSlot.notifier).state),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  } else {
                    var bookingModel = snapshot.data as BookingModel;
                    return Card(
                      elevation: 8,
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(22)),
                      ),
                      child: Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                  MainAxisAlignment.spaceBetween,
                                  children: [
                                    Column(
                                      crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Клиент:',
                                          style: GoogleFonts.robotoMono(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        Text(
                                          bookingModel.customerName,
                                          style: GoogleFonts.robotoMono(
                                            fontSize: 16,
                                          ),
                                        ),
                                      ],
                                    ),
                                    Column(
                                      crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Телефон:',
                                          style: GoogleFonts.robotoMono(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        Text(
                                          bookingModel.customerPhone,
                                          style: GoogleFonts.robotoMono(
                                            fontSize: 16,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                const Divider(
                                  thickness: 1,
                                ),
                                Row(
                                  mainAxisAlignment:
                                  MainAxisAlignment.spaceBetween,
                                  children: [
                                    Column(
                                      crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Дата',
                                          style: GoogleFonts.robotoMono(),
                                        ),
                                        Text(
                                          DateFormat("dd/MM/yy").format(DateTime
                                              .fromMillisecondsSinceEpoch(
                                              bookingModel.timeStamp)),
                                          style: GoogleFonts.robotoMono(
                                            fontSize: 22,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                    Column(
                                      crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Время',
                                          style: GoogleFonts.robotoMono(),
                                        ),
                                        Text(
                                          TIME_SLOT
                                              .elementAt(bookingModel.slot),
                                          style: GoogleFonts.robotoMono(
                                            fontSize: 22,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                const Divider(
                                  thickness: 1,
                                ),
                                Column(
                                  mainAxisAlignment:
                                  MainAxisAlignment.spaceAround,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          bookingModel.salonName,
                                          style: GoogleFonts.robotoMono(
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        Text(
                                          bookingModel.barberName,
                                          style: GoogleFonts.robotoMono(),
                                        ),
                                      ],
                                    ),
                                    Text(
                                      bookingModel.salonAddress,
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
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                // Display services and prices
                                for (var service in bookingModel.services)
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
                                      style: GoogleFonts.robotoMono(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      '${bookingModel.totalPrice} руб.',
                                      style: GoogleFonts.robotoMono(),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  }
                },
              ),
            ),
            const SizedBox(height: 20), // Add some spacing
            Container(
              width: MediaQuery.of(context).size.width,
              padding: const EdgeInsets.all(8),
              child: ElevatedButton(
                onPressed: () => finishService(ref, context),
                child: Text(
                  'Завершить',
                  style: GoogleFonts.robotoMono(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  finishService(WidgetRef ref, BuildContext context) async {
    var batch = FirebaseFirestore.instance.batch();
    var barberBook = ref.read(selectedBooking.notifier).state;

    var userBook = FirebaseFirestore.instance
        .collection('User')
        .doc(barberBook.customerPhone)
        .collection('Booking_${barberBook.customerId}')
        .doc(
        '${barberBook.barberId}_${DateFormat('dd_MM_yyyy').format(DateTime.fromMillisecondsSinceEpoch(barberBook.timeStamp))}');
    Map<String, dynamic> updateDone = {};
    updateDone['done'] = true;

    batch.update(userBook, updateDone);
    batch.update(barberBook.reference!, updateDone);

    batch.commit().then((value) {
      ScaffoldMessenger.of(scaffoldKey.currentContext!)
          .showSnackBar(const SnackBar(content: Text('Процесс успешно завершён')))
          .closed
          .then((v) => Navigator.of(context).pop());
    });
  }
}