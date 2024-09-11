import 'dart:convert';

import 'package:bdesktop/widgets/Timers/class.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class TradeCountdownWidget extends StatefulWidget {
  final String tradeHash;
  final int duration; // Duration from Firestore

  TradeCountdownWidget({required this.tradeHash, required this.duration});

  @override
  _TradeCountdownWidgetState createState() => _TradeCountdownWidgetState();
}

class _TradeCountdownWidgetState extends State<TradeCountdownWidget> {
  CountdownTimerService? _countdownTimer;
  int _remainingTime = 0;

  @override
  void initState() {
    super.initState();
    _countdownTimer = CountdownTimerService(
      duration: widget.duration,
      onComplete: _onTimerComplete,
    );
    _countdownTimer!.start();
  }

  void _onTimerComplete() {
    // Handle timer completion logic here
    // E.g., Mark the trade as paid
    _markTradeAsPaid();
  }

  void _markTradeAsPaid() async {
    // Your API call to mark trade as paid
    try {
      final response = await http.post(
        Uri.parse('https://tester-1wva.onrender.com/trade/mark'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'trade_hash': widget.tradeHash,
          'markedAt': 'Automatic',
          'amountPaid': 'Amount to be paid',
        }),
      );

      if (response.statusCode == 200) {
        // Handle successful mark as paid
      } else {
        print('Failed to mark trade as paid: ${response.body}');
      }
    } catch (e) {
      print('Error making API call: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Text(
        'Time Remaining: ${_countdownTimer!.remainingTime} seconds',
        style: TextStyle(fontSize: 16),
      ),
    );
  }

  @override
  void dispose() {
    _countdownTimer?.reset(widget.duration);
    super.dispose();
  }
}
