import 'package:http/http.dart' as http;
import 'dart:convert';

class QueryService {
  Future<void> closeQuery(String name, String queryId) async {
    final url = Uri.parse('https://b-backend-xe8q.onrender.com/removequery');
    
    try {
      final response = await http.delete(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'name': name,
          'queryId': queryId,
        }),
      );

      if (response.statusCode == 200) {
        // Handle successful response
        print('Query closed successfully');
      } else {
        // Handle error response
        print('Failed to close query: ${response.body}');
      }
    } catch (error) {
      print('Error closing query: $error');
    }
  }
}
