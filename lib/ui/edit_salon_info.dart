import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yandex_geocoder/yandex_geocoder.dart';
import '../state/state_management.dart';

class SalonEditScreen extends ConsumerStatefulWidget {
  const SalonEditScreen({super.key});

  @override
  SalonEditScreenState createState() => SalonEditScreenState();
}

class SalonEditScreenState extends ConsumerState<SalonEditScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final YandexGeocoder geocoder = YandexGeocoder(apiKey: 'e0ff82b8-b4b6-46ab-9a34-c596c133d6cb');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Редактирование данных о салоне',
          style: TextStyle(
            color: Colors.white, // Здесь указывается цвет текста
          ),),
        backgroundColor: const Color(0xFF383838),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      resizeToAvoidBottomInset: true,
      backgroundColor: const Color(0xFFFDF9EE),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('AllSalon')
            .doc(ref.read(selectedCity.notifier).state.name)
            .collection('Branch')
            .doc(ref.read(selectedSalon.notifier).state.docId)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          var salonData = snapshot.data;
          _nameController.text = salonData?['name'];
          _addressController.text = salonData?['address'];

          return Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Название салона:',
                  style: TextStyle(fontSize: 18),
                ),
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    hintText: 'Введите название салона',
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Адрес салона:',
                  style: TextStyle(fontSize: 18),
                ),
                TextFormField(
                  controller: _addressController,
                  decoration: const InputDecoration(
                    hintText: 'Введите адрес салона',
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    _updateSalonData(
                        salonData!.reference, _nameController.text, _addressController.text);
                  },
                  child: const Text('Сохранить изменения'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Future<void> _updateSalonData(DocumentReference reference, String name, String address) async {
    try {
      // Получаем текущий город
      String cityName = ref.read(selectedCity.notifier).state.name;

      // Формируем полный адрес для геокодирования
      String fullAddress = "$cityName, $address";

      // Получаем координаты по адресу
      GeocodeResponse geocodeResponse = await geocoder.getGeocode(
        DirectGeocodeRequest(
          addressGeocode: fullAddress,
          ),
        );

      if (geocodeResponse.response?.geoObjectCollection?.featureMember?.isNotEmpty ?? false) {
        var point = geocodeResponse.response!.geoObjectCollection!.featureMember![0].geoObject?.point;
        if (point != null) {
          double? latitude = point.latitude;
          double? longitude = point.longitude;

          // Обновляем данные салона с новыми координатами
          await reference.update({
            'name': name,
            'address': address,
            'latitude': latitude,
            'longitude': longitude,
          });

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Данные о салоне успешно обновлены')),
          );
        } else {
          throw Exception('Не удалось получить координаты');
        }
      } else {
        throw Exception('Адрес не найден');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ошибка при обновлении данных: ${e.toString()}')),
      );
    }
  }
}