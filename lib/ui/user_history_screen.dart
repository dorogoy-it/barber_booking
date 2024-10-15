import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:untitled2/state/state_management.dart';
import 'package:untitled2/utils/utils.dart';
import 'package:untitled2/view_model/user_history/user_history_view_model_imp.dart';
import '../model/booking_model.dart';
import '../model/review_model.dart';

class UserHistory extends ConsumerWidget {
  final scaffoldKey = GlobalKey<ScaffoldState>();
  final userHistoryViewModel = UserHistoryViewModelImp();

  UserHistory({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    const int daysAfterBooking = 3;
    var watchRefresh = ref.watch(deleteFlagRefresh);
    return SafeArea(
        child: Scaffold(
      key: scaffoldKey,
      appBar: AppBar(
        title: const Text(
          'История записи',
          style: TextStyle(
            color: Colors.white, // Здесь указывается цвет текста
          ),
        ),
        backgroundColor: const Color(0xFF383838),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      resizeToAvoidBottomInset: true,
      backgroundColor: const Color(0xFFFDF9EE),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: FutureBuilder(
            future: userHistoryViewModel.displayUserHistory(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              } else if (snapshot.hasError) {
                return Center(
                  child: Text('Error: ${snapshot.error}'),
                );
              } else if (snapshot.data == null) {
                return const Center(
                  child: Text('Data is null'),
                );
              } else {
                var userBookings = snapshot.data as List<BookingModel>;
                if (userBookings.isEmpty) {
                  return const Center(
                    child: Text('Не удалось загрузить историю записи'),
                  );
                } else {
                  return FutureBuilder(
                      future: syncTime(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        } else {
                          var syncTime = snapshot.data as DateTime;
                          return ListView.builder(
                              itemCount: userBookings.length,
                              itemBuilder: (context, index) {
                                var isExpired =
                                    DateTime.fromMillisecondsSinceEpoch(
                                            userBookings[index].timeStamp)
                                        .isBefore(syncTime);
                                return Card(
                                    elevation: 8,
                                    shape: const RoundedRectangleBorder(
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(22))),
                                    child: Column(children: [
                                      Padding(
                                        padding: const EdgeInsets.all(12),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Column(
                                                  children: [
                                                    Text(
                                                      'Дата',
                                                      style: GoogleFonts
                                                          .robotoMono(),
                                                    ),
                                                    Text(
                                                      DateFormat("dd/MM/yy")
                                                          .format(DateTime
                                                              .fromMillisecondsSinceEpoch(
                                                                  userBookings[
                                                                          index]
                                                                      .timeStamp)),
                                                      style: GoogleFonts
                                                          .robotoMono(
                                                              fontSize: 22,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold),
                                                    ),
                                                  ],
                                                ),
                                                Column(
                                                  children: [
                                                    Text(
                                                      'Время',
                                                      style: GoogleFonts
                                                          .robotoMono(),
                                                    ),
                                                    Text(
                                                      timeSlot.elementAt(
                                                          userBookings[index]
                                                              .slot),
                                                      style: GoogleFonts
                                                          .robotoMono(
                                                              fontSize: 22,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold),
                                                    ),
                                                  ],
                                                )
                                              ],
                                            ),
                                            const Divider(
                                              thickness: 1,
                                            ),
                                            Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.spaceAround,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: [
                                                    Text(
                                                      userBookings[index]
                                                          .salonName,
                                                      style: GoogleFonts
                                                          .robotoMono(
                                                              fontSize: 20,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold),
                                                    ),
                                                    Text(
                                                      userBookings[index]
                                                          .barberName,
                                                      style: GoogleFonts
                                                          .robotoMono(),
                                                    ),
                                                  ],
                                                ),
                                                Text(
                                                  userBookings[index]
                                                      .salonAddress,
                                                  style:
                                                      GoogleFonts.robotoMono(),
                                                ),
                                              ],
                                            ),
                                            const Divider(
                                              thickness: 1,
                                            ),
                                            Text(
                                              'Услуги:',
                                              style: GoogleFonts.robotoMono(
                                                  fontSize: 20,
                                                  fontWeight: FontWeight.bold),
                                            ),

                                            // Показываем услуги и цены
                                            for (var service
                                                in userBookings[index].services)
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  Text(
                                                    service.name,
                                                    style: GoogleFonts
                                                        .robotoMono(),
                                                  ),
                                                  Text(
                                                    '${service.price} руб.',
                                                    style: GoogleFonts
                                                        .robotoMono(),
                                                  ),
                                                ],
                                              ),
                                            const Divider(
                                              thickness: 1,
                                            ),
                                            // Выводим окончательную цену
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Text(
                                                  'Окончательная цена:',
                                                  style: GoogleFonts.robotoMono(
                                                      fontSize: 16,
                                                      fontWeight:
                                                          FontWeight.bold),
                                                ),
                                                Text(
                                                  '${userBookings[index].totalPrice} руб.',
                                                  style:
                                                      GoogleFonts.robotoMono(),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                      Column(
                                        children: [
                                          GestureDetector(
                                            onTap: (userBookings[index].done ||
                                                    isExpired)
                                                ? null
                                                : () {
                                                    Alert(
                                                      context: context,
                                                      type: AlertType.warning,
                                                      title: 'Удалить запись',
                                                      desc:
                                                          'Пожалуйста, удалите ещё и запись из календаря',
                                                      buttons: [
                                                        DialogButton(
                                                          onPressed: () =>
                                                              Navigator.of(
                                                                      context)
                                                                  .pop(),
                                                          color: Colors.white,
                                                          child: Text(
                                                            'Отмена',
                                                            style: GoogleFonts
                                                                .robotoMono(
                                                                    color: Colors
                                                                        .black),
                                                          ),
                                                        ),
                                                        DialogButton(
                                                          onPressed: () {
                                                            Navigator.of(
                                                                    context)
                                                                .pop();
                                                            userHistoryViewModel
                                                                .userCancelBooking(
                                                                    ref,
                                                                    context,
                                                                    userBookings[
                                                                        index]);
                                                          },
                                                          color: Colors.white,
                                                          child: Text(
                                                            'Удалить',
                                                            style: GoogleFonts
                                                                .robotoMono(
                                                                    color: Colors
                                                                        .red),
                                                          ),
                                                        ),
                                                      ],
                                                    ).show();
                                                  },
                                            child: Container(
                                              decoration: const BoxDecoration(
                                                color: Colors.blue,
                                              ),
                                              width: double.infinity,
                                              height: 60,
                                              child: Center(
                                                child: Text(
                                                  userBookings[index].done
                                                      ? 'Завершена'
                                                      : isExpired
                                                          ? 'Просрочена'
                                                          : 'Отмена',
                                                  style: GoogleFonts.robotoMono(
                                                    color: isExpired
                                                        ? Colors.grey
                                                        : Colors.white,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                          GestureDetector(
                                            onTap: !userBookings[index].done ||
                                                    DateTime.fromMillisecondsSinceEpoch(
                                                            userBookings[index]
                                                                .timeStamp)
                                                        .add(const Duration(
                                                            days:
                                                                daysAfterBooking))
                                                        .isBefore(syncTime)
                                                ? null
                                                : () {
                                                    if (userBookings[index]
                                                        .done) {
                                                      showReviewDialog(context,
                                                          userBookings[index]);
                                                    }
                                                  },
                                            child: Container(
                                              decoration: const BoxDecoration(
                                                color: Colors.green,
                                                borderRadius: BorderRadius.only(
                                                  bottomRight:
                                                      Radius.circular(22),
                                                  bottomLeft:
                                                      Radius.circular(22),
                                                ),
                                              ),
                                              width: double.infinity,
                                              height: 60,
                                              child: Center(
                                                child: Text(
                                                  'Оставить отзыв',
                                                  style: GoogleFonts.robotoMono(
                                                    color: !userBookings[index]
                                                                .done ||
                                                            DateTime.fromMillisecondsSinceEpoch(
                                                                    userBookings[
                                                                            index]
                                                                        .timeStamp)
                                                                .add(const Duration(
                                                                    days:
                                                                        daysAfterBooking))
                                                                .isBefore(
                                                                    syncTime)
                                                        ? Colors.grey
                                                        : Colors.white,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ]));
                              });
                        }
                      });
                }
              }
            }),
      ),
    ));
  }
}

void showReviewDialog(BuildContext context, BookingModel booking) async {
  final commentController = TextEditingController();
  var rating = 0.0;

  // Получаем существующие отзывы пользователя на эту запись
  final reviewsRef = FirebaseFirestore.instance.collection('Reviews');
  final existingReviews = await reviewsRef
      .where('userId', isEqualTo: booking.customerId)
      .where('bookingId', isEqualTo: booking.docId)
      .get();

  // Если уже есть отзыв, показываем сообщение об ошибке
  if (existingReviews.size > 0) {
    if (context.mounted) {
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('Ошибка'),
            content: const Text('Вы уже оставляли отзыв на эту запись'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('OK'),
              ),
            ],
          );
        },
      );
    }
    return;
  }


  // Проверяем, прошло ли время записи
  final bookingTimeStamp =
      DateTime.fromMillisecondsSinceEpoch(booking.timeStamp);
  final currentTime = DateTime.now();
  if (bookingTimeStamp.isAfter(currentTime)) {
    if (context.mounted) {
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('Ошибка'),
            content: Text(
                'Вы можете оставить отзыв только после окончания записи, которая была запланирована на ${DateFormat('dd/MM/yyyy HH:mm').format(bookingTimeStamp)}'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('OK'),
              ),
            ],
          );
        },
      );
    }
    return;
  }

  if (context.mounted) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Оставить отзыв'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Оценка:'),
              RatingBar.builder(
                initialRating: rating,
                minRating: 1,
                direction: Axis.horizontal,
                allowHalfRating: true,
                itemCount: 5,
                itemPadding: const EdgeInsets.symmetric(horizontal: 4.0),
                itemBuilder: (context, _) => const Icon(
                  Icons.star,
                  color: Colors.amber,
                ),
                onRatingUpdate: (newRating) {
                  // Обновляем значение rating
                  rating = newRating;
                },
              ),
              const Text('Комментарий:'),
              TextField(
                controller: commentController,
                maxLines: 3,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Отмена'),
            ),
            TextButton(
              onPressed: () {
                final review = ReviewModel(
                  userId: booking.customerId,
                  barberId: booking.barberId,
                  rating: rating,  // Используем обновленное значение rating
                  comment: commentController.text,
                  timestamp: DateTime.now(),
                  bookingId: booking.docId!,
                );
                submitReview(booking, review);
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                  content: Text('Спасибо за отзыв!'),
                ));
                Navigator.of(context).pop();
              },
              child: const Text('Отправить'),
            ),
          ],
        );
      },
    );
  }
}

Future<void> submitReview(BookingModel booking, ReviewModel review) async {
  final reviewsRef = FirebaseFirestore.instance.collection('Reviews');
  final reviewId = reviewsRef.doc().id;

  // Получаем существующие отзывы пользователя на эту запись
  final existingReviews = await reviewsRef
      .where('userId', isEqualTo: review.userId)
      .where('bookingId', isEqualTo: booking.docId)
      .get();

  if (existingReviews.size > 0) {
    // Если уже есть отзыв, показываем сообщение об ошибке
    if (kDebugMode) {
      print('Вы уже оставляли отзыв на эту запись');
    }
    return;
  }

  // Если нет существующего отзыва, добавляем новый
  await reviewsRef.doc(reviewId).set(review.toJson());

  await updateBarberRating(booking, review.barberId);
}

Future<void> updateBarberRating(BookingModel booking, String barberId) async {
  final barberRef = FirebaseFirestore.instance
      .collection('AllSalon')
      .doc(booking.cityBook)
      .collection('Branch')
      .doc(booking.salonId)
      .collection('Barber')
      .doc(barberId);

  final reviewsSnapshot = await FirebaseFirestore.instance
      .collection('Reviews')
      .where('barberId', isEqualTo: barberId)
      .get();

  final reviews = reviewsSnapshot.docs.map((doc) => doc.data()).toList();
  final totalRating =
      reviews.fold<double>(0, (sum, r) => sum + r['rating']);
  final ratingTimes = reviews.length;
  final updatedRating = totalRating / ratingTimes;

  await barberRef.update({
    'rating': updatedRating,
    'ratingTimes': ratingTimes,
  });
}
