import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:untitled2/string/strings.dart';
import 'package:untitled2/view_model/booking/booking_view_model.dart';

import '../../../state/state_management.dart';

displayConfirm(WidgetRef ref, BookingViewModel bookingViewModel, BuildContext context, GlobalKey<ScaffoldState> scaffoldKey) {
  return SingleChildScrollView(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Padding(
          padding: const EdgeInsets.all(24),
          child: Image.asset('assets/images/logo.png'),
        ),
        SizedBox(
          width: MediaQuery.of(context).size.width,
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Text(
                    thankServiceText.toUpperCase(),
                    style:
                    GoogleFonts.robotoMono(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    bookingInformationText.toUpperCase(),
                    style: GoogleFonts.robotoMono(),
                  ),
                  Row(
                    children: [
                      const Icon(Icons.calendar_today),
                      const SizedBox(
                        width: 10,
                      ),
                      Text(
                        '${ref.read(selectedTime.notifier).state} - ${DateFormat('dd/MMMM/yyyy', 'ru').format(ref.read(selectedDate.notifier).state)}'
                            .toUpperCase(),
                        style: GoogleFonts.robotoMono(),
                      ),
                    ],
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                  Row(
                    children: [
                      const Icon(Icons.person),
                      const SizedBox(
                        width: 10,
                      ),
                      Text(
                        ref
                            .read(selectedBarber.notifier)
                            .state
                            .name
                            .toUpperCase(),
                        style: GoogleFonts.robotoMono(),
                      ),
                    ],
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                  const Divider(
                    thickness: 1,
                  ),
                  Row(
                    children: [
                      const Icon(Icons.home),
                      const SizedBox(
                        width: 10,
                      ),
                      Text(
                        ref
                            .read(selectedSalon.notifier)
                            .state
                            .name
                            .toUpperCase(),
                        style: GoogleFonts.robotoMono(),
                      ),
                    ],
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                  Row(
                    children: [
                      const Icon(Icons.location_on),
                      const SizedBox(
                        width: 10,
                      ),
                      Flexible(
                        child: Text(
                          ref
                              .read(selectedSalon.notifier)
                              .state
                              .address
                              .toUpperCase(),
                          style: GoogleFonts.robotoMono(),
                        ),
                      )
                    ],
                  ),
                  Row(
                    children: [
                      const Icon(Icons.content_cut),
                      const SizedBox(
                        width: 10,
                      ),
                      Flexible(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            for (var selectedService
                            in ref.read(selectedServices.notifier).state)
                              Text(
                                '${selectedService.name}: ${selectedService.price} руб.',
                                style: GoogleFonts.robotoMono(),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      const Icon(Icons.money),
                      const SizedBox(
                        width: 10,
                      ),
                      Flexible(
                        child: Text(
                          'Общая стоимость: ${bookingViewModel.calculateTotalPrice(ref.read(selectedServices.notifier).state)} руб.',
                          style: GoogleFonts.robotoMono(),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 8,
                  ),
                  ElevatedButton(
                    onPressed: () => bookingViewModel.confirmBooking(ref, context, scaffoldKey),
                    style: ButtonStyle(
                        backgroundColor:
                        WidgetStateProperty.all(Colors.black26)),
                    child: const Text('Подтвердить',
                        style: TextStyle(color: Colors.white)),
                  )
                ],
              ),
            ),
          ),
        ),
      ],
    ),
  );
}