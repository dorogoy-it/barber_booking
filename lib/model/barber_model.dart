import 'package:cloud_firestore/cloud_firestore.dart';

class BarberModel{
  String name= '';
  String? docId = '';
  double rating=0;
  int ratingTimes=0;

  DocumentReference? reference;

  BarberModel();

  BarberModel.fromJson(Map<String,dynamic> json) {
    name = json['name'];
    rating = double.parse(json['rating'] == null ? '0' : json['rating'].toString());
    ratingTimes = int.parse(json['ratingTimes'] == null ? '0' : json['ratingTimes'].toString());
  }

  Map<String, dynamic> toJson(){
    final Map<String, dynamic> data = <String, dynamic>{};
    data['name'] = name;
    data['rating'] = rating;
    data['ratingTimes'] = ratingTimes;
    return data;
  }
}