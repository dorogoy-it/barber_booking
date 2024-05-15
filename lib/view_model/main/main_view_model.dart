import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

abstract class MainViewModel {
  void processLogin(WidgetRef ref, BuildContext context, GlobalKey<ScaffoldState> scaffoldKey);
}