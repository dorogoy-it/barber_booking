import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:untitled2/model/image_model.dart';

Future<List<ImageModel>> getLookbook() async {
  List<ImageModel> result = List<ImageModel>.empty(growable: true);
  CollectionReference bannerRef = FirebaseFirestore.instance.collection('Lookbook');
  QuerySnapshot snapshot = await bannerRef.get();
  for (var element in snapshot.docs) {
    final data = element.data() as Map<String,dynamic>;
    result.add(ImageModel.fromJson(data));
  }
  return result;
}