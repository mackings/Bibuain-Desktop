import 'dart:convert';
import 'package:bdesktop/HR/models/staffpayroll.dart';
import 'package:http/http.dart' as http;



class PayrollApiService {
  final String baseUrl = 'https://b-backend-xe8q.onrender.com/payroll/all';

  Future<Map<String, dynamic>> fetchPayrollData() async {
    try {
      final response = await http.get(Uri.parse(baseUrl));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success']) {
          // Parse staff payrolls
          List<StaffPayroll> staffPayrolls = (data['data']['staffPayrolls'] as List)
              .map((i) => StaffPayroll.fromJson(i))
              .toList();

          return {
            'success': true,
            'data': {
              'staffCount': data['data']['staffCount'],
              'totalAmountPaid': data['data']['totalAmountPaid'],
              'totalDebts': data['data']['totalDebts'],
              'staffPayrolls': staffPayrolls,
            },
          };
        } else {
          throw Exception(data['message']);
        }
      } else {
        throw Exception('Failed to load payroll data');
      }
    } catch (error) {
      throw Exception('Error fetching payroll data: $error');
    }
  }
}
