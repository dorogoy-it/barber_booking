import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:untitled2/state/state_management.dart';
import 'package:untitled2/view_model/booking/booking_view_model_imp.dart';
import 'package:untitled2/widgets/my_loading_widget.dart';
import 'components/user_widgets/barber_list.dart';
import 'components/user_widgets/city_list.dart';
import 'components/user_widgets/confirm.dart';
import 'components/user_widgets/salon_list.dart';
import 'components/user_widgets/services_list.dart';
import 'components/user_widgets/time_slot.dart';

class BookingScreen extends ConsumerWidget {
  final scaffoldKey = GlobalKey<ScaffoldState>();
  final bookingViewModel = BookingViewModelImp();

  BookingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    var step = ref.watch(currentStep);
    var cityWatch = ref.watch(selectedCity);
    var salonWatch = ref.watch(selectedSalon);
    var barberWatch = ref.watch(selectedBarber);
    var dateWatch = ref.watch(selectedDate);
    var timeWatch = ref.watch(selectedTime);
    var timeSlotWatch = ref.watch(selectedTimeSlot);
    var selectedServicesList = ref.watch(selectedServices);

    var isLoadingWatch = ref.watch(isLoading);
    return SafeArea(
        child: Scaffold(
      key: scaffoldKey,
      appBar: AppBar(
        title: const Text(
          'Запись',
          style: TextStyle(
            color: Colors.white, // Здесь указывается цвет текста
          ),
        ),
        backgroundColor: const Color(0xFF383838),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      resizeToAvoidBottomInset: true,
      backgroundColor: const Color(0xFFFDF9EE),
      body: Column(
        children: [
          // Экран
          Expanded(
            flex: 10,
            child: step == 1
                ? displayCityList(ref, bookingViewModel)
                : step == 2
                    ? displaySalon(ref, bookingViewModel, cityWatch.name)
                    : step == 3
                        ? displayBarber(ref, bookingViewModel, salonWatch)
                        : step == 4
                            ? displayServices(ref, bookingViewModel, context)
                            : step == 5
                                ? displayTimeSlot(
                                    ref, bookingViewModel, context, barberWatch)
                                : step == 6
                                    ? isLoadingWatch
                                        ? MyLoadingWidget(
                                            text: 'Оформляем вашу запись!')
                                        : displayConfirm(ref, bookingViewModel,
                                            context, scaffoldKey)
                                    : Container(),
          ),
          // Кнопки
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
                    onPressed: step == 1
                        ? null
                        : () => ref.read(currentStep.notifier).state--,
                    child: const Text('Предыдущая'),
                  )),
                  const SizedBox(
                    width: 30,
                  ),
                  Expanded(
                      child: ElevatedButton(
                    onPressed: (step == 1 &&
                                ref
                                    .read(selectedCity.notifier)
                                    .state
                                    .name
                                    .isEmpty) ||
                            (step == 2 &&
                                ref
                                    .read(selectedSalon.notifier)
                                    .state
                                    .docId!
                                    .isEmpty) ||
                            (step == 3 &&
                                ref
                                    .read(selectedBarber.notifier)
                                    .state
                                    .docId!
                                    .isEmpty) ||
                            (step == 4 &&
                                ref
                                    .read(selectedServices.notifier)
                                    .state
                                    .isEmpty) ||
                            (step == 5 &&
                                ref.read(selectedTimeSlot.notifier).state == -1)
                        ? null
                        : step == 6
                            ? null
                            : () => ref.read(currentStep.notifier).state++,
                    child: const Text('Следующая'),
                  )),
                ],
              ),
            ),
          ))
        ],
      ),
    ));
  }
}
