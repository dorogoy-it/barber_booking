import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../state/state_management.dart';

class AddEmployeeScreen extends ConsumerStatefulWidget {
  const AddEmployeeScreen({super.key});

  @override
  AddEmployeeScreenState createState() => AddEmployeeScreenState();
}

class AddEmployeeScreenState extends ConsumerState<AddEmployeeScreen> {
  final TextEditingController _phoneNumberController = TextEditingController();
  final TextEditingController _employeeNameController = TextEditingController();
  final TextEditingController _employeeAddressController =
      TextEditingController();

  String? _verificationId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Добавить сотрудника',
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
              controller: _employeeNameController,
              decoration: const InputDecoration(
                labelText: 'Имя сотрудника',
              ),
            ),
            const SizedBox(height: 16.0),
            TextField(
              controller: _employeeAddressController,
              decoration: const InputDecoration(
                labelText: 'Адрес сотрудника',
              ),
            ),
            const SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () {
                _verifyPhoneNumber();
              },
              child: const Text('Зарегистрировать сотрудника'),
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
    await _registerEmployee(ref, credential);
  }

  void _verificationFailed(FirebaseAuthException exception) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
            exception.message ?? 'Не получилось зарегистрировать сотрудника'),
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
                await _registerEmployee(ref, credential);
                if (context.mounted) {
                  Navigator.of(context).pop();
                }
              },
              child: const Text('Подтвердить'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _registerEmployee(
      WidgetRef ref, PhoneAuthCredential credential) async {
    try {
      await FirebaseAuth.instance.signInWithCredential(credential);
      String? phoneNumber = FirebaseAuth.instance.currentUser!.phoneNumber;
      String selectedCityName = ref.read(selectedCity.notifier).state.name;
      String? selectedSalonDocId = ref.read(selectedSalon.notifier).state.docId;
      String uniqueId = FirebaseAuth.instance.currentUser!.uid;

      // Добавляем сотрудника в коллекцию User
      await FirebaseFirestore.instance.collection('User').doc(phoneNumber).set({
        'name': _employeeNameController.text,
        'address': _employeeAddressController.text,
        'id': uniqueId,
        'phone': phoneNumber,
        'isStaff': true,
      });

      // Добавляем сотрудника в коллекцию Barber
      await FirebaseFirestore.instance
          .collection('AllSalon')
          .doc(selectedCityName)
          .collection('Branch')
          .doc(selectedSalonDocId)
          .collection('Barber')
          .doc(uniqueId)
          .set({
        'name': _employeeNameController.text,
        'rating': 0,
        'ratingTimes': 0,
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Сотрудник успешно добавлен!'),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Ошибка регистрации: $e'),
          ),
        );
      }
    }
  }
}
