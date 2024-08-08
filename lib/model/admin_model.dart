import 'package:cloud_firestore/cloud_firestore.dart';

class AdminModel {
  String name = '';
  String? docId = '';
  String? adminId = '';

  DocumentReference? reference;

  AdminModel({required this.name});

  AdminModel.fromJson(Map<String,dynamic> json) {
    name = json['name'];
    adminId = json['id'];
  }

  Map<String, dynamic> toJson(){
    final Map<String, dynamic> data = <String, dynamic>{};
    data['name'] = name;
    data['id'] = adminId;
    return data;
  }
}