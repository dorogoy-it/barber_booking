import 'package:flutter_riverpod/flutter_riverpod.dart';

final barberHistorySelectedDate = StateProvider<DateTime>((ref) => DateTime.now());