import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:untitled2/state/state_management.dart';
import '../cloud_firestore/all_salon_ref.dart';
import '../model/city_model.dart';
import '../model/salon_model.dart';

class AdminHome extends ConsumerWidget {
  const AdminHome({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    var currentAdminStep = ref.watch(staffStep);
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
            currentAdminStep == 1
                ? 'Выберите город'
                : currentAdminStep == 2
                ? 'Выберите салон'
                : currentAdminStep == 3
                ? 'Выберите действие'
                : 'Домашняя страница сотрудника',
            style: const TextStyle(
              color: Colors.white,
            ),
          ),
          backgroundColor: const Color(0xFF383838),
          iconTheme: const IconThemeData(color: Colors.white),
        ),
        body: Column(
          children: [
            Expanded(
              child: currentAdminStep == 1
                  ? displayCity(ref)
                  : currentAdminStep == 2
                  ? displaySalon(ref, cityWatch.name)
                  : currentAdminStep == 3
                  ? displayAppointment(ref, context)
                  : Container(),
              flex: 10,
            ),
            // Кнопки навигации
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
                          onPressed: currentAdminStep == 1
                              ? null
                              : () => ref.read(staffStep.notifier).state--,
                          child: const Text('Предыдущая'),
                        ),
                      ),
                      const SizedBox(width: 30),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: (currentAdminStep == 1 &&
                              ref.read(selectedCity.notifier).state.name ==
                                  '') ||
                              (currentAdminStep == 2 &&
                                  ref.read(selectedSalon.notifier).state.docId ==
                                      '') ||
                              currentAdminStep == 3
                              ? null
                              : () => ref.read(staffStep.notifier).state++,
                          child: const Text('Следующая'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  displayCity(WidgetRef ref) {
    return FutureBuilder(
        future: getCities(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          } else {
            var cities = snapshot.data as List<CityModel>;
            if (cities.isEmpty) {
              return const Center(
                child: Text('Не удалось загрузить список городов'),
              );
            } else {
              return GridView.builder(
                  itemCount: cities.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2),
                  itemBuilder: (context, index) {
                    return GestureDetector(
                      onTap: () =>
                      ref.read(selectedCity.notifier).state = cities[index],
                      child: Padding(
                        padding: const EdgeInsets.all(8),
                        child: Card(
                          shape: ref.read(selectedCity.notifier).state.name ==
                              cities[index].name
                              ? RoundedRectangleBorder(
                              side:
                              const BorderSide(color: Colors.green, width: 4),
                              borderRadius: BorderRadius.circular(5))
                              : null,
                          child: Center(
                            child: Text(cities[index].name),
                          ),
                        ),
                      ),
                    );
                  });
            }
          }
        });
  }

  displaySalon(WidgetRef ref, String name) {
    return FutureBuilder(
        future: getSalonsWithCurrentAdmin(name),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          } else {
            var salons = snapshot.data as List<SalonModel>;
            if (salons.isEmpty) {
              return const Center(
                child: Text('Не удалось загрузить список салонов'),
              );
            } else {
              return ListView.builder(
                  itemCount: salons.length,
                  itemBuilder: (context, index) {
                    return GestureDetector(
                      onTap: () =>
                      ref.read(selectedSalon.notifier).state = salons[index],
                      child: Card(
                        child: ListTile(
                          shape: ref.read(selectedSalon.notifier).state.name ==
                              salons[index].name
                              ? RoundedRectangleBorder(
                              side:
                              const BorderSide(color: Colors.green, width: 4),
                              borderRadius: BorderRadius.circular(5))
                              : null,
                          leading: const Icon(
                            Icons.home_outlined,
                            color: Colors.black,
                          ),
                          trailing: ref.read(selectedSalon.notifier).state.docId ==
                              salons[index].docId
                              ? const Icon(Icons.check)
                              : null,
                          title: Text(
                            salons[index].name,
                            style: GoogleFonts.robotoMono(),
                          ),
                          subtitle: Text(
                            salons[index].address,
                            style: GoogleFonts.robotoMono(
                                fontStyle: FontStyle.italic),
                          ),
                        ),
                      ),
                    );
                  });
            }
          }
        });
  }

  displayAppointment(WidgetRef ref, BuildContext context) {
    //First, we need check is this user a admin of this salon
    return FutureBuilder(
        future: checkAdminOfThisSalon(ref, context),
        builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else {
            var result = snapshot.data as bool;
            if (result) {
              return displayAdminActions(context);
            } else {
              return const Center(
                  child: Text('Простите! Вы в этом салоне не работаете'));
            }
          }
        });
  }


  // Метод для отображения действий администратора
  displayAdminActions(BuildContext context) {
    return ListView(
      children: [
        ListTile(
          leading: const Icon(Icons.delete),
          title: const Text('Удалить запись'),
          onTap: () {
            // Вызов метода для удаления записи
            Navigator.pushNamed(context, '/deleteBooking');
          },
        ),
        ListTile(
          leading: const Icon(Icons.person_add),
          title: const Text('Добавить парикмахера'),
          onTap: () {
            // Вызов метода для добавления парикмахера
            Navigator.pushNamed(context, '/addBarber');
          },
        ),
        ListTile(
          leading: const Icon(Icons.person_remove),
          title: const Text('Удалить парикмахера'),
          onTap: () {
            // Вызов метода для добавления парикмахера
            Navigator.pushNamed(context, '/removeBarber');
          },
        ),
        ListTile(
          leading: const Icon(Icons.date_range),
          title: const Text('Записать клиента'),
          onTap: () {
            // Вызов метода для переноса записи
            Navigator.pushNamed(context, '/rescheduleBooking');
          },
        ),
        ListTile(
          leading: const Icon(Icons.admin_panel_settings),
          title: const Text('Добавить администратора'),
          onTap: () {
            // Вызов метода для добавления администратора
            Navigator.pushNamed(context, '/addAdmin');
          },
        ),
        ListTile(
          leading: const Icon(Icons.edit),
          title: const Text('Редактировать данные о салоне'),
          onTap: () {
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: const Text('Выберите, что редактировать'),
                  content: SingleChildScrollView(
                    child: ListBody(
                      children: <Widget>[
                        GestureDetector(
                          child: const Text('Название и адрес салона'),
                          onTap: () {
                            Navigator.pop(context);
                            // Вызов метода для редактирования названия и адреса салона
                            Navigator.pushNamed(context, '/editSalonInfo');
                          },
                        ),
                        const Padding(
                          padding: EdgeInsets.all(8.0),
                        ),
                        GestureDetector(
                          child: const Text('Предоставляемые услуги салона'),
                          onTap: () {
                            Navigator.pop(context);
                            // Вызов метода для редактирования услуг салона
                            Navigator.pushNamed(context, '/editSalonServices');
                          },
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        ),
      ],
    );
  }
}
