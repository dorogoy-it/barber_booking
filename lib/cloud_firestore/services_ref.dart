
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:untitled2/model/service_model.dart';
import 'package:untitled2/state/state_management.dart';

Future<List<ServiceModel>> getServices(BuildContext context) async{
  var services = List<ServiceModel>.empty(growable: true);
  CollectionReference serviceRef = FirebaseFirestore.instance.collection('Services');
  QuerySnapshot snapshot = await serviceRef.where(
    context.read(selectedSalon).state.docId!, isEqualTo: true
  ).get();
  snapshot.docs.forEach((element) {
    final data = element.data() as Map<String, dynamic>;
    var serviceModel = ServiceModel.fromJson(data);
    serviceModel.docId = element.id;
    services.add(serviceModel);
  });
  return services;
}