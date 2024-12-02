import 'package:flutter/material.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Center(
              child: CircleAvatar(
                radius: 80,
                backgroundImage: AssetImage('assets/profile.jpg'),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Aiken Ahmad Hakeem',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 5),
            const Text(
              'NIM: 124220128',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 20),
            const DropDownSection(
              title: 'Kesan pesan',
              dropDown: [
                'Lorem ipsum amet',
                'Sed ut perspiciatis unde omnis iste natus error sit voluptatem accusantium doloremque laudantium.',
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class DropDownSection extends StatefulWidget {
  final String title;
  final List<String> dropDown;

  const DropDownSection({
    required this.title,
    required this.dropDown,
    super.key,
  });

  @override
  _DropDownSectionState createState() => _DropDownSectionState();
}

class _DropDownSectionState extends State<DropDownSection> {
  bool isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.grey.shade300),
        ),
      ),
      child: ExpansionTile(
        tilePadding: EdgeInsets.zero,
        title: Text(
          widget.title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        initiallyExpanded: false,
        onExpansionChanged: (value) {
          setState(() {
            isExpanded = value;
          });
        },
        children: widget.dropDown.map((step) {
          return Padding(
            padding: const EdgeInsets.fromLTRB(24, 6, 6, 6),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '• ',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                Expanded(
                  child: Text(
                    step,
                    style: const TextStyle(fontSize: 16),
                    textAlign: TextAlign.justify,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}
