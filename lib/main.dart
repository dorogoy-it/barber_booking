
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_auth_ui/flutter_auth_ui.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:page_transition/page_transition.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:untitled2/screens/booking_screen.dart';
import 'package:untitled2/screens/done_services_screens.dart';
import 'package:untitled2/screens/home_screen.dart';
import 'package:untitled2/screens/staff_home_screen.dart';
import 'package:untitled2/screens/user_history_screen.dart';
import 'package:untitled2/state/state_management.dart';
import 'package:untitled2/utils/utils.dart';

import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Barber Booking App',
      localizationsDelegates: [GlobalMaterialLocalizations.delegate],
      supportedLocales: [const Locale('en'), const Locale('fr')],
      onGenerateRoute: (settings) {
        switch (settings.name) {
          case '/staffHome':
            return PageTransition(
                settings: settings,
                child: StaffHome(),
                type: PageTransitionType.fade);
            break;
          case '/doneService':
            return PageTransition(
                settings: settings,
                child: DoneService(),
                type: PageTransitionType.fade);
            break;
          case '/home':
            return PageTransition(
                settings: settings,
                child: HomePage(),
                type: PageTransitionType.fade);
            break;
          case '/history':
            return PageTransition(
                settings: settings,
                child: UserHistory(),
                type: PageTransitionType.fade);
            break;
          case '/booking':
            return PageTransition(
                settings: settings,
                child: BookingScreen(),
                type: PageTransitionType.fade);
            break;

          default:
            return null;
        }
      },
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(),
    );
  }
}



class MyHomePage extends ConsumerWidget {
  GlobalKey<ScaffoldState> scaffoldState = new GlobalKey();

  bool isAlertShown = false;

  processLogin(BuildContext context) {
    var user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      FlutterAuthUi.startUi(
              items: [AuthUiProvider.phone],
              tosAndPrivacyPolicy: TosAndPrivacyPolicy(
                  tosUrl: 'https://google.com',
                  privacyPolicyUrl: 'https://google.com'),
              androidOption: AndroidOption(
                  enableSmartLock: false, showLogo: true, overrideTheme: true))
          .then((value) async {
        //refresh state
        context.read(userLogged).state = FirebaseAuth.instance.currentUser;
        // Check if user data exists in the database
        bool userExists = await checkIfUserExists(user);

        // Navigate to the appropriate screen
        if (userExists) {
          Navigator.pushReplacementNamed(context, '/home');
        } else {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            showUpdateDialog(context);
          });
        }
        //start new screen
        //await checkLoginState(context, true, scaffoldState);
      }).catchError((e) {
        ScaffoldMessenger.of(scaffoldState.currentContext!)
            .showSnackBar(SnackBar(content: Text('${e.toString()}')));
      });
    } else {
      Navigator.pushReplacementNamed(context, '/home');
    }
  }

  @override
  Widget build(BuildContext context, watch) {
    return SafeArea(
      child: Scaffold(
        key: scaffoldState,
        body: Container(
          decoration: BoxDecoration(
              image: DecorationImage(
                  image: AssetImage('assets/images/my_bg.png'),
                  fit: BoxFit.cover)),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                width: MediaQuery.of(context).size.width,
                child: FutureBuilder(
                  future: checkLoginState(context, false, scaffoldState),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting)
                      return Center(
                        child: CircularProgressIndicator(),
                      );
                    else {
                      var userState = snapshot.data as LOGIN_STATE?;
                      print(userState);
                      if (userState == LOGIN_STATE.LOGGED) {
                        return Container();
                      } else {
                        return ElevatedButton.icon(
                          onPressed: () => processLogin(context),
                          icon: Icon(
                            Icons.phone,
                            color: Colors.white,
                          ),
                          label: Text(
                            'Регистрация по номеру телефона',
                            style: TextStyle(color: Colors.white),
                          ),
                          style: ButtonStyle(
                              backgroundColor:
                                  MaterialStateProperty.all(Colors.black)),
                        );
                      }
                    }
                  },
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Future<LOGIN_STATE?> checkLoginState(BuildContext context, bool fromLogin,
      GlobalKey<ScaffoldState> scaffoldState) async {
    if (!context.read(forceReload).state) {
      await Future.delayed(Duration(seconds: fromLogin == true ? 0 : 3))
          .then((value) => {
                FirebaseAuth.instance.currentUser!
                    .getIdToken()
                    .then((token) async {
                  //print('$token');
                  context.read(userToken).state = token;
                  CollectionReference userRef =
                      FirebaseFirestore.instance.collection('User');
                  DocumentSnapshot snapshotUser = await userRef
                      .doc(FirebaseAuth.instance.currentUser!.phoneNumber)
                      .get();
                  //Force reload state
                  context.read(forceReload).state = true;
                  if (snapshotUser.exists) {
                    Navigator.pushNamedAndRemoveUntil(
                        context, '/home', (route) => false);
                  } else {
                    // Only show the Alert dialog if it hasn't been shown before
                    if (!isAlertShown) {
                      isAlertShown = true; // Set the flag to true
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        showUpdateDialog(context);
                      });
                    }
                  }
                })
              });
    }
    return FirebaseAuth.instance.currentUser != null
        ? LOGIN_STATE.LOGGED
        : LOGIN_STATE.NOT_LOGIN;
  }

  // Show the update dialog
  void showUpdateDialog(BuildContext context) {
    var nameController = TextEditingController();
    var addressController = TextEditingController();
    Alert(
      context: context,
      title: 'Обновить данные',
      content: Column(
        children: [
          TextField(
            decoration: InputDecoration(
              icon: Icon(Icons.account_circle),
              labelText: 'Имя',
            ),
            controller: nameController,
          ),
          TextField(
            decoration: InputDecoration(
              icon: Icon(Icons.home),
              labelText: 'Адрес',
            ),
            controller: addressController,
          ),
        ],
      ),
      buttons: [
        DialogButton(
          child: Text('Отмена'),
          onPressed: () => {
            Navigator.pushNamedAndRemoveUntil(
                context, '/home', (route) => false)
          }
        ),
        DialogButton(
          child: Text('Обновить'),
          onPressed: () {
            // Update to server
            createUserProfile(
              context,
              FirebaseAuth.instance.currentUser!.phoneNumber!,
              nameController.text,
              addressController.text,
            );
          },
        ),
      ],
    ).show();
  }

  Future<void> createUserProfile(BuildContext context, String phoneNumber, String name, String address) async {
    try {
      CollectionReference userRef = FirebaseFirestore.instance.collection('User');
      await userRef.doc(phoneNumber).set({
        'name': name,
        'address': address,
      });
      Navigator.pop(context);
      ScaffoldMessenger.of(scaffoldState.currentContext!).showSnackBar(
        SnackBar(
          content: Text('Данные успешно обновлены!'),
        ),
      );
      await Future.delayed(Duration(seconds: 1), () {
        Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
      });
    } catch (e) {
      Navigator.pop(context);
      ScaffoldMessenger.of(scaffoldState.currentContext!).showSnackBar(
        SnackBar(content: Text('$e')),
      );
    }
  }

  Future<bool> checkIfUserExists(User? user) async {
    if (user != null) {
      CollectionReference userRef = FirebaseFirestore.instance.collection('User');
      DocumentSnapshot snapshotUser =
      await userRef.doc(user.phoneNumber!).get();
      return snapshotUser.exists;
    }
    return false;
  }
}
