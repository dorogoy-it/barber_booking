import 'package:cloud_firestore/cloud_firestore.dart';

class AdminModel {
  String name = '';
  String? docId = '';

  DocumentReference? reference;

  AdminModel({required this.name});

  AdminModel.fromJson(Map<String,dynamic> json) {
    name = json['name'];
  }

  Map<String, dynamic> toJson(){
    final Map<String, dynamic> data = <String, dynamic>{};
    data['name'] = name;
    return data;
  }
}