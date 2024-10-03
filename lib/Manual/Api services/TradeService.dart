
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart';

class TradeService {

  Future<void> markTradeAsPaid({
    required String tradeHash,
    required int elapsedTime,
    required String amountPaid,
    required String loggedInStaffID,
    required Function resetSelectedTrade,
  }) async {
    try {
      print("Marking trade with elapsed time >>>>>>>>>>>>> $elapsedTime");

      final response = await http.post(
        Uri.parse('https://b-backend-xe8q.onrender.com/Trade/mark'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'trade_hash': tradeHash,
          'name':loggedInStaffID,
          'markedAt': '$elapsedTime', // Using the elapsed time
          'amountPaid': amountPaid,
        }),
      );

      if (response.statusCode == 200) {
        print("Trade marked as paid successfully: ${response.body}");
        await FirebaseFirestore.instance
            .collection('Allstaff')
            .doc(loggedInStaffID)
            .update({
          'assignedTrades': FieldValue.arrayRemove([tradeHash]),
        });

        // Update the trade document to mark it as paid
        await FirebaseFirestore.instance
            .collection('manualsystem')
            .doc(tradeHash)
            .update({
          'isPaid': true,
        });

        // Reset selected trade in the UI
        resetSelectedTrade();
      } else {
        print('Failed to mark trade as paid: ${response.body}');
      }
    } catch (e) {
      print('Error marking trade as paid: $e');
    }
  }
}
