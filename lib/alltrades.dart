import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;

class AllTrades extends StatefulWidget {
  const AllTrades({Key? key}) : super(key: key);

  @override
  State<AllTrades> createState() => _AllTradesState();
}

class _AllTradesState extends State<AllTrades> {
  final TextEditingController _messageController = TextEditingController();
  String _responseMessage = '';

  String? selectedTradeHash;

  DateTime _convertToDateTime(dynamic timestamp) {
    if (timestamp is Timestamp) {
      return timestamp.toDate();
    } else if (timestamp is int) {
      return DateTime.fromMillisecondsSinceEpoch(timestamp);
    } else {
      return DateTime.now();
    }
  }

  String _formatDateTime(DateTime dateTime) {
    return DateFormat.yMMMd().add_jm().format(dateTime);
  }


  @override
  Widget build(BuildContext context) {

    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);
    final endOfDay = DateTime(now.year, now.month, now.day, 23, 59, 59, 999);

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Expanded(
              flex: 3,
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('trades')
                    .where('timestamp', isGreaterThanOrEqualTo: startOfDay)
                    .where('timestamp', isLessThanOrEqualTo: endOfDay)
                    .orderBy('timestamp', descending: true)
                    .limit(1000) // Limit to the latest 20 trades
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  }
                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return Center(child: Text('No trades available'));
                  }

                  return ListView.builder(
                    itemCount: snapshot.data!.docs.length,
                    itemBuilder: (context, index) {
                      final trade = snapshot.data!.docs[index];
                      final tradeData = trade.data() as Map<String, dynamic>;
                      final tradeHash = tradeData['trade_hash'];
                      final timestamp = tradeData['timestamp'];

                      return InkWell(
                        onTap: () {
                          setState(() {
                            selectedTradeHash = tradeHash;
                          });
                        },
                        child: Container(
                          margin: EdgeInsets.symmetric(vertical: 10),
                          padding: EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Trade: $tradeHash',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 5),
                              Text(
                                ' ${_formatDateTime(_convertToDateTime(timestamp))}',
                                style: TextStyle(color: Colors.grey),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
            SizedBox(width: 20),
            Expanded(
              flex: 4,
              child: selectedTradeHash == null
                  ? Center(child: Text('Select a trade to view messages'))
                  : StreamBuilder<DocumentSnapshot>(
                      stream: FirebaseFirestore.instance
                          .collection('tradeMessages')
                          .doc(selectedTradeHash)
                          .snapshots(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return Center(child: CircularProgressIndicator());
                        }
                        if (!snapshot.hasData || !snapshot.data!.exists) {
                          return Center(child: Text('No messages available'));
                        }

                        final tradeMessages =
                            snapshot.data!.data() as Map<String, dynamic>;
                        final messages = List<Map<String, dynamic>>.from(
                            tradeMessages['messages']);

                        return ListView.builder(
                          itemCount: messages.length,
                          itemBuilder: (context, index) {
                            final message = messages[index];
                            final messageTime =
                                _formatDateTime(_convertToDateTime(message['timestamp']));
                            final messageAuthor = message['author'];
                            final messageType = message['type'];

                            final isMine = messageAuthor == '2minmax_pro';

                            String messageText;

                            if (messageType == 'bank-account-instruction') {
                              final bankAccount =
                                  message['text']['bank_account'];
                              messageText = '''
                                Bank Name: ${bankAccount['bank_name']}
                                Account Number: ${bankAccount['account_number']}
                                Holder Name: ${bankAccount['holder_name']}
                                Amount: ${bankAccount['amount']}
                                Currency: ${bankAccount['currency']}
                              ''';
                            } else {
                              messageText = message['text'].toString();
                            }

                            return Align(
                              alignment: isMine ? Alignment.centerRight : Alignment.centerLeft,
                              child: Container(
                                decoration: BoxDecoration(
                                  color: isMine ? Colors.blue[200] : Colors.grey[200],
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                padding: EdgeInsets.all(10),
                                margin: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      messageText,
                                      style: TextStyle(fontSize: 16),
                                    ),
                                    SizedBox(height: 5),
                                    Text(
                                      messageTime,
                                      style: TextStyle(fontSize: 12, color: Colors.grey),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
