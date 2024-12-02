import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';
import 'package:intl/intl.dart';
import 'loginPage.dart';

class pengaturan extends StatefulWidget {
  @override
  State<pengaturan> createState() => _pengaturanState();
}

class _pengaturanState extends State<pengaturan> {
  late String sessiUser;
  bool isPasswordVisible = false;

  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  String selectedTimezone = 'WIB';
  String username = '';
  DateTime currentTime = DateTime.now();

  String convertTime(String timezone) {
    DateTime time;
    switch (timezone) {
      case 'WITA':
        time = currentTime.add(const Duration(hours: 1));
        break;
      case 'WIT':
        time = currentTime.add(const Duration(hours: 2));
        break;
      case 'London':
        time = currentTime.subtract(const Duration(hours: 7));
        break;
      default:
        time = currentTime;
    }
    return DateFormat('yyyy-MM-dd HH:mm:ss').format(time);
  }

  @override
  void initState() {
    super.initState();
    _getUsername();
    _getTimezoneFromHive();
  }

  Future<void> _getTimezoneFromHive() async {
    var box = await Hive.openBox('preferences');
    setState(() {
      selectedTimezone = box.get('timezone', defaultValue: 'WIB');
    });
  }

  Future<void> _saveTimezoneToHive() async {
    var box = await Hive.openBox('preferences');
    await box.put('timezone', selectedTimezone);
  }

  Future<void> _getUsername() async {
    final sessionBox = await Hive.openBox('session');
    setState(() {
      sessiUser = sessionBox.get('username', defaultValue: '');
    });
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final box = await Hive.openBox('users');
    final userData = box.get(sessiUser);

    if (userData != null) {
      emailController.text = userData['email'] ?? '';
    }
    passwordController.clear();
  }

  String encryptPassword(String password) {
    final bytes = utf8.encode(password);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  Future<void> _saveChanges() async {
    final box = await Hive.openBox('users');
    final updatedEmail = emailController.text.trim();

    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(updatedEmail)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Email tidak valid')),
      );
      return;
    }

    String? updatedPassword;
    if (passwordController.text.isNotEmpty) {
      updatedPassword = encryptPassword(passwordController.text.trim());
    }

    print('username: $sessiUser');
    print('Updated password: $updatedPassword');

    box.put(sessiUser, {
      'email': updatedEmail,
      'password': updatedPassword ?? box.get(sessiUser)['password'],
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Data berhasil diperbarui')),
    );

    if (passwordController.text.isNotEmpty) {
      final sessionBox = await Hive.openBox('session');
      await sessionBox.clear();
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const LoginPage()),
        (route) => false,
      );
    }
  }

  Future<void> _showDeleteConfirmationDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Konfirmasi Hapus Akun'),
          content: const Text(
              'Apakah Anda yakin ingin menghapus akun ini? Aksi ini tidak dapat dibatalkan.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Batal'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();
                await _deleteAccount();
              },
              style: TextButton.styleFrom(
                foregroundColor: Colors.red,
              ),
              child: const Text('Hapus'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _deleteAccount() async {
    final box = await Hive.openBox('users');
    box.delete(sessiUser);

    final sessionBox = await Hive.openBox('session');
    await sessionBox.clear();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Akun berhasil dihapus')),
    );

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const LoginPage()),
      (route) => false,
    );
  }

  Widget _buildField({
    required String label,
    required TextEditingController controller,
    bool isPassword = false,
  }) {
    return TextField(
      controller: controller,
      obscureText: isPassword && !isPasswordVisible,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
        ),
        suffixIcon: isPassword
            ? IconButton(
                icon: Icon(
                  isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                ),
                onPressed: () {
                  setState(() {
                    isPasswordVisible = !isPasswordVisible;
                  });
                },
              )
            : null,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Text(
              'Setting akun',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _buildField(
              label: 'Email',
              controller: emailController,
            ),
            const SizedBox(height: 16),
            _buildField(
              label: 'Password',
              controller: passwordController,
              isPassword: true,
            ),
            const SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton(
                  onPressed: _saveChanges,
                  child: const Text('Save'),
                ),
                ElevatedButton(
                  onPressed: _showDeleteConfirmationDialog,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                  ),
                  child: const Text(
                    'Hapus Akun',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            const Divider(),
            const SizedBox(height: 20),
            const Text(
              'Setting zona waktu',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            DropdownButton<String>(
              value: selectedTimezone,
              onChanged: (String? newTimezone) {
                setState(() {
                  selectedTimezone = newTimezone!;
                });
                _saveTimezoneToHive();
              },
              items: ['WIB', 'WITA', 'WIT', 'London'].map((String timezone) {
                return DropdownMenuItem<String>(
                  value: timezone,
                  child: Text(timezone),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),
            Text(
              'Current Time: ${convertTime(selectedTimezone)}',
              style: const TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}
