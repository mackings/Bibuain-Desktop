import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart';

class ComplainApiService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final String _sendMessageUrl =
      'https://b-backend-xe8q.onrender.com/paxful/send-message';
  final String _markTradeUrl = 'https://b-backend-xe8q.onrender.com/Trade/mark';
  final String _resolveComplaintUrl =
      'https://b-backend-xe8q.onrender.com/staff/complain/resolve';

  

  Future<String> markAsComplaint(String selectedTradeHash) async {
    try {
      final tradeDoc = await _firestore
          .collection('manualsystem')
          .doc(selectedTradeHash)
          .get();

      if (tradeDoc.exists) {
        final tradeData = tradeDoc.data() as Map<String, dynamic>;
        await _firestore
            .collection('complaints')
            .doc(selectedTradeHash)
            .set(tradeData);
        await _firestore
            .collection('complaints')
            .doc(selectedTradeHash)
            .update({'status': 'unresolved'});

        return 'Trade marked as complaint successfully.';
      } else {
        return 'Trade not found.';
      }
    } catch (e) {
      return 'An error occurred: $e';
    }
  }


Future<String> resolveComplaint(String tradeId) async {

    try {
      final response = await http.post(
        Uri.parse(_resolveComplaintUrl),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8'
        },
        body: jsonEncode({
          'tradeId': tradeId,
        }),
      );

      if (response.statusCode == 200) {
        print("Complaint resolved successfully for tradeId: $tradeId.");
        return 'Complaint resolved successfully for tradeId: $tradeId.';
      } else {
        return 'Failed to resolve complaint: ${response.statusCode}.';
      }
    } catch (e) {
      return 'Error resolving complaint: $e';
    }
  }


  Future<String> RemoveComplaint(String selectedTradeHash) async {
    try {
      final complaintDoc = await _firestore
          .collection('complaints')
          .doc(selectedTradeHash)
          .get();

      if (complaintDoc.exists) {
        final complaintData = complaintDoc.data() as Map<String, dynamic>;

        // Mark the complaint as resolved
        await _firestore
            .collection('complaints')
            .doc(selectedTradeHash)
            .update({
          'status': 'resolved',
          'resolvedAt': FieldValue.serverTimestamp(),
        });

        // Immediately delete the complaint after marking it as resolved
        await _firestore
            .collection('complaints')
            .doc(selectedTradeHash)
            .delete();

        return 'Complaint marked as resolved and deleted successfully.';
      } else {
        return 'Complaint not found.';
      }
    } catch (e) {
      return 'An error occurred: $e';
    }
  }

  // Send message to API and Firestore
  Future<String> sendMessage(
      String selectedTradeHash, String messageText) async {
    try {
      final response = await http.post(
        Uri.parse(_sendMessageUrl),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8'
        },
        body: jsonEncode({'message': messageText, 'hash': selectedTradeHash}),
      );

      if (response.statusCode == 200) {
        final messageData = {
          'author': '2minmax_pro',
          'text': messageText,
          'timestamp': Timestamp.now(),
          'type': 'text',
        };

        await _firestore
            .collection('tradeMessages')
            .doc(selectedTradeHash)
            .update({
          'messages': FieldValue.arrayUnion([messageData])
        });

        return 'Message sent successfully.';
      } else {
        return 'Failed to send message: ${response.statusCode}';
      }
    } catch (error) {
      return 'Error sending message: $error';
    }
  }


  Future<List<DocumentSnapshot>> fetchComplaints() async {
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);
    final endOfDay = DateTime(now.year, now.month, now.day, 23, 59, 59, 999);

    try {
      final QuerySnapshot querySnapshot = await _firestore
          .collection('complaints')
          .where('timestamp', isGreaterThanOrEqualTo: startOfDay)
          .where('timestamp', isLessThanOrEqualTo: endOfDay)
          .orderBy('timestamp', descending: true)
          .limit(20)
          .get();

      return querySnapshot.docs;
    } catch (e) {
      print('Error fetching complaints: $e');
      return [];
    }
  }

}
