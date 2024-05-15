import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:untitled2/string/strings.dart';
import 'package:untitled2/view_model/booking/booking_view_model.dart';
import '../../../model/city_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

displayCityList(WidgetRef ref, BookingViewModel bookingViewModel) {
  return FutureBuilder(
      future: bookingViewModel.displayCities(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        } else {
          var cities = snapshot.data as List<CityModel>;
          if (cities.isEmpty) {
            return const Center(
              child: Text(cannotLoadCityText),
            );
          } else {
            return ListView.builder(
                key: const PageStorageKey('keep'),
                itemCount: cities.length,
                itemBuilder: (context, index) {
                  return GestureDetector(
                    onTap: () => bookingViewModel.onSelectedCity(ref, context, cities[index]),
                    child: Card(
                      child: ListTile(
                        leading: const Icon(
                          Icons.home_work,
                          color: Colors.black,
                        ),
                        trailing:
                        bookingViewModel.isCitySelected(ref, context, cities[index])
                            ? const Icon(Icons.check)
                            : null,
                        title: Text(
                          cities[index].name,
                          style: GoogleFonts.robotoMono(),
                        ),
                      ),
                    ),
                  );
                });
          }
        }
      });
}