import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../state/state_management.dart';

class AddAdminScreen extends ConsumerStatefulWidget {
  const AddAdminScreen({super.key});

  @override
  AddAdminScreenState createState() => AddAdminScreenState();
}

class AddAdminScreenState extends ConsumerState<AddAdminScreen> {
  final TextEditingController _phoneNumberController = TextEditingController();
  final TextEditingController _adminNameController = TextEditingController();
  final TextEditingController _adminAddressController = TextEditingController();

  String? _verificationId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Добавить администратора',
          style: TextStyle(
            color: Colors.white, // Здесь указывается цвет текста
          ),
        ),
        backgroundColor: const Color(0xFF383838),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      resizeToAvoidBottomInset: true,
      backgroundColor: const Color(0xFFFDF9EE),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _phoneNumberController,
              decoration: const InputDecoration(
                labelText: 'Номер телефона',
              ),
            ),
            const SizedBox(height: 16.0),
            TextField(
              controller: _adminNameController,
              decoration: const InputDecoration(
                labelText: 'Имя админа',
              ),
            ),
            const SizedBox(height: 16.0),
            TextField(
              controller: _adminAddressController,
              decoration: const InputDecoration(
                labelText: 'Адрес админа',
              ),
            ),
            const SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () {
                _verifyPhoneNumber();
              },
              child: const Text('Зарегистрировать админа'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _verifyPhoneNumber() async {
    await FirebaseAuth.instance.verifyPhoneNumber(
      phoneNumber: _phoneNumberController.text,
      verificationCompleted: _verificationCompleted,
      verificationFailed: _verificationFailed,
      codeSent: _codeSent,
      codeAutoRetrievalTimeout: _autoRetrieve,
    );
  }

  void _autoRetrieve(String verId) {
    _verificationId = verId;
  }

  void _codeSent(String verId, [int? forceCodeResend]) {
    _verificationId = verId;
    _showOTPDialog(ref);
  }

  void _verificationCompleted(PhoneAuthCredential credential) async {
    await _registerAdmin(ref, credential);
  }

  void _verificationFailed(FirebaseAuthException exception) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(exception.message ?? 'Не получилось зарегистрировать сотрудника'),
      ),
    );
  }

  void _showOTPDialog(WidgetRef ref) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        final TextEditingController otpController = TextEditingController();
        return AlertDialog(
          title: const Text('Введите код подтверждения'),
          content: TextField(
            controller: otpController,
            keyboardType: TextInputType.number,
          ),
          actions: [
            ElevatedButton(
              onPressed: () async {
                PhoneAuthCredential credential = PhoneAuthProvider.credential(
                  verificationId: _verificationId!,
                  smsCode: otpController.text,
                );
                await _registerAdmin(ref, credential);
                Navigator.of(context).pop();
              },
              child: const Text('Подтвердить'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _registerAdmin(WidgetRef ref, PhoneAuthCredential credential) async {
    try {
      await FirebaseAuth.instance.signInWithCredential(credential);
      String? phoneNumber = FirebaseAuth.instance.currentUser!.phoneNumber;
      String selectedCityName =
          ref.read(selectedCity.notifier).state.name;
      String? selectedSalonDocId = ref.read(selectedSalon.notifier).state.docId;
      String uniqueId = FirebaseAuth.instance.currentUser!.uid;

      // Добавляем админа в коллекцию User
      await FirebaseFirestore.instance.collection('User').doc(phoneNumber).set({
        'name': _adminNameController.text,
        'address': _adminAddressController.text,
        'id': uniqueId,
        'phone': phoneNumber,
        'isAdmin': true,
      });

      // Добавляем админа в коллекцию Barber
      await FirebaseFirestore.instance
          .collection('AllSalon')
          .doc(selectedCityName)
          .collection('Branch')
          .doc(selectedSalonDocId)
          .collection('Admin')
          .doc(uniqueId)
          .set({
        'name': _adminNameController.text,
        'id': uniqueId,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Администратор успешно добавлен!'),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Ошибка регистрации: $e'),
        ),
      );
    }
  }
}