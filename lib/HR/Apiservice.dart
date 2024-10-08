import 'dart:convert';
import 'package:bdesktop/HR/models/staffmodel.dart';
import 'package:http/http.dart' as http;

class StaffApiService {
  final String baseUrl = 'https://b-backend-xe8q.onrender.com';

  Future<List<Staff>> fetchStaffs() async {
    final response = await http.get(Uri.parse('$baseUrl/staffs'));

    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body);
      print("Staff List $jsonData");
      
      if (jsonData['success']) {
        List<Staff> staffList = (jsonData['data'] as List)
            .map((staff) => Staff.fromJson(staff))
            .toList();
        return staffList;
      } else {
        throw Exception('Failed to load staff');
      }
    } else {
      throw Exception('Failed to load staff');
    }
  }
}
