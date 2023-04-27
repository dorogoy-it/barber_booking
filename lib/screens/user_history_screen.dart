import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:untitled2/cloud_firestore/user_ref.dart';
import 'package:untitled2/utils/utils.dart';
import '../model/booking_model.dart';

class UserHistory extends ConsumerWidget {
  GlobalKey<ScaffoldState> scaffoldKey = new GlobalKey();

  @override
  Widget build(BuildContext context, watch) {
    return SafeArea(
        child: Scaffold(
      key: scaffoldKey,
      appBar: AppBar(
        title: Text('User History'),
        backgroundColor: Color(0xFF383838),
      ),
      resizeToAvoidBottomInset: true,
      backgroundColor: Color(0xFFFDF9EE),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: displayUserHistory(),
      ),
    ));
  }

  displayUserHistory() {
    return FutureBuilder(
        future: getUserHistory(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting)
            return Center(
              child: CircularProgressIndicator(),
            );
          else {
            var userBookings = snapshot.data as List<BookingModel>;
            if (userBookings.length == 0)
              return Center(
                child: Text('Cannot load Booking information'),
              );
            else
              return ListView.builder(
                  itemCount: userBookings.length,
                  itemBuilder: (context, index) {
                    return Card(
                      elevation: 8,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(Radius.circular(22))),
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
                                      children: [
                                        Text(
                                          'Date',
                                          style: GoogleFonts.robotoMono(),
                                        ),
                                        Text(
                                          DateFormat("dd/MM/yy").format(DateTime
                                              .fromMillisecondsSinceEpoch(
                                                  userBookings[index]
                                                      .timeStamp)),
                                          style: GoogleFonts.robotoMono(
                                              fontSize: 22,
                                              fontWeight: FontWeight.bold),
                                        ),
                                      ],
                                    ),
                                    Column(
                                      children: [
                                        Text(
                                          'Time',
                                          style: GoogleFonts.robotoMono(),
                                        ),
                                        Text(
                                          TIME_SLOT.elementAt(
                                              userBookings[index].slot),
                                          style: GoogleFonts.robotoMono(
                                              fontSize: 22,
                                              fontWeight: FontWeight.bold),
                                        ),
                                      ],
                                    )
                                  ],
                                ),
                                Divider(thickness: 1,),
                                Column(mainAxisAlignment: MainAxisAlignment.spaceAround,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                    Text('${userBookings[index].salonName}',
                                    style: GoogleFonts.robotoMono(fontSize: 20, fontWeight: FontWeight.bold),
                                    ),
                                    Text('${userBookings[index].barberName}',
                                      style: GoogleFonts.robotoMono(),
                                    ),
                                  ],),
                                  Text('${userBookings[index].salonAddress}',
                                    style: GoogleFonts.robotoMono(),
                                  ),
                                ],
                                )
                              ],
                            ),
                          ),
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.blue,
                              borderRadius: BorderRadius.only(
                                bottomRight: Radius.circular(22),
                                bottomLeft: Radius.circular(22)
                              ),
                            ),
                            child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                              Padding(padding: const EdgeInsets.symmetric(vertical: 10),
                              child: Text('CANCEL', style: GoogleFonts.robotoMono(color: Colors.white),),)
                            ],),
                          )
                        ],
                      ),
                    );
                  });
          }
        });
  }
}
