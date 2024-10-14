import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../state/state_management.dart';

class RemoveBarberScreen extends ConsumerWidget {
  const RemoveBarberScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Управление сотрудниками',
          style: TextStyle(
            color: Colors.white, // Здесь указывается цвет текста
          ),
        ),
        backgroundColor: const Color(0xFF383838),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      resizeToAvoidBottomInset: true,
      backgroundColor: const Color(0xFFFDF9EE),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('AllSalon')
            .doc(ref.read(selectedCity.notifier).state.name)
            .collection('Branch')
            .doc(ref.read(selectedSalon.notifier).state.docId)
            .collection('Barber')
            .snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (!snapshot.hasData) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          return ListView.builder(
            itemCount: snapshot.data?.docs.length,
            itemBuilder: (context, index) {
              DocumentSnapshot document =
                  snapshot.data?.docs[index] as DocumentSnapshot<Object?>;
              return GestureDetector(
                  onTap: () {},
                  child: Card(
                      child: ListTile(
                    leading: const Icon(Icons.person),
                    title: Text(
                      document['name'],
                      style: GoogleFonts.robotoMono(),
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () async {
                        bool confirm = await showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: const Text('Удаление сотрудника'),
                              content: Text(
                                  'Вы действительно хотите удалить сотрудника ${document['name']}?'),
                              actions: <Widget>[
                                TextButton(
                                  child: const Text('Нет'),
                                  onPressed: () {
                                    Navigator.of(context).pop(false);
                                  },
                                ),
                                TextButton(
                                  child: const Text('Да'),
                                  onPressed: () {
                                    Navigator.of(context).pop(true);
                                  },
                                ),
                              ],
                            );
                          },
                        );

                        if (confirm) {
                          // Удаление сотрудника из коллекции Barber
                          FirebaseFirestore.instance
                              .collection('AllSalon')
                              .doc(ref.read(selectedCity.notifier).state.name)
                              .collection('Branch')
                              .doc(ref.read(selectedSalon.notifier).state.docId)
                              .collection('Barber')
                              .doc(document.id)
                              .delete();

                          // Проверка и удаление поля isStaff из коллекции User
                          QuerySnapshot userSnapshot = await FirebaseFirestore
                              .instance
                              .collection('User')
                              .where('isStaff', isEqualTo: true)
                              .get();

                          if (userSnapshot.docs.isNotEmpty) {
                            DocumentSnapshot userDoc = userSnapshot.docs.first;
                            userDoc.reference.update({'isStaff': false});
                          }

                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Сотрудник успешно удалён'),
                                duration: Duration(seconds: 2),
                              ),
                            );
                          }
                        }
                      },
                    ),
                  )));
            },
          );
        },
      ),
    );
  }
}
