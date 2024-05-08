import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:untitled2/cloud_firestore/lookbook_ref.dart';
import 'package:untitled2/cloud_firestore/user_ref.dart';
import 'package:untitled2/model/image_model.dart';
import 'package:untitled2/model/user_model.dart';
import 'package:untitled2/view_model/home/home_view_model.dart';
import '../../cloud_firestore/banner_ref.dart';
import '../../state/state_management.dart';

class HomeViewModelImp implements HomeViewModel{
  @override
  Future<List<ImageModel>> displayBanner() {
    return getBanners();
  }

  @override
  Future<List<ImageModel>> displayLookbook() {
    return getLookbook();
  }

  @override
  Future<UserModel> displayUserProfile(WidgetRef ref, BuildContext context, String phoneNumber) {
    return getUserProfiles(ref, context, phoneNumber);
  }

  @override
  bool isStaff(WidgetRef ref, BuildContext context) {
    return ref.read(userInformation.notifier).state.isStaff;
  }

  @override
  bool isAdmin(WidgetRef ref, BuildContext context) {
    return ref.read(userInformation.notifier).state.isAdmin;
  }
  
}