import 'dart:convert';
import 'package:http/http.dart' as http;

class StaffQueriesApiService {
  
  final String baseUrl = 'https://b-backend-xe8q.onrender.com';

  Future<Map<String, dynamic>?> fetchStaffQueries(String username) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/getquery/single/$username'));

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        print('Failed to load queries: ${response.statusCode}');
        return null;
      }
    } catch (error) {
      print('Error fetching queries: $error');
      return null;
    }
  }

  Future<Map<String, dynamic>?> sendStaffReply(String name, String queryId, String message) async {
    final url = '$baseUrl/query/staffreply';
    final body = json.encode({
      'name': name,
      'queryId': queryId,
      'message': message,
    });

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {"Content-Type": "application/json"},
        body: body,
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        print('Failed to send reply: ${response.statusCode}');
        return null;
      }
    } catch (error) {
      print('Error sending reply: $error');
      return null;
    }
  }
}
