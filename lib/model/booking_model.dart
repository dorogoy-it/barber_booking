import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:untitled2/model/service_model.dart';

class BookingModel {
  String? docId = '';
  String barberId = '',
      barberName = '',
      cityBook = '',
      customerId = '',
      customerName = '',
      customerPhone = '',
      salonAddress = '',
      salonId = '',
      salonName = '',
      time = '';

  double totalPrice=0;
  bool done = false;
  int slot = 0, timeStamp = 0;
  List<ServiceModel> services = [];

  DocumentReference? reference;

  BookingModel(
      {this.docId,
      required this.barberId,
      required this.barberName,
      required this.cityBook,
      required this.customerId,
      required this.customerName,
      required this.customerPhone,
      required this.salonAddress,
      required this.salonId,
      required this.salonName,
      required this.services,
      required this.time,
      required this.done,
      required this.slot,
      required this.totalPrice,
      required this.timeStamp});

  BookingModel.fromJson(Map<String, dynamic> json) {
    barberId = json['barberId'];
    barberName = json['barberName'];
    cityBook = json['cityBook'];
    customerId = json['customerId'];
    customerName = json['customerName'];
    customerPhone = json['customerPhone'];
    salonAddress = json['salonAddress'];
    salonName = json['salonName'];
    salonId = json['salonId'];
    // Ensure that 'services' is a List<Map<String, dynamic>> and not null
    List<dynamic>? servicesJson = json['services'];
    services = servicesJson?.map((serviceJson) => ServiceModel.fromJson(serviceJson)).toList() ?? [];
    time = json['time'];
    done = json['done'] as bool;
    slot = int.parse(json['slot'] == null ? '-1' : json['slot'].toString());
    totalPrice = double.parse(
        json['totalPrice'] == null ? '0' : json['totalPrice'].toString());
    timeStamp = int.parse(
        json['timeStamp'] == null ? '0' : json['timeStamp'].toString());
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['barberId'] = this.barberId;
    data['barberName'] = this.barberName;
    data['cityBook'] = this.cityBook;
    data['customerId'] = this.customerId;
    data['customerName'] = this.customerName;
    data['customerPhone'] = this.customerPhone;
    data['salonAddress'] = this.salonAddress;
    data['salonName'] = this.salonName;
    data['salonId'] = this.salonId;
    data['services'] = this.services.map((service) => service.toJson()).toList();
    data['time'] = this.time;
    data['done'] = this.done;
    data['slot'] = this.slot;
    data['totalPrice'] = this.totalPrice;
    data['timeStamp'] = this.timeStamp;
    return data;
  }
}
