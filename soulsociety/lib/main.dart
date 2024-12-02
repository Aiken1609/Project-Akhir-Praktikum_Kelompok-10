import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:soulsociety/screens/loginPage.dart';
import 'package:soulsociety/screens/homePage.dart';
import 'package:soulsociety/model/modelDonasi.dart';
import 'package:awesome_notifications/awesome_notifications.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  AwesomeNotifications().isNotificationAllowed().then((isAllowed) {
    if (!isAllowed) {
      AwesomeNotifications().requestPermissionToSendNotifications();
    }
  });
  AwesomeNotifications().initialize(
    null,
    [
      NotificationChannel(
        channelKey: 'donasi',
        channelName: 'Donation Notifications',
        channelDescription: 'Notification for successful donations',
        defaultColor: Colors.blue,
        ledColor: Colors.white,
        importance: NotificationImportance.High,
      ),
    ],
  );

  await Hive.initFlutter();

  Hive.registerAdapter(DonationAdapter());

  await Hive.openBox<Donation>('donations');
  await Hive.openBox('session');

  runApp(const CharityApp());
}

class CharityApp extends StatelessWidget {
  const CharityApp({super.key});

  Future<bool> checkSession() async {
    final sessionBox = Hive.box('session');
    return sessionBox.get('isLoggedIn', defaultValue: false);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: checkSession(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const MaterialApp(
            home: Scaffold(
              body: Center(child: CircularProgressIndicator()),
            ),
          );
        }

        if (snapshot.data == true) {
          return const MaterialApp(
            home: HomePage(),
            debugShowCheckedModeBanner: false,
          );
        }

        return const MaterialApp(
          home: LoginPage(),
          debugShowCheckedModeBanner: false,
        );
      },
    );
  }
}
