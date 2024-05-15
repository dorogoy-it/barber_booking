import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../model/service_model.dart';
import '../../../state/state_management.dart';
import '../../../view_model/booking/booking_view_model.dart';

displayServices(WidgetRef ref, BookingViewModel bookingViewModel, BuildContext context) {
  var selectedServicesList = ref.watch(selectedServices);
  var totalPrice = bookingViewModel.calculateTotalPrice(selectedServicesList);

  return FutureBuilder(
    future: bookingViewModel.displayServices(ref, context),
    builder: (context, snapshot) {
      if (snapshot.connectionState == ConnectionState.waiting) {
        return const Center(
          child: CircularProgressIndicator(),
        );
      } else {
        var services = snapshot.data != null ? List<ServiceModel>.from(snapshot.data as Iterable) : [];

        return SingleChildScrollView(
          child: Column(
            children: [
              Wrap(
                children: services
                    .map((e) => Padding(
                  padding: const EdgeInsets.all(4),
                  child: ChoiceChip(
                    selected: bookingViewModel.isSelectedService(ref, context, e),
                    selectedColor: Colors.blue,
                    label: Text('${e.name}: ${e.price} руб.'),
                    labelStyle: const TextStyle(color: Colors.white),
                    backgroundColor: Colors.teal,
                    onSelected: (isSelected) => bookingViewModel.onSelectedChip(ref, context, isSelected, e)
                  ),
                ))
                    .toList(),
              ),
            ],
          ),
        );
      }
    },
  );
}