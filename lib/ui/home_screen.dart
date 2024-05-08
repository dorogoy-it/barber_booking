import 'package:carousel_slider/carousel_slider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:untitled2/model/image_model.dart';
import 'package:untitled2/state/state_management.dart';
import 'package:untitled2/view_model/home/home_view_model_imp.dart';
import '../cloud_firestore/user_ref.dart';
import '../main.dart';
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
                        //user profile
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
                                        onPressed: () => signOut(context),
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
                        //Menu
                        Padding(
                          padding: const EdgeInsets.all(4),
                          child: _buildButtons(
                              context, ref
                              .read(userInformation.notifier)
                              .state),
                        ),
                        //Banner
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
                        //Lookbook
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

  Future<void> signOut(BuildContext context) async {
    await FirebaseAuth.instance.signOut().then((value) =>
        Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => MyHomePage())));
  }

  Widget _buildButtons(BuildContext context, UserModel userModel) {
    if (!userModel.isStaff && !userModel.isAdmin) {
      // Если не сотрудник и не администратор, показать обе кнопки
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
