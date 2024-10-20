import 'dart:convert';
import 'package:bdesktop/Manual/Dashboard/Model/staffmodel.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
class StaffOverviewService {
  final String baseUrl = 'https://b-backend-xe8q.onrender.com/staff/single';

  // Fetch staff data using the username directly
  Future<StaffResponse?> fetchStaffData(String username) async {
    final url = Uri.parse('$baseUrl/$username');

    print('Fetching data for: $username');

    try {
      final response = await http.get(url);

      // Check if the response is successful
      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);

        // Log the API response for debugging
        print('API response: $jsonResponse');

        // Ensure the response is well-structured
        if (jsonResponse['success'] != null && jsonResponse['data'] != null) {
          return StaffResponse.fromJson(jsonResponse);
        } else {
          print('Invalid API response structure: $jsonResponse');
          return null; // Return null or handle as needed
        }
      } else {
        print('Failed to load data. Status code: ${response.statusCode}');
        return null; // Return null or handle as needed
      }
    } catch (e) {
      print('Error fetching staff data: $e');
      return null; // Return null or handle as needed
    }
  }
}