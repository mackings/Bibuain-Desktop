import 'dart:convert';
import 'package:bdesktop/Configuration/Model/model.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';


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

  // Get saved values from SharedPreferences
  Future<Map<String, num>> _getSavedValues() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    String? savedBinbinRate = prefs.getString('override');
    String? savedMarkupValue = prefs.getString('markup');

    num binbinrate = savedBinbinRate != null
        ? num.parse(
            savedBinbinRate.replaceAll(',', '')) // Remove commas for parsing
        : 1640; // Default value if not found

    num markupValue = savedMarkupValue != null
        ? num.parse(
            savedMarkupValue.replaceAll(',', '')) // Remove commas for parsing
        : 250000; // Default value if not found

    print(
        "Prefs Got ${savedBinbinRate} ${savedMarkupValue} and formatted ${binbinrate} ${markupValue}");
    return {
      'binbinrate': binbinrate,
      'markupValue': markupValue,
    };
  }

  // Calculate Prices
Future<Map<String, double>> calculatePrices(Map<String, dynamic> ratesData) async {

  num? paxfulRate = ratesData['paxfulRate']['data'];
  num? binanceRate = ratesData['binanceRate']['price'];

  // Get binbinrate and markupValue from SharedPreferences
  Map<String, num> savedValues = await _getSavedValues();
  num binbinrate = savedValues['binbinrate']!;
  num markupValue = savedValues['markupValue']!;

  // Format values in thousands for display purposes
  final formatter = NumberFormat("#,##0");
  String formattedBinbinRate = formatter.format(binbinrate);  // String
  String formattedMarkupValue = formatter.format(markupValue); // String

  // Print the formatted values to the console
  print("Binbinrate used (formatted): $formattedBinbinRate");
  print("Markup Value used (formatted): $formattedMarkupValue");

  num parsedBinbinRate = num.parse(formattedBinbinRate.replaceAll(',', ''));
  num parsedMarkupValue = num.parse(formattedMarkupValue.replaceAll(',', ''));


  if (paxfulRate != null && binanceRate != null) {

    num sellingPrice = paxfulRate * parsedBinbinRate;
    num costPrice;
    num rateDifference;

    if (binanceRate >= paxfulRate) {
      rateDifference = parsedBinbinRate * (paxfulRate - binanceRate);
      costPrice = sellingPrice - rateDifference - parsedMarkupValue;
    } else {
      costPrice = sellingPrice - parsedMarkupValue;
    }

    num margin = ((sellingPrice - costPrice) / costPrice) * 100;
    print("Calculated Margin: ${margin.toStringAsFixed(2)}%");

    return {
      'CP': costPrice.toDouble(),
      'SP': sellingPrice.toDouble(),
      'Margin': margin.toDouble(),
    };
  } else {
    throw Exception("Rates data is missing or null");
  }
}


}




  // Calculate Prices


//   Map<String, double> calculatePrices(Map<String, dynamic> ratesData) {
//   num? paxfulRate = ratesData['paxfulRate']['data'];
//   num? binanceRate = ratesData['binanceRate']['price'];

//   num binbinrate = 1640;
//   num markupValue = 250000;

//   // Ensure rates are non-null before proceeding
//   if (paxfulRate != null && binanceRate != null) {
//     final formatter = NumberFormat("#,##0");

//     num sellingPrice = paxfulRate * binbinrate;
//     num costPrice;
//     num rateDifference;

//     if (binanceRate >= paxfulRate) {
//       rateDifference = binbinrate * (paxfulRate - binanceRate);
//       costPrice = sellingPrice - rateDifference - markupValue;
//     } else {
//       costPrice = sellingPrice - markupValue;
//     }

//     // Calculate margin
//     num margin = ((sellingPrice - costPrice) / costPrice) * 100;
//     String formattedMarkup = formatter.format(markupValue);

//     print("Formatted Markup: $formattedMarkup");
//     print("Calculated Margin: ${margin.toStringAsFixed(2)}%");

//     // Return calculated prices and margin as double
//     return {
//       'CP': costPrice.toDouble(),
//       'SP': sellingPrice.toDouble(),
//       'Margin': margin.toDouble() // Add margin to the returned map
//     };
//   } else {
//     throw Exception("Rates data is missing or null");
//   }
// }