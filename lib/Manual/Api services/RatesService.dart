
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

class RateService {
  // Fetch Paxful Rates
  Future<int?> fetchPaxfulRates() async {
    
    const String url = 'https://tester-1wva.onrender.com/paxful/paxful/rates';
    try {
      // Make the POST request
      final http.Response response = await http.post(Uri.parse(url));

      if (response.statusCode == 200) {
        // Decode the response body
        final Map<String, dynamic> responseData = json.decode(response.body);
        double price = responseData['price'];
        int priceAsInt = price.toInt(); // Convert to int
        print('Paxful USD RATE: $priceAsInt');
        return priceAsInt;
      } else {
        print('Failed to fetch Paxful price: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Error fetching Paxful price: $e');
      return null;
    }
  }

  // Fetch Binance Rates
  Future<int?> fetchBinanceRates() async {
    const String url = 'https://tester-1wva.onrender.com/paxful/binance/rates';
    try {
      // Make the POST request
      final http.Response response = await http.post(Uri.parse(url));

      if (response.statusCode == 200) {
        // Decode the response body
        final Map<String, dynamic> responseData = json.decode(response.body);
        int price = responseData['price'];
        print('Binance USD RATE: $price');
        return price;
      } else {
        print('Failed to fetch Binance price: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Error fetching Binance price: $e');
      return null;
    }
  }

  // Calculate Prices
  
  Future<void> calculatePrices(Function setState) async {
    int? paxfulRate = await fetchPaxfulRates();
    int? binanceRate = await fetchBinanceRates();
    int systemOverride = 1587;
    int markup = 250000;

    if (paxfulRate != null && binanceRate != null) {
      final formatter = NumberFormat("#,##0");

      String formattedPaxfulRate = formatter.format(paxfulRate);
      String formattedBinanceRate = formatter.format(binanceRate);
      String formattedSystemOverride = formatter.format(systemOverride);
      String formattedMarkup = formatter.format(markup);

      // Print the formatted rates before any calculation
      print("Paxful Rate: $formattedPaxfulRate");
      print("Binance Rate: $formattedBinanceRate");
      print("System Override: $formattedSystemOverride");
      print("Markup: $formattedMarkup");

      // Calculate the selling price using the given logic
      int sellingPrice = paxfulRate * systemOverride;

      print("Selling Price: $sellingPrice");

      if (paxfulRate > binanceRate) {
        // Calculate the difference between the rates
        int rateDifference = paxfulRate - binanceRate;
        print("Rate Diff Pax/Bin: $rateDifference");

        // Calculate the cost price using the given logic
        int costPrice = (rateDifference + markup) + sellingPrice;

        print("Cost Price when Paxful is higher: $costPrice");

        setState(() {
          // Update state with the calculated values
        });
      } else {
        // Calculate the cost price when Binance rate is higher
        int rateDifference = paxfulRate - binanceRate;
        int costPrice = systemOverride - sellingPrice;

        print("Cost Price when Binance is higher: $costPrice");
        print("Rate Diff Pax/Bin: $rateDifference");

        setState(() {
          // Update state with the calculated values
        });
      }
    }
  }
}
