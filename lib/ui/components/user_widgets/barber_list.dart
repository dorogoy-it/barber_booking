import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:untitled2/view_model/booking/booking_view_model.dart';
import '../../../model/barber_model.dart';
import '../../../model/salon_model.dart';
import '../../../string/strings.dart';

displayBarber(WidgetRef ref, BookingViewModel bookingViewModel, SalonModel salonModel) {
  return FutureBuilder(
      future: bookingViewModel.displayBarbersBySalon(ref, salonModel),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        } else {
          var barbers = snapshot.data != null
              ? List<BarberModel>.from(snapshot.data as Iterable)
              : [];
          if (barbers.isEmpty) {
            return const Center(
              child: Text(barberEmptyText),
            );
          } else {
            return ListView.builder(
                key: const PageStorageKey('keep'),
                itemCount: barbers.length,
                itemBuilder: (context, index) {
                  return GestureDetector(
                    onTap: () => bookingViewModel.onSelectedBarber(ref, context, barbers[index]),
                    child: Card(
                      child: ListTile(
                        leading: const Icon(
                          Icons.person,
                          color: Colors.black,
                        ),
                        trailing:
                        bookingViewModel.isBarberSelected(ref, context, barbers[index])
                            ? const Icon(Icons.check)
                            : null,
                        title: Text(
                          '${barbers[index].name}',
                          style: GoogleFonts.robotoMono(),
                        ),
                        subtitle: RatingBar.builder(
                          itemSize: 16,
                          allowHalfRating: true,
                          initialRating: barbers[index].rating,
                          ignoreGestures: true,
                          direction: Axis.horizontal,
                          itemCount: 5,
                          onRatingUpdate: (double value) {},
                          itemBuilder: (context, _) => const Icon(
                            Icons.star,
                            color: Colors.amber,
                          ),
                          itemPadding: const EdgeInsets.all(4),
                        ),
                      ),
                    ),
                  );
                });
          }
        }
      });
}