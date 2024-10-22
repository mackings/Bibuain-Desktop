import 'dart:convert';
import 'package:bdesktop/Configuration/Model/model.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SingleOfferService {
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
  Future<Map<String, dynamic>> fetchRates({
    required String nusername,
    required String pusername,
  }) async {
    final response = await http.post(
      Uri.parse(ratesApiUrl),
      headers: {"Content-Type": "application/json"},
      body: json
          .encode({"nusername": "Eden_Ageh", "pusername": "MeekWhistler588"}),
    );

    if (response.statusCode == 200) {
      print(" Single Class DID ${response.body}");
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load market rates');
    }
  }

  // Get saved values from SharedPreferences for the specific user
  Future<Map<String, num>> _getSavedValues(String username) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    // Fetch markup for the specific username
    String? savedMarkupValue = prefs.getString('${username}_markup');
    // Fetch global override (binbinrate)
    String? savedBinbinRate = prefs.getString('override');

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

  // Calculate Prices with user-specific margin
  Future<Map<String, double>> calculatePrices({
    required Map<String, dynamic> ratesData,
    required String username,
  }) async {
    num? paxfulRate = ratesData['paxfulRate']['data'];
    num? binanceRate = ratesData['binanceRate']['price'];

    // Get binbinrate and user-specific markupValue from SharedPreferences
    Map<String, num> savedValues = await _getSavedValues(username);
    num binbinrate = savedValues['binbinrate']!;
    num markupValue = savedValues['markupValue']!;

    // Format values in thousands for display purposes
    final formatter = NumberFormat("#,##0");
    String formattedBinbinRate = formatter.format(binbinrate); // String
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
      print("Calculated Margin for ${username}: ${margin.toStringAsFixed(2)}%");

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
