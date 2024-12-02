import 'dart:convert';
import 'package:http/http.dart' as http;
import '/model/fundraiser.dart';

class CharityService {
  static const String apiUrl = "https://partners.every.org/v0.2/search";
  static const String apiKey = "pk_live_992abf893c167770e43681360147b02a";

  static Future<List<Fundraiser>> fetchFundraisers(String query) async {
    final uri = Uri.parse("$apiUrl/$query?apiKey=$apiKey");

    final response = await http.get(uri);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['nonprofits'] != null && data['nonprofits'] is List) {
        return (data['nonprofits'] as List)
            .map((item) => Fundraiser.fromJson(item))
            .toList();
      } else {
        return [];
      }
    } else {
      throw Exception("Failed to load fundraisers: ${response.reasonPhrase}");
    }
  }
}
