import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';
import '../model/modelDonasi.dart';
import '../model/fundraiser.dart';
import 'package:awesome_notifications/awesome_notifications.dart';

class DetailLembagaPage extends StatefulWidget {
  final Fundraiser fundraiser;

  const DetailLembagaPage({
    super.key,
    required this.fundraiser,
  });

  @override
  State<DetailLembagaPage> createState() => _DetailLembagaPageState();
}

class _DetailLembagaPageState extends State<DetailLembagaPage> {
  bool isAnonymous = false;
  late String username;
  late String selectedTimezone = 'WIB';
  String selectedCurrency = 'IDR';
  double conversionRate = 1.0;

  final List<String> currencies = ['IDR', 'USD', 'EUR', 'SGD', 'JPY'];

  final Map<String, double> currencyRates = {
    'IDR': 1.0,
    'USD': 0.00006278479,
    'EUR': 0.000060247253,
    'SGD': 0.000084587484,
    'JPY': 0.0097117399,
  };

  @override
  void initState() {
    super.initState();
    _getUsername();
    _getTimezoneFromHive();
  }

  Future<void> _getUsername() async {
    final sessionBox = await Hive.openBox('session');
    setState(() {
      username = sessionBox.get('username', defaultValue: 'User123');
    });
  }

  Future<void> _getTimezoneFromHive() async {
    var box = await Hive.openBox('preferences');
    String timezone = box.get('timezone', defaultValue: 'WIB');
    setState(() {
      selectedTimezone = timezone;
    });
  }

  String convertTime(DateTime currentTime) {
    DateTime time;
    switch (selectedTimezone) {
      case 'WITA':
        time = currentTime.add(Duration(hours: 1));
        break;
      case 'WIT':
        time = currentTime.add(Duration(hours: 2));
        break;
      case 'London':
        time = currentTime.subtract(Duration(hours: 7));
        break;
      default:
        time = currentTime;
    }
    return DateFormat('yyyy-MM-dd HH:mm:ss').format(time);
  }

  double convertCurrency(double amount) {
    return amount * conversionRate;
  }

  List<Donation> getDonations() {
    final donationBox = Hive.box<Donation>('donations');
    return donationBox.values
        .where((donation) => donation.charityName == widget.fundraiser.name)
        .toList();
  }

  void showDonationDialog() {
    final donationBox = Hive.box<Donation>('donations');
    final TextEditingController amountController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text("Donasi"),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      DropdownButton<String>(
                        value: selectedCurrency,
                        onChanged: (String? newCurrency) {
                          setDialogState(() {
                            selectedCurrency = newCurrency!;
                            conversionRate =
                                currencyRates[selectedCurrency] ?? 1.0;
                          });
                        },
                        items: currencies.map((String currency) {
                          return DropdownMenuItem<String>(
                            value: currency,
                            child: Text(currency),
                          );
                        }).toList(),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextField(
                          controller: amountController,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            hintText: "Masukkan nominal (IDR)",
                            labelText: "Jumlah Donasi",
                          ),
                          onChanged: (value) {
                            setDialogState(() {});
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Nominal setelah konversi:",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text(
                            "${amountController.text.isEmpty ? 0 : convertCurrency(double.tryParse(amountController.text) ?? 0)} ${selectedCurrency}",
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text("Sembunyikan Nama?"),
                      Switch(
                        value: isAnonymous,
                        onChanged: (value) {
                          setDialogState(() {
                            isAnonymous = value;
                          });
                        },
                      ),
                    ],
                  ),
                ],
              ),
              actions: [
                ElevatedButton(
                  onPressed: () {
                    final donorName = isAnonymous ? "Anonymous" : username;
                    double amount =
                        double.tryParse(amountController.text) ?? 0.0;
                    double convertedAmount = convertCurrency(amount);
                    if (amount <= 0 || convertedAmount <= 0) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text('Harap isi nominal donasi > 0')),
                      );
                      return;
                    }
                    donationBox.add(
                      Donation(
                        donorName: donorName,
                        charityName: widget.fundraiser.name!,
                        amount: convertedAmount,
                        currency: selectedCurrency,
                        date: DateTime.now(),
                      ),
                    );

                    AwesomeNotifications().createNotification(
                      content: NotificationContent(
                        id: DateTime.now()
                            .millisecondsSinceEpoch
                            .remainder(100000),
                        channelKey: 'donasi',
                        title: 'Terima Kasih atas Donasi Anda!',
                        body:
                            '$donorName telah mendonasikan $convertedAmount $selectedCurrency untuk ${widget.fundraiser.name}',
                        notificationLayout: NotificationLayout.Default,
                      ),
                    );
                    Navigator.pop(context);
                    setState(() {});
                    _showSuccessDialog();
                  },
                  child: const Text("Donasikan"),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Terima Kasih!"),
          content: const Text("Donasi Anda berhasil dilakukan."),
          actions: [
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("OK"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final donations = getDonations();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.fundraiser.name ?? "Detail Lembaga",
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Color.fromRGBO(158, 223, 156, 1),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Card(
              elevation: 4,
              margin: const EdgeInsets.only(bottom: 16),
              child: Column(
                children: [
                  widget.fundraiser.coverImageUrl != null
                      ? Image.network(
                          widget.fundraiser.coverImageUrl!,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Image.asset('assets/default.jpg');
                          },
                        )
                      : Image.asset('assets/default.jpg'),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      widget.fundraiser.description ??
                          "Deskripsi tidak tersedia.",
                      style: const TextStyle(fontSize: 16),
                      textAlign: TextAlign.justify,
                    ),
                  ),
                ],
              ),
            ),
            ElevatedButton(
              onPressed: showDonationDialog,
              child: const Text("Donasi Sekarang"),
            ),
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 16),
            donations.isNotEmpty
                ? Expanded(
                    child: ListView.builder(
                      itemCount: donations.length,
                      itemBuilder: (context, index) {
                        final donation = donations[index];
                        String convertedTime = convertTime(donation.date);
                        return Card(
                          margin: EdgeInsets.all(10),
                          color: Colors.grey.shade300,
                          child: ListTile(
                            title: Text(
                              '${donation.amount} ${donation.currency}',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  donation.donorName,
                                  style: TextStyle(color: Colors.black54),
                                ),
                                Text(
                                  '${convertedTime} - ($selectedTimezone)',
                                  style: TextStyle(color: Colors.black54),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  )
                : const Center(
                    child: Text(
                        "Jadilah orang pertama yang bergerak dan berkontribusi membantu lembaga ini!"),
                  ),
          ],
        ),
      ),
    );
  }
}
