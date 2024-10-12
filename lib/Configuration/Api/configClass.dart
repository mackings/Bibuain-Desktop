import 'dart:convert';
import 'package:bdesktop/Configuration/Model/model.dart';
import 'package:http/http.dart' as http;

class OfferService {

  final String apiUrl = 'https://b-backend-xe8q.onrender.com/offers/paxful/get-multiple';

  Future<List<AccountOffers>> fetchOffers() async {
    final response = await http.get(Uri.parse(apiUrl));

    if (response.statusCode == 200) {
      List<dynamic> jsonResponse = json.decode(response.body);

      List<AccountOffers> accountOffersList = jsonResponse.map((data) {
        return AccountOffers.fromJson(data);
      }).toList();

      return accountOffersList;
    } else {
      throw Exception('Failed to load offers');
    }
  }

  
}
