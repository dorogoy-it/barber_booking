import 'package:cloud_firestore/cloud_firestore.dart';

class SalonModel {
  String name = '', address = '';
  String? docId = '';
  DocumentReference? reference;
  double latitude = 0.0;
  double longitude = 0.0;

  SalonModel({
    required this.name,
    required this.address,
    this.latitude = 0.0,
    this.longitude = 0.0
  });

  SalonModel.fromJson(Map<String,dynamic> json) {
    address = json['address'];
    name = json['name'];
    latitude = json['latitude'] ?? 0.0;
    longitude = json['longitude'] ?? 0.0;
  }

  Map<String, dynamic> toJson(){
    final Map<String, dynamic> data = <String, dynamic>{};
    data['address'] = address;
    data['name'] = name;
    data['latitude'] = latitude;
    data['longitude'] = longitude;
    return data;
  }
}