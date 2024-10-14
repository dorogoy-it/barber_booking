import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../model/service_model.dart';
import '../state/state_management.dart';

class EditServiceScreen extends ConsumerStatefulWidget {
  const EditServiceScreen({super.key});

  @override
  ServiceScreenState createState() => ServiceScreenState();
}

class ServiceScreenState extends ConsumerState<EditServiceScreen> {
  late TextEditingController _nameController;
  late TextEditingController _priceController;
  late Future<List<ServiceModel>> _servicesFuture;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _priceController = TextEditingController();
    _servicesFuture = _getServices(ref);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  Future<List<ServiceModel>> _getServices(WidgetRef ref) async {
    var services = <ServiceModel>[];
    CollectionReference serviceRef =
        FirebaseFirestore.instance.collection('Services');
    QuerySnapshot snapshot = await serviceRef
        .where(ref.read(selectedSalon.notifier).state.docId!, isEqualTo: true)
        .get();
    for (var element in snapshot.docs) {
      final data = element.data() as Map<String, dynamic>;
      var serviceModel = ServiceModel.fromJson(data);
      serviceModel.docId = element.id;
      services.add(serviceModel);
    }
    return services;
  }

  Future<void> _addService(WidgetRef ref) async {
    String name = _nameController.text;
    double price = double.parse(_priceController.text);
    await FirebaseFirestore.instance.collection('Services').add({
      ref.read(selectedSalon.notifier).state.docId!: true,
      'name': name,
      'price': price,
    });
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Услуга успешно добавлена'),
        ),
      );
    }
    setState(() {
      _servicesFuture = _getServices(ref);
      _nameController.clear();
      _priceController.clear();
    });
  }

  Future<void> _editService(WidgetRef ref, ServiceModel service) async {
    String name = _nameController.text;
    double price = double.parse(_priceController.text);
    await FirebaseFirestore.instance
        .collection('Services')
        .doc(service.docId)
        .update({
      'name': name,
      'price': price,
    });
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Услуга успешно отредактирована'),
        ),
      );
    }
    setState(() {
      _servicesFuture = _getServices(ref);
      _nameController.clear();
      _priceController.clear();
    });
  }

  Future<void> _deleteService(WidgetRef ref, ServiceModel service) async {
    await FirebaseFirestore.instance
        .collection('Services')
        .doc(service.docId)
        .delete();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Услуга успешно удалена'),
        ),
      );
    }
    setState(() {
      _servicesFuture = _getServices(ref);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Услуги салона',
          style: TextStyle(
            color: Colors.white, // Здесь указывается цвет текста
          ),
        ),
        backgroundColor: const Color(0xFF383838),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      resizeToAvoidBottomInset: true,
      backgroundColor: const Color(0xFFFDF9EE),
      body: FutureBuilder<List<ServiceModel>>(
        future: _servicesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Text('Ошибка: ${snapshot.error}'),
            );
          } else {
            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                var service = snapshot.data![index];
                return Card(
                    child: ListTile(
                  title: Text(service.name),
                  subtitle: Text('${service.price} руб.'),
                  leading: const Icon(Icons.content_cut),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (context) {
                              return AlertDialog(
                                title: const Text('Редактировать услугу'),
                                content: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    TextField(
                                      controller: _nameController
                                        ..text = service.name,
                                      decoration: const InputDecoration(
                                          labelText: 'Название'),
                                    ),
                                    TextField(
                                      controller: _priceController
                                        ..text = service.price.toString(),
                                      decoration: const InputDecoration(
                                          labelText: 'Цена'),
                                      keyboardType: TextInputType.number,
                                    ),
                                  ],
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                    },
                                    child: const Text('Отмена'),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      _editService(ref, service);
                                      Navigator.of(context).pop();
                                    },
                                    child: const Text('Сохранить'),
                                  ),
                                ],
                              );
                            },
                          );
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (context) {
                              return AlertDialog(
                                title: const Text('Удалить услугу?'),
                                content: Text(
                                    'Вы уверены, что хотите удалить услугу "${service.name}"?'),
                                actions: [
                                  TextButton(
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                    },
                                    child: const Text('Отмена'),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      _deleteService(ref, service);
                                      Navigator.of(context).pop();
                                    },
                                    child: const Text('Удалить'),
                                  ),
                                ],
                              );
                            },
                          );
                        },
                      ),
                    ],
                  ),
                ));
              },
            );
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                title: const Text('Добавить услугу'),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: _nameController,
                      decoration: const InputDecoration(labelText: 'Название'),
                    ),
                    TextField(
                      controller: _priceController,
                      decoration: const InputDecoration(labelText: 'Цена'),
                      keyboardType: TextInputType.number,
                    ),
                  ],
                ),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: const Text('Отмена'),
                  ),
                  TextButton(
                    onPressed: () {
                      _addService(ref);
                      Navigator.of(context).pop();
                    },
                    child: const Text('Добавить'),
                  ),
                ],
              );
            },
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
