import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../state/state_management.dart';

class SalonEditScreen extends ConsumerStatefulWidget {
  const SalonEditScreen({super.key});

  @override
  SalonEditScreenState createState() => SalonEditScreenState();
}

class SalonEditScreenState extends ConsumerState<SalonEditScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Редактирование данных о салоне'),
      ),
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

  void _updateSalonData(DocumentReference reference, String name, String address) async {
    await reference.update({
      'name': name,
      'address': address,
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Данные о салоне успешно обновлены'),
      ),
    );
  }
}