import 'package:bdesktop/Performance/model/model.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class StaffPerformanceService {

  final String baseUrl = 'https://b-backend-xe8q.onrender.com';

  Future<List<StaffPerformanceModel>> fetchStaffs() async {
    final response = await http.get(Uri.parse('$baseUrl/staffs'));

    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body);
      print("Staff List $jsonData");
      
      if (jsonData['success']) {
        List<StaffPerformanceModel> staffList = (jsonData['data'] as List)
            .map((staff) => StaffPerformanceModel.fromJson(staff))
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

