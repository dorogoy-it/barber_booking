import 'package:cloud_firestore/cloud_firestore.dart';
import '../model/barber_model.dart';
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
    var salon = SalonModel.fromJson(element.data());
    salon.docId = element.id;
    salon.reference = element.reference;
    salons.add(salon);
  });
  return salons;
}

Future<List<BarberModel>> getBarbersBySalon(SalonModel salon) async{
  var barbers = new List<BarberModel>.empty(growable: true);
  var barberRef = salon.reference!.collection('Barber');
  var snapshot = await barberRef.get();
  snapshot.docs.forEach((element) {
    var barber = BarberModel.fromJson(element.data());
    barber.docId = element.id;
    barber.reference = element.reference;
    barbers.add(barber);
  });
  return barbers;
}

Future<List<int>> getTimeSlotOfBarber(BarberModel barberModel, String date) async{
  List<int> result = new List<int>.empty(growable: true);
  var bookingRef = barberModel.reference!.collection(date);
  QuerySnapshot snapshot = await bookingRef.get();
  snapshot.docs.forEach((element) {
    result.add(int.parse(element.id));
  });
  return result;
}