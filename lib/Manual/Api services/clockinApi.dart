// lib/api_service.dart

import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  final String baseUrl = 'https://b-backend-xe8q.onrender.com';

  Future<Map<String, dynamic>> clockIn(String token) async {
    final String url = '$baseUrl/clockin';
    final Map<String, dynamic> requestBody = {
      "token": token,
    };

    try {
      var response = await http.post(
        Uri.parse(url),
        headers: {
          "Content-Type": "application/json",
        },
        body: jsonEncode(requestBody),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body); 
      } else {
        return {
          'success': false,
          'message': 'Error: ${response.statusCode}',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'An error occurred: $e',
      };
    }
  }


Future<Map<String, dynamic>> clockOut(String token) async {
    final String url = '$baseUrl/clockout';
    final Map<String, dynamic> requestBody = {
      "token": token,
    };

    try {
      var response = await http.post(
        Uri.parse(url),
        headers: {
          "Content-Type": "application/json",
        },
        body: jsonEncode(requestBody),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body); // Return the response as a Map
      } else {
        return {
          'success': false,
          'message': 'Error: ${response.statusCode}',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'An error occurred: $e',
      };
    }
  }
}
