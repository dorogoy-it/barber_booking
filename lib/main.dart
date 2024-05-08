import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:page_transition/page_transition.dart';
import 'package:untitled2/fcm/fcm_background_handler.dart';
import 'package:untitled2/fcm/fcm_notification_handler.dart';
import 'package:untitled2/state/state_management.dart';
import 'package:untitled2/ui/add_admin_screen.dart';
import 'package:untitled2/ui/add_barber_screen.dart';
import 'package:untitled2/ui/admin_home_screen.dart';
import 'package:untitled2/ui/barber_booking_history_screen.dart';
import 'package:untitled2/ui/booking_screen.dart';
import 'package:untitled2/ui/delete_booking_screen.dart';
import 'package:untitled2/ui/done_deleting_screen.dart';
import 'package:untitled2/ui/done_services_screens.dart';
import 'package:untitled2/ui/edit_salon_info.dart';
import 'package:untitled2/ui/edit_salon_services.dart';
import 'package:untitled2/ui/home_screen.dart';
import 'package:untitled2/ui/remove_barber_screen.dart';
import 'package:untitled2/ui/reschedule_booking_screen.dart';
import 'package:untitled2/ui/staff_home_screen.dart';
import 'package:untitled2/ui/user_history_screen.dart';
import 'package:untitled2/utils/utils.dart';
import 'package:untitled2/view_model/main/main_view_model_imp.dart';
import 'firebase_options.dart';

FlutterLocalNotificationsPlugin? flutterLocalNotificationsPlugin;
AndroidNotificationChannel? channel;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  //Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  //Setup Firebase
  FirebaseMessaging.onBackgroundMessage(firebaseBackgroundHandler);

  //Flutter Local Notifications
  flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
  channel = const AndroidNotificationChannel(
      'com.example.untitled2', 'Barber Booking App',
      importance: Importance.max);

  await flutterLocalNotificationsPlugin!
      .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(channel!);
  runApp(const ProviderScope(child: MyApp()));

  await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
      alert: true, badge: true, sound: true);
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
                child: StaffHome(),
                type: PageTransitionType.fade);
          case '/doneService':
            return PageTransition(
                settings: settings,
                child: DoneService(),
                type: PageTransitionType.fade);
          case '/home':
            return PageTransition(
                settings: settings,
                child: HomePage(),
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
          case '/bookingHistory':
            return PageTransition(
                settings: settings,
                child: BarberHistoryScreen(),
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

class MyHomePage extends StatefulWidget {
  final scaffoldState = GlobalKey<ScaffoldState>();

  MyHomePage({super.key});

  final mainViewModel = MainViewModelImp();

  @override
  MyHomePageState createState() => MyHomePageState();
}

class MyHomePageState extends State<MyHomePage>{

  @override
  void initState() {
    super.initState();

    //Get token, subscribe... etc here

    //Get token
    FirebaseMessaging.instance.getToken().then((value) => print('Token $value'));

    //Код в комментах работает, если пользователь уже авторизирован
    //так как у приложения не планировалась кнопка выхода
    //      FirebaseMessaging.instance.subscribeToTopic(FirebaseAuth.instance.currentUser!.uid)
    //           .then((value) => print('Успех'));
    if (FirebaseAuth.instance.currentUser != null) {
      FirebaseMessaging.instance.subscribeToTopic(FirebaseAuth.instance.currentUser!.uid)
          .then((value) => print('Успех'));
    } else {
      print('Пользователь не авторизован');
    }

    //Setup message display
    initFirebaseMessagingHandler(channel!);
    
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        key: widget.scaffoldState,
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
                              onPressed: () => widget.mainViewModel.processLogin(
                                  ref, context, widget.scaffoldState),
                              icon: const Icon(
                                Icons.phone,
                                color: Colors.white,
                              ),
                              label: const Text(
                                'Регистрация по номеру телефона',
                                style: TextStyle(color: Colors.white),
                              ),
                              style: ButtonStyle(
                                backgroundColor:
                                MaterialStateProperty.all(Colors.black),
                              ),
                            );
                          }
                        },
                        loading: () => const CircularProgressIndicator(),
                        // Покажет индикатор загрузки в случае ожидания данных
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
        CollectionReference userRef =
        FirebaseFirestore.instance.collection('User');
        DocumentSnapshot snapshotUser =
        await userRef.doc(user.phoneNumber).get();
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
