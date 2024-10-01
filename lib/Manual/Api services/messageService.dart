
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart';

class MessageService {
  final String apiUrl = 'https://b-backend-xe8q.onrender.com/paxful/send-message';

  // Function to send a message
  Future<void> sendMessage({
    required String messageText,
    required String selectedTradeHash,
    required Function onSuccess,
    required Function onError,
  }) async {
    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, String>{
          'message': messageText,
          'hash': selectedTradeHash,
        }),
      );

      if (response.statusCode == 200) {
        final messageData = {
          'author': '2minmax_pro',
          'text': messageText,
          'timestamp': Timestamp.now(),
          'type': 'text',
        };

        // Update Firestore with the new message
        await FirebaseFirestore.instance
            .collection('tradeMessages')
            .doc(selectedTradeHash)
            .update({
          'messages': FieldValue.arrayUnion([messageData])
        });

        // Call onSuccess callback
        onSuccess();
      } else {
        onError('Failed to send message: ${response.statusCode}');
      }
    } catch (error) {
      onError('Error sending message: $error');
    }
  }
}
