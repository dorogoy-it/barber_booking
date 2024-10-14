import 'package:carousel_slider/carousel_slider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:untitled2/model/image_model.dart';
import 'package:untitled2/state/state_management.dart';
import 'package:untitled2/view_model/home/home_view_model_imp.dart';
import '../cloud_firestore/user_ref.dart';
import '../model/barber_model.dart';
import '../model/city_model.dart';
import '../model/salon_model.dart';
import '../model/service_model.dart';
import '../model/user_model.dart';

class HomePage extends ConsumerWidget {
  HomePage({super.key});
  final homeViewModel = HomeViewModelImp();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return FutureBuilder<UserModel>(
      future: getUserProfiles(
          ref, context, FirebaseAuth.instance.currentUser!.phoneNumber!),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else {
          UserModel userModel = snapshot.data!;
          return FutureBuilder<void>(
            future: saveUserRole(userModel),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else {
                return SafeArea(
                  child: Scaffold(
                    resizeToAvoidBottomInset: true,
                    backgroundColor: const Color(0xFFDFDFDF),
                    body: SingleChildScrollView(
                      child: Column(children: [
                        // профиль пользователя
                        FutureBuilder(
                            future: homeViewModel.displayUserProfile(ref, context,
                                FirebaseAuth.instance.currentUser!
                                    .phoneNumber!),
                            builder: (context, snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return const Center(
                                  child: CircularProgressIndicator(),
                                );
                              } else {
                                var userModel = snapshot
                                    .data as UserModel;
                                return Container(
                                  decoration: const BoxDecoration(
                                      color: Color(0xFF383838)),
                                  padding: const EdgeInsets.all(16),
                                  child: Row(
                                    children: [
                                      const CircleAvatar(
                                        maxRadius: 30,
                                        backgroundColor: Colors.black,
                                        child: Icon(
                                          Icons.person,
                                          color: Colors.white,
                                          size: 30,
                                        ),
                                      ),
                                      const SizedBox(
                                        width: 30,
                                      ),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              userModel.name,
                                              style: GoogleFonts
                                                  .robotoMono(
                                                  fontSize: 22,
                                                  color: Colors.white,
                                                  fontWeight: FontWeight
                                                      .bold),
                                            ),
                                            Text(
                                              userModel.address,
                                              overflow: TextOverflow
                                                  .ellipsis,
                                              style: GoogleFonts
                                                  .robotoMono(
                                                fontSize: 18,
                                                color: Colors.white,
                                              ),
                                            )
                                          ],
                                        ),
                                      ),
                                      IconButton(
                                        icon: const Icon(
                                          Icons.logout,
                                          color: Colors.white,
                                        ),
                                        onPressed: () => signOut(ref, context),
                                      ),
                                          homeViewModel.isStaff(ref, context)
                                          ? IconButton(
                                        icon: const Icon(
                                          Icons.admin_panel_settings,
                                          color: Colors.white,
                                        ),
                                        onPressed: () =>
                                            Navigator.of(context)
                                                .pushNamed('/staffHome'),
                                      )
                                          : Container(),
                                      homeViewModel.isAdmin(ref, context)
                                          ? IconButton(
                                        icon: const Icon(
                                          Icons.supervisor_account,
                                          color: Colors.white,
                                        ),
                                        onPressed: () =>
                                            Navigator.of(context)
                                                .pushNamed('/adminHome'),
                                      )
                                          : Container()
                                    ],
                                  ),
                                );
                              }
                            }),
                        //Меню
                        Padding(
                          padding: const EdgeInsets.all(4),
                          child: _buildButtons(
                              context, ref
                              .read(userInformation.notifier)
                              .state),
                        ),
                        //Баннеры
                        FutureBuilder(
                            future: homeViewModel.displayBanner(),
                            builder: (context, snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return const Center(
                                  child: CircularProgressIndicator(),
                                );
                              } else {
                                var banners = snapshot.data as List<
                                    ImageModel>;
                                return CarouselSlider(
                                    options: CarouselOptions(
                                        enlargeCenterPage: true,
                                        aspectRatio: 3.0,
                                        autoPlay: true,
                                        autoPlayInterval: const Duration(
                                            seconds: 3)),
                                    items: banners
                                        .map((e) =>
                                        ClipRRect(
                                          borderRadius:
                                          BorderRadius.circular(8),
                                          child: Image.network(e.image),
                                        ))
                                        .toList());
                              }
                            }),
                        //Лукбуки (примеры работ)
                        Padding(
                          padding: const EdgeInsets.all(8),
                          child: Row(
                            children: [
                              Text(
                                'Примеры наших работ',
                                style: GoogleFonts.robotoMono(
                                    fontSize: 24),
                              )
                            ],
                          ),
                        ),
                        FutureBuilder(
                            future: homeViewModel.displayLookbook(),
                            builder: (context, snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return const Center(
                                  child: CircularProgressIndicator(),
                                );
                              } else if (!snapshot.hasData ||
                                  snapshot.data == null) {
                                return const SizedBox.shrink();
                              }
                              else {
                                var lookbook = snapshot.data as List<
                                    ImageModel>;
                                return Column(
                                  children: lookbook
                                      .map((e) =>
                                      Container(
                                        padding: const EdgeInsets.all(8),
                                        child: ClipRRect(
                                          borderRadius: BorderRadius
                                              .circular(8),
                                          child: Image.network(e.image),
                                        ),
                                      ))
                                      .toList(),
                                );
                              }
                            }),
                      ]),
                    ),
                  ),
                );
              }
            },
          );
        }
      },
    );
  }

  Future<void> signOut(WidgetRef ref, BuildContext context) async {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text("Выход"),
          content: const Text("Вы уверены, что хотите выйти?"),
          actions: [
            TextButton(
              onPressed: () async {
                // Закрываем диалог перед выполнением выхода
                Navigator.of(dialogContext).pop();

                // Получаем текущего пользователя перед выходом
                User? currentUser = FirebaseAuth.instance.currentUser;

                // Отписка от топика, если пользователь был авторизован
                if (currentUser != null) {
                  try {
                    await FirebaseMessaging.instance.unsubscribeFromTopic(currentUser.uid);
                    if (kDebugMode) {
                      print('Успешная отписка от топика');
                    }
                  } catch (error) {
                    if (kDebugMode) {
                      print('Ошибка отписки от топика: $error');
                    }
                  }

                  // Выход из системы
                  if (context.mounted) {
                    await FirebaseUIAuth.signOut(context: context);
                  }

                  ref.read(selectedUser.notifier).state = UserModel(name: '', address: '', phone: '', id: '');
                  ref.read(selectedDate.notifier).state = DateTime.now();
                  ref.read(selectedBarber.notifier).state = BarberModel();
                  ref.read(selectedCity.notifier).state = CityModel(name: '');
                  ref.read(selectedSalon.notifier).state =
                      SalonModel(name: '', address: '');
                  ref.read(selectedServices.notifier).state =
                  List<ServiceModel>.empty(growable: true);
                  ref.read(currentStep.notifier).state = 1;
                  ref.read(selectedTime.notifier).state = '';
                  ref.read(selectedTimeSlot.notifier).state = -1;
                }

                // Перенаправление на главную страницу
                if (context.mounted) {
                  Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
                }
              },
              child: const Text("Да"),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
              child: const Text("Нет"),
            ),
          ],
        );
      },
    );
  }

  Widget _buildButtons(BuildContext context, UserModel userModel) {
    if (!userModel.isStaff && !userModel.isAdmin) {
      // Если пользователь не сотрудник и не администратор, показать обе кнопки
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => Navigator.pushNamed(context, '/booking'),
              child: _buildButtonCard(Icons.book_online, 'Запись'),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () => Navigator.pushNamed(context, '/history'),
              child: _buildButtonCard(Icons.history, 'История'),
            ),
          ),
        ],
      );
    } else {
      // Если сотрудник или администратор, не показывать кнопки
      return Container();
    }
  }

  Widget _buildButtonCard(IconData icon, String label) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 50,
            ),
            Text(
              label,
              style: GoogleFonts.robotoMono(),
            )
          ],
        ),
      ),
    );
  }
}
