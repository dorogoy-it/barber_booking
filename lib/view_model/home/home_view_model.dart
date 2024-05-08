import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../model/image_model.dart';
import '../../model/user_model.dart';

abstract class HomeViewModel {
  Future<UserModel> displayUserProfile(WidgetRef ref, BuildContext context, String phoneNumber);
  Future<List<ImageModel>> displayBanner();
  Future<List<ImageModel>> displayLookbook();

  bool isStaff(WidgetRef ref, BuildContext context);
  bool isAdmin(WidgetRef ref, BuildContext context);
}