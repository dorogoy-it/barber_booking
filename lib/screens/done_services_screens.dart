import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:untitled2/model/booking_model.dart';
import 'package:untitled2/model/service_model.dart';
import 'package:untitled2/state/state_management.dart';
import '../cloud_firestore/all_salon_ref.dart';
import '../cloud_firestore/services_ref.dart';
import '../utils/utils.dart';

class DoneService extends ConsumerWidget {
  GlobalKey<ScaffoldState> scaffoldKey = GlobalKey();

  @override
  Widget build(BuildContext context, watch) {
    //When refresh, clear servicesSelected, because ChipChoices don't hold state
    context.read(selectedServices).state.clear();
    return SafeArea(
      child: Scaffold(
        key: scaffoldKey,
        resizeToAvoidBottomInset: true,
        backgroundColor: Color(0xFFDFDFDF),
        appBar: AppBar(
          title: Text('Услуги завершения'),
          backgroundColor: Color(0xFF383838),
        ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8),
              child: FutureBuilder(
                future: getDetailBooking(
                    context, context.read(selectedTimeSlot).state),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting)
                    return Center(
                      child: CircularProgressIndicator(),
                    );
                  else {
                    var bookingModel = snapshot.data as BookingModel;
                    return Card(
                      elevation: 8,
                      child: Padding(
                        padding: const EdgeInsets.all(8),
                        child: Column(
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                CircleAvatar(
                                  child: Icon(Icons.account_box_rounded,
                                      color: Colors.white),
                                  backgroundColor: Colors.black,
                                ),
                                SizedBox(
                                  width: 30,
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('${bookingModel.customerName}',
                                        style: GoogleFonts.robotoMono(
                                            fontSize: 22,
                                            fontWeight: FontWeight.bold)),
                                    Text('${bookingModel.customerPhone}',
                                        style: GoogleFonts.robotoMono(
                                            fontSize: 18)),
                                  ],
                                )
                              ],
                            ),
                            Divider(
                              thickness: 2,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Consumer(builder: (context, watch, _) {
                                  var servicesSelected =
                                      watch(selectedServices).state;
                                  var totalPrice = servicesSelected
                                      .map((item) => item.price)
                                      .fold(
                                          0.0,
                                          (value, element) =>
                                              double.parse(value.toString()) +
                                              element);
                                  return Text(
                                    'Price \$${context.read(selectedBooking).state.totalPrice == 0 ? totalPrice : context.read(selectedBooking).state.totalPrice}',
                                    style: GoogleFonts.robotoMono(fontSize: 22),
                                  );
                                }),
                                context.read(selectedBooking).state.done
                                    ? Chip(
                                        label: Text('Завершено'),
                                      )
                                    : Container()
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  }
                },
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: FutureBuilder(
                    future: getServices(context),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting)
                        return Center(
                          child: CircularProgressIndicator(),
                        );
                      else {
                        var services = snapshot.data as List<ServiceModel>;
                        return Consumer(builder: (context, watch, _) {
                          var servicesWatch = watch(selectedServices).state;
                          return SingleChildScrollView(
                              child: Column(
                            children: [
                              Wrap(
                                children: services.map((e) => Padding(
                                    padding: const EdgeInsets.all(4),
                                    child: ChoiceChip(
                                        selected: context.read(selectedServices).state.contains(e),
                                        selectedColor: Colors.blue,
                                        label: Text('${e.name}'),
                                        labelStyle: TextStyle(color: Colors.white),
                                        backgroundColor: Colors.teal,
                                        onSelected: (isSelected){
                                          var list = context.read(selectedServices).state;
                                          if (isSelected)
                                            {
                                              list.add(e);
                                              context.read(selectedServices).state = list;
                                            }
                                          else{
                                            list.remove(e);
                                            context.read(selectedServices).state = list;
                                          }
                                      },
                                    ),
                                )).toList(),
                              ),
                              Container(
                                width: MediaQuery.of(context).size.width,
                                child: ElevatedButton(
                                  onPressed:
                                      context.read(selectedBooking).state.done
                                          ? null
                                          : servicesWatch.length > 0
                                              ? () => finishService(context)
                                              : null,
                                  child: Text(
                                    'Завершено',
                                    style: GoogleFonts.robotoMono(),
                                  ),
                                ),
                              )
                            ],
                          ));
                        });
                      }
                    }),
              ),
            )
          ],
        ),
      ),
    );
  }

  finishService(BuildContext context) {
    var batch = FirebaseFirestore.instance.batch();
    var barberBook = context.read(selectedBooking).state;

    var userBook = FirebaseFirestore.instance
        .collection('User')
        .doc('${barberBook.customerPhone}')
        .collection('Booking_${barberBook.customerId}')
        .doc(
            '${barberBook.barberId}_${DateFormat('dd_MM_yyyy').format(DateTime.fromMillisecondsSinceEpoch(barberBook.timeStamp))}');
    Map<String, dynamic> updateDone = new Map();
    updateDone['done'] = true;
    updateDone['services'] =
        convertServices(context.read(selectedServices).state);
    updateDone['totalPrice'] = context
        .read(selectedServices)
        .state
        .map((e) => e.price)
        .fold(
            0.0,
            (previousValue, element) =>
                double.parse(previousValue.toString()) + element);

    batch.update(userBook, updateDone);
    batch.update(barberBook.reference!, updateDone);

    batch.commit().then((value) {
      ScaffoldMessenger.of(scaffoldKey.currentContext!)
          .showSnackBar(SnackBar(content: Text('Процесс успешно завершён')))
          .closed
          .then((v) => Navigator.of(context).pop());
    });
  }
}
