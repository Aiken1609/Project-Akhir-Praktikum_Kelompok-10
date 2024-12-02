import 'package:hive/hive.dart';

part 'modelDonasi.g.dart';

@HiveType(typeId: 1)
class Donation extends HiveObject {
  @HiveField(0)
  final String donorName;

  @HiveField(1)
  final String charityName;

  @HiveField(2)
  final double amount;

  @HiveField(3)
  final String currency;

  @HiveField(4)
  final DateTime date;

  Donation({
    required this.donorName,
    required this.charityName,
    required this.amount,
    required this.currency,
    required this.date,
  });
}
