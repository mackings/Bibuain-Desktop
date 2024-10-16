import 'dart:convert';
import 'package:bdesktop/Configuration/Model/model.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

class OfferService {
  final String offersApiUrl =
      'https://b-backend-xe8q.onrender.com/offers/paxful/get-multiple';
  final String ratesApiUrl = 'https://b-backend-xe8q.onrender.com/market/rates';

  Future<List<AccountOffers>> fetchOffers() async {
    final response = await http.get(Uri.parse(offersApiUrl));

    if (response.statusCode == 200) {
      List<dynamic> jsonResponse = json.decode(response.body);

      List<AccountOffers> accountOffersList = jsonResponse.map((data) {
        return AccountOffers.fromJson(data);
      }).toList();
      print(accountOffersList[0]);

      return accountOffersList;
    } else {
      throw Exception('Failed to load offers');
    }
  }

  // Fetch market rates
  Future<Map<String, dynamic>> fetchRates(
      {required String nusername, required String pusername}) async {
    final response = await http.post(
      Uri.parse(ratesApiUrl),
      headers: {"Content-Type": "application/json"},
      body: json.encode({"nusername": nusername, "pusername": pusername}),
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load market rates');
    }
  }

  // Calculate Prices


  Map<String, double> calculatePrices(Map<String, dynamic> ratesData) {
  num? paxfulRate = ratesData['paxfulRate']['data'];
  num? binanceRate = ratesData['binanceRate']['price'];

  num binbinrate = 1698;
  num markupValue = 250000;

  // Ensure rates are non-null before proceeding
  if (paxfulRate != null && binanceRate != null) {
    final formatter = NumberFormat("#,##0");

    num sellingPrice = paxfulRate * binbinrate;
    num costPrice;
    num rateDifference;

    if (binanceRate >= paxfulRate) {
      rateDifference = binbinrate * (paxfulRate - binanceRate);
      costPrice = sellingPrice - rateDifference - markupValue;
    } else {
      costPrice = sellingPrice - markupValue;
    }

    // Calculate margin
    num margin = ((sellingPrice - costPrice) / costPrice) * 100;
    String formattedMarkup = formatter.format(markupValue);

    print("Formatted Markup: $formattedMarkup");
    print("Calculated Margin: ${margin.toStringAsFixed(2)}%");

    // Return calculated prices and margin as double
    return {
      'CP': costPrice.toDouble(),
      'SP': sellingPrice.toDouble(),
      'Margin': margin.toDouble() // Add margin to the returned map
    };
  } else {
    throw Exception("Rates data is missing or null");
  }
}

  // Map<String, double> calculatePrices(Map<String, dynamic> ratesData) {
  //   num? paxfulRate = ratesData['paxfulRate']['data'];
  //   num? binanceRate = ratesData['binanceRate']['price'];

  //   // Assuming binbinrate and markupValue are predefined
  //   num binbinrate = 1698;
  //   num markupValue = 250000;
  //   num systemOverride = 1704;

  //   // Ensure rates are non-null before proceeding
  //   if (paxfulRate != null && binanceRate != null) {
  //     // Create a number formatter
  //     final formatter = NumberFormat("#,##0");

  //     // Calculate the selling price using the numerical binbinrate
  //     num sellingPrice = paxfulRate * binbinrate;

  //     // Initialize cost price and rate difference as num

  //     num costPrice;
  //     num rateDifference;

  //     if (binanceRate >= paxfulRate) {
  //       rateDifference = binbinrate * (paxfulRate - binanceRate);
  //       costPrice = sellingPrice - rateDifference - markupValue;
  //     } else {
  //       costPrice = sellingPrice - markupValue;
  //     }

  //     // Format the system override and markup for display
  //     String formattedSystemOverride = formatter.format(systemOverride);
  //     String formattedMarkup = formatter.format(markupValue);

  //     // Output formatted values (optional: log or display them)
  //     print("Formatted System Override: $formattedSystemOverride");
  //     print("Formatted Markup: $formattedMarkup");

  //     // Return calculated prices as double
  //     return {
  //       'CP': costPrice
  //           .toDouble(), // Convert costPrice to double before returning
  //       'SP': sellingPrice
  //           .toDouble(), // Convert sellingPrice to double before returning
  //     };
  //   } else {
  //     throw Exception("Rates data is missing or null");
  //   }
  // }
}
