import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:untitled2/string/strings.dart';
import 'package:untitled2/view_model/booking/booking_view_model.dart';
import '../../../model/salon_model.dart';

displaySalon(WidgetRef ref, BookingViewModel bookingViewModel, String cityName) {
  return FutureBuilder(
    future: bookingViewModel.displaySalonByCity(ref, cityName),
    builder: (context, snapshot) {
      if (snapshot.connectionState == ConnectionState.waiting) {
        return const Center(
          child: CircularProgressIndicator(),
        );
      } else {
        var salons = snapshot.data as List<SalonModel>;
        if (salons.isEmpty) {
          return const Center(
            child: Text(cannotLoadSalonListText),
          );
        } else {
          return ListView.builder(
            key: const PageStorageKey('keep'),
            itemCount: salons.length,
            itemBuilder: (context, index) {
              return GestureDetector(
                onTap: () {
                  // Опустошаем список услуг при выборе нового салона
                  bookingViewModel.changeSalon(ref, context);
                  // Устанавливаем выбранный салон
                  bookingViewModel.onSelectedSalon(ref, context, salons[index]);
                },
                child: Card(
                  child: ListTile(
                    leading: const Icon(
                      Icons.home_outlined,
                      color: Colors.black,
                    ),
                    trailing: bookingViewModel.isSalonSelected(ref, context, salons[index])
                        ? const Icon(Icons.check)
                        : null,
                    title: Text(
                      salons[index].name,
                      style: GoogleFonts.robotoMono(),
                    ),
                    subtitle: Text(
                      salons[index].address,
                      style: GoogleFonts.robotoMono(
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
                ),
              );
            },
          );
        }
      }
    },
  );
}