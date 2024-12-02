import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:soulsociety/screens/pengaturanPage.dart';
import 'package:soulsociety/screens/profilePage.dart';
import 'package:soulsociety/screens/menuPage.dart';
import 'package:soulsociety/screens/loginPage.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomePage> {
  int _currentIndex = 0;

  final List<Widget> _pages = [const HomeMenu(), ProfilePage(), pengaturan()];

  void _onItemTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  Future<void> logoutUser(BuildContext context) async {
    final sessionBox = await Hive.openBox('session');
    await sessionBox.clear();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Berhasil logout')),
    );

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const LoginPage()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],
      appBar: AppBar(
        title: Text(
          _currentIndex == 0
              ? 'SoulSociety'
              : _currentIndex == 1
                  ? 'Profile'
                  : 'Pengaturan',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Color.fromRGBO(158, 223, 156, 1),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => logoutUser(context),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
          BottomNavigationBarItem(
              icon: Icon(Icons.settings), label: 'Pengaturan'),
        ],
      ),
    );
  }
}

class HomeMenu extends StatelessWidget {
  const HomeMenu({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        elevation: 8,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: const Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text(
                "Charity Section Menu",
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 20),
              tombolMenu(
                text: 'Health',
                tujuan: 'health',
              ),
              SizedBox(height: 20),
              tombolMenu(
                text: 'Disabilities',
                tujuan: 'disabilities',
              ),
              SizedBox(height: 20),
              tombolMenu(
                text: 'Cancer',
                tujuan: 'cancer',
              ),
              SizedBox(height: 20),
              tombolMenu(
                text: 'Autism',
                tujuan: 'autism',
              ),
              SizedBox(height: 20),
              tombolMenu(
                text: 'Humans',
                tujuan: 'humans',
              ),
              SizedBox(height: 20),
              tombolMenu(
                text: 'Environment',
                tujuan: 'environment',
              ),
              SizedBox(height: 20),
              tombolMenu(
                text: 'Justice',
                tujuan: 'justice',
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class tombolMenu extends StatelessWidget {
  final String text;
  final String tujuan;

  const tombolMenu({super.key, required this.text, required this.tujuan});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => menuPage(type: tujuan),
            ),
          );
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color.fromARGB(255, 128, 182, 126),
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: Text(
          text,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
