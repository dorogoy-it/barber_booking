import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:untitled2/state/state_management.dart';
import 'package:untitled2/ui/components/staff_widgets/city_list.dart';
import 'package:untitled2/ui/components/staff_widgets/salon_list.dart';
import 'package:untitled2/view_model/staff_home/staff_home_view_model_imp.dart';
import '../string/strings.dart';
import 'components/staff_widgets/appointment_list.dart';

class StaffHome extends ConsumerWidget {
  final staffHomeViewModel = StaffHomeViewModelImp();

  StaffHome({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    var currentStaffStep = ref.watch(staffStep);
    var cityWatch = ref.watch(selectedCity);
    var salonWatch = ref.watch(selectedSalon);
    var dateWatch = ref.watch(selectedDate);
    var selectTimeWatch = ref.watch(selectedTime);
    return SafeArea(
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        backgroundColor: const Color(0xFFDFDFDF),
        appBar: AppBar(
          title: Text(
            currentStaffStep == 1
                ? selectCityText
                : currentStaffStep == 2
                    ? selectSalonText
                    : currentStaffStep == 3
                        ? yourAppointmentText
                        : staffHomeText,
            style: const TextStyle(
              color: Colors.white, // Здесь указывается цвет текста
            ),
          ),
          backgroundColor: const Color(0xFF383838),
          iconTheme: const IconThemeData(color: Colors.white),
          actions: [
            currentStaffStep == 3
                ? InkWell(
                    child: const Icon(Icons.history),
                    onTap: () =>
                        Navigator.of(context).pushNamed('/bookingHistory'),
                  )
                : Container()
          ],
        ),
        body: Column(
          children: [
            //Area
            Expanded(
              child: currentStaffStep == 1
                  ? staffDisplayCity(ref, staffHomeViewModel)
                  : currentStaffStep == 2
                      ? staffDisplaySalon(
                          ref, staffHomeViewModel, cityWatch.name)
                      : currentStaffStep == 3
                          ? displayAppointment(ref, staffHomeViewModel, context)
                          : Container(),
              flex: 10,
            ),

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
                          : () => ref.read(staffStep.notifier).state--,
                      child: const Text(previousText),
                    )),
                    const SizedBox(
                      width: 30,
                    ),
                    Expanded(
                        child: ElevatedButton(
                      onPressed: (currentStaffStep == 1 &&
                                  ref.read(selectedCity.notifier).state.name ==
                                      '') ||
                              (currentStaffStep == 2 &&
                                  ref
                                          .read(selectedSalon.notifier)
                                          .state
                                          .docId ==
                                      '') ||
                              currentStaffStep == 3
                          ? null
                          : () => ref.read(staffStep.notifier).state++,
                      child: const Text(nextText),
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
}
