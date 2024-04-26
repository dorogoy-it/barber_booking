import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_auth_ui/flutter_auth_ui.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:page_transition/page_transition.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:untitled2/screens/add_admin_screen.dart';
import 'package:untitled2/screens/add_barber_screen.dart';
import 'package:untitled2/screens/admin_home_screen.dart';
import 'package:untitled2/screens/booking_screen.dart';
import 'package:untitled2/screens/delete_booking_screen.dart';
import 'package:untitled2/screens/done_deleting_screen.dart';
import 'package:untitled2/screens/done_services_screens.dart';
import 'package:untitled2/screens/edit_salon_info.dart';
import 'package:untitled2/screens/edit_salon_services.dart';
import 'package:untitled2/screens/home_screen.dart';
import 'package:untitled2/screens/remove_barber_screen.dart';
import 'package:untitled2/screens/reschedule_booking_screen.dart';
import 'package:untitled2/screens/staff_home_screen.dart';
import 'package:untitled2/screens/user_history_screen.dart';
import 'package:untitled2/state/state_management.dart';
import 'package:untitled2/utils/utils.dart';
import 'firebase_options.dart';
import 'model/user_model.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Barber Booking App',
      localizationsDelegates: const [GlobalMaterialLocalizations.delegate],
      restorationScopeId: "Test",
      onGenerateRoute: (settings) {
        switch (settings.name) {
          case '/removeBarber':
            return PageTransition(
                settings: settings,
                child: const RemoveBarberScreen(),
                type: PageTransitionType.fade);
          case '/editSalonServices':
            return PageTransition(
                settings: settings,
                child: const EditServiceScreen(),
                type: PageTransitionType.fade);
          case '/editSalonInfo':
            return PageTransition(
                settings: settings,
                child: const SalonEditScreen(),
                type: PageTransitionType.fade);
          case '/addAdmin':
            return PageTransition(
                settings: settings,
                child: const AddAdminScreen(),
                type: PageTransitionType.fade);
          case '/addBarber':
            return PageTransition(
                settings: settings,
                child: const AddEmployeeScreen(),
                type: PageTransitionType.fade);
          case '/rescheduleBooking':
            return PageTransition(
                settings: settings,
                child: RescheduleBooking(),
                type: PageTransitionType.fade);
          case '/doneDeleting':
            return PageTransition(
                settings: settings,
                child: DoneDeleting(),
                type: PageTransitionType.fade);
          case '/deleteBooking':
            return PageTransition(
                settings: settings,
                child: DeleteBooking(),
                type: PageTransitionType.fade);
          case '/adminHome':
            return PageTransition(
                settings: settings,
                child: const AdminHome(),
                type: PageTransitionType.fade);
          case '/staffHome':
            return PageTransition(
                settings: settings,
                child: const StaffHome(),
                type: PageTransitionType.fade);
          case '/doneService':
            return PageTransition(
                settings: settings,
                child: DoneService(),
                type: PageTransitionType.fade);
          case '/home':
            return PageTransition(
                settings: settings,
                child: const HomePage(),
                type: PageTransitionType.fade);
          case '/history':
            return PageTransition(
                settings: settings,
                child: UserHistory(),
                type: PageTransitionType.fade);
          case '/booking':
            return PageTransition(
                settings: settings,
                child: BookingScreen(),
                type: PageTransitionType.fade);

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
  final GlobalKey<ScaffoldState> scaffoldState = GlobalKey();

  MyHomePage({super.key});

  processLogin(WidgetRef ref, BuildContext context) async {
    var user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      try {
        await FlutterAuthUi.startUi(
            items: [AuthUiProvider.phone],
            tosAndPrivacyPolicy: const TosAndPrivacyPolicy(
                tosUrl: 'https://google.com',
                privacyPolicyUrl: 'https://google.com'),
            androidOption: const AndroidOption(
                enableSmartLock: false, showLogo: true, overrideTheme: true));

        // refresh state
        ref.read(userLogged.notifier).state = FirebaseAuth.instance.currentUser;

        // check if the user exists in the 'User' collection
        CollectionReference userRef = FirebaseFirestore.instance.collection('User');
        DocumentSnapshot snapshotUser = await userRef.doc(FirebaseAuth.instance.currentUser!.phoneNumber).get();

        if (snapshotUser.exists) {
          // user exists, navigate to home
          UserModel userModel = UserModel.fromJson(snapshotUser.data() as Map<String, dynamic>);

          // Сохраните userModel в провайдере userInformation
          ref.read(userInformation.notifier).state = userModel;

          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => const HomePage()),
                (Route<dynamic> route) => false,
          );
        } else {
          // user does not exist, show Alert Dialog for user input
          var nameController = TextEditingController();
          var addressController = TextEditingController();

          Alert(
            context: context,
            title: 'Введите данные',
            content: Column(
              children: [
                TextField(
                  decoration: const InputDecoration(
                      icon: Icon(Icons.account_circle),
                      labelText: 'Имя'
                  ),
                  controller: nameController,
                ),
                TextField(
                  decoration: const InputDecoration(
                      icon: Icon(Icons.home),
                      labelText: 'Адрес'
                  ),
                  controller: addressController,
                )
              ],
            ),
            buttons: [
              DialogButton(
                child: const Text('Отмена'),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
              DialogButton(
                child: const Text('Сохранить'),
                onPressed: () {
                  // check if the input fields contain non-space characters
                  if (nameController.text.trim().isNotEmpty && addressController.text.trim().isNotEmpty) {
                    // save user data to 'User' collection
                    userRef.doc(FirebaseAuth.instance.currentUser!.phoneNumber).set({
                      'name': nameController.text.trim(),
                      'address': addressController.text.trim(),
                      'phone': FirebaseAuth.instance.currentUser!.phoneNumber,
                      'id': FirebaseAuth.instance.currentUser!.uid,
                    }).then((_) {
                      Navigator.pop(context); // close the Alert Dialog
                      ScaffoldMessenger.of(scaffoldState.currentContext!)
                          .showSnackBar(const SnackBar(
                        content: Text('Данные успешно сохранены!'),
                      ));
                      // navigate to home
                      Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(builder: (context) => const HomePage()),
                            (Route<dynamic> route) => false,
                      );
                    }).catchError((e) {
                      // handle error
                      ScaffoldMessenger.of(scaffoldState.currentContext!)
                          .showSnackBar(SnackBar(content: Text('$e')));
                    });
                  } else {
                    // show error message for fields containing only spaces
                    ScaffoldMessenger.of(scaffoldState.currentContext!)
                        .showSnackBar(const SnackBar(
                      content: Text('Пожалуйста, введите корректные данные!'),
                    ));
                  }
                },
              ),
            ],
          ).show();
        }
      } catch (e) {
        ScaffoldMessenger.of(scaffoldState.currentContext!)
            .showSnackBar(SnackBar(content: Text('$e')));
      }
    } else {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const HomePage()),
            (Route<dynamic> route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SafeArea(
      child: Scaffold(
        key: scaffoldState,
        body: Container(
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/images/my_bg.png'),
              fit: BoxFit.cover,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                width: MediaQuery.of(context).size.width,
                child: Consumer(
                  builder: (context, ref, child) {
                    var userState = ref.watch(checkLoginStateProvider);

                    //print("User State: ${userState.data?.value}");

                    if (userState.value == LOGIN_STATE.LOGGED) {
                      // Пользователь зарегистрирован, перейти на главную страницу
                      Future.microtask(() {
                        Navigator.pushNamedAndRemoveUntil(
                            context, '/home', (route) => false);
                      });
                      return Container();
                    } else {
                      return userState.when(
                        data: (loginState) {
                          if (loginState == LOGIN_STATE.LOGGED) {
                            return const CircularProgressIndicator(); // Покажет индикатор загрузки
                          } else {
                            return ElevatedButton.icon(
                              onPressed: () => processLogin(ref, context),
                              icon: const Icon(
                                Icons.phone,
                                color: Colors.white,
                              ),
                              label: const Text(
                                'Регистрация по номеру телефона',
                                style: TextStyle(color: Colors.white),
                              ),
                              style: ButtonStyle(
                                backgroundColor: MaterialStateProperty.all(Colors.black),
                              ),
                            );
                          }
                        },
                        loading: () => const CircularProgressIndicator(), // Покажет индикатор загрузки в случае ожидания данных
                        error: (error, stackTrace) {
                          //print("Ошибка: $error");
                          return const Text('Что-то пошло не так');
                        },
                      );
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  final checkLoginStateProvider = FutureProvider<LOGIN_STATE>((ref) async {
    try {
      var user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        var token = await user.getIdToken();
        ref.read(userToken.notifier).state = token!;
        CollectionReference userRef = FirebaseFirestore.instance.collection('User');
        DocumentSnapshot snapshotUser = await userRef.doc(user.phoneNumber).get();
        // Force reload state
        ref.read(forceReload.notifier).state = true;
        return snapshotUser.exists ? LOGIN_STATE.LOGGED : LOGIN_STATE.NOT_LOGIN;
      } else {
        return LOGIN_STATE.NOT_LOGIN;
      }
    } catch (e) {
      //print(e);
      return LOGIN_STATE.NOT_LOGIN;
    }
  });
}
