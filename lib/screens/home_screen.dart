import 'package:carousel_slider/carousel_slider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:untitled2/model/image_model.dart';
import 'package:untitled2/state/state_management.dart';
import '../cloud_firestore/banner_ref.dart';
import '../cloud_firestore/lookbook_ref.dart';
import '../cloud_firestore/user_ref.dart';
import '../model/user_model.dart';

class HomePage extends ConsumerWidget {
  @override
  Widget build(BuildContext context, watch) {
    return SafeArea(
        child: Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: Color(0xFFDFDFDF),
      body: SingleChildScrollView(
        child: Column(children: [
          //user profile
          FutureBuilder(
              future: getUserProfiles(context,
                  FirebaseAuth.instance.currentUser!.phoneNumber!),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting)
                  return Center(
                    child: CircularProgressIndicator(),
                  );
                else {
                  var userModel = snapshot.data as UserModel;
                  return Container(
                    decoration: BoxDecoration(color: Color(0xFF383838)),
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        CircleAvatar(
                          child: Icon(
                            Icons.person,
                            color: Colors.white,
                            size: 30,
                          ),
                          maxRadius: 30,
                          backgroundColor: Colors.black,
                        ),
                        SizedBox(
                          width: 30,
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${userModel.name}',
                                style: GoogleFonts.robotoMono(
                                    fontSize: 22,
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold),
                              ),
                              Text(
                                '${userModel.address}',
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.robotoMono(
                                  fontSize: 18,
                                  color: Colors.white,
                                ),
                              )
                            ],
                          ),
                        ),
                        context.read(userInformation).state.isStaff ?
                            IconButton(icon: Icon(Icons.admin_panel_settings,
                              color: Colors.white,),
                              onPressed: () =>
                                  Navigator.of(context).pushNamed(
                                      '/staffHome'),) : Container()
                      ],
                    ),
                  );
                }
              }),
          //Menu
          Padding(
            padding: const EdgeInsets.all(4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => Navigator.pushNamed(context, '/booking'),
                    child: Container(
                      child: Card(
                        child: Padding(
                          padding: const EdgeInsets.all(8),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.book_online,
                                size: 50,
                              ),
                              Text(
                                'Запись',
                                style: GoogleFonts.robotoMono(),
                              )
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: GestureDetector(onTap: () => Navigator.pushNamed(context, '/history'),
                  child: Container(
                    child: Card(
                      child: Padding(
                        padding: const EdgeInsets.all(8),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.history,
                              size: 50,
                            ),
                            Text(
                              'История',
                              style: GoogleFonts.robotoMono(),
                            )
                          ],
                        ),
                      ),
                    ),
                  ),),
                )
              ],
            ),
          ),
          //Banner
          FutureBuilder(
              future: getBanners(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting)
                  return Center(
                    child: CircularProgressIndicator(),
                  );
                else {
                  var banners = snapshot.data as List<ImageModel>;
                  return CarouselSlider(
                      options: CarouselOptions(
                          enlargeCenterPage: true,
                          aspectRatio: 3.0,
                          autoPlay: true,
                          autoPlayInterval: Duration(seconds: 3)),
                      items: banners
                          .map((e) => Container(
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.network(e.image),
                                ),
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
                  style: GoogleFonts.robotoMono(fontSize: 24),
                )
              ],
            ),
          ),
          FutureBuilder(
              future: getLookbook(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting)
                  return Center(
                    child: CircularProgressIndicator(),
                  );
                else if (!snapshot.hasData || snapshot.data == null)
                  return SizedBox.shrink();
                else {
                  var lookbook = snapshot.data as List<ImageModel>;
                  return Column(
                    children: lookbook
                        .map((e) => Container(
                              padding: const EdgeInsets.all(8),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.network(e.image),
                              ),
                            ))
                        .toList(),
                  );
                }
              }),
        ]),
      ),
    ));
  }
}
