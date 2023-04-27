import 'package:carousel_slider/carousel_slider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:untitled2/model/image_model.dart';
import 'package:untitled2/state/state_management.dart';
import '../cloud_firestore/all_salon_ref.dart';
import '../cloud_firestore/banner_ref.dart';
import '../cloud_firestore/lookbook_ref.dart';
import '../cloud_firestore/user_ref.dart';
import '../model/city_model.dart';
import '../model/salon_model.dart';
import '../model/user_model.dart';

class StaffHome extends ConsumerWidget {
  @override
  Widget build(BuildContext context, watch) {
    var currentStaffStep = watch(staffStep).state;
    var cityWatch = watch(selectedCity).state;
    var salonWatch = watch(selectedSalon).state;
    return SafeArea(
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        backgroundColor: Color(0xFFDFDFDF),
        appBar: AppBar(
          title: Text(currentStaffStep == 1
              ? 'Select City'
              : currentStaffStep == 2
                  ? 'Select Salon'
                  : currentStaffStep == 3
                      ? 'Your Appointment'
                      : 'Staff Home'),
          backgroundColor: Color(0xFF383838),
        ),
        body: Column(
          children: [
            //Area
            Expanded(
              child: currentStaffStep == 1 ? displayCity() : currentStaffStep == 2 ? displaySalon(cityWatch.name) : Container(),
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
                      child: Text('Previous'),
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
                          : () => context
                          .read(staffStep)
                          .state++,
                      child: Text('Next'),
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
                child: Text('Cannot load city list'),
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
                child: Text('Cannot load Salon list'),
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


}
