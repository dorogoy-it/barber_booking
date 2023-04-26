import 'package:cloud_firestore/cloud_firestore.dart';
import '../model/city_model.dart';
import '../model/salon_model.dart';

Future<List<CityModel>> getCities() async{
  var cities = new List<CityModel>.empty(growable: true);
  var cityRef = FirebaseFirestore.instance.collection('AllSalon');
  var snapshot = await cityRef.get();
  snapshot.docs.forEach((element) {
    cities.add(CityModel.fromJson(element.data()));
  });
  return cities;
}

Future<List<SalonModel>> getSalonByCity(String cityName) async{
  var salons = new List<SalonModel>.empty(growable: true);
  var salonRef = FirebaseFirestore.instance.collection('AllSalon').doc(cityName.replaceAll(' ', '')).collection('Branch');
  var snapshot = await salonRef.get();
  snapshot.docs.forEach((element) {
    salons.add(SalonModel.fromJson(element.data()));
  });
  return salons;
}