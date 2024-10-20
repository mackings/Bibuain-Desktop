import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;

class TradeComplains extends StatefulWidget {
  const TradeComplains({Key? key}) : super(key: key);

  @override
  State<TradeComplains> createState() => _TradeComplainsState();
}

class _TradeComplainsState extends State<TradeComplains> {

  
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

  Future<List<DocumentSnapshot>> _fetchComplaints() async {
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);
    final endOfDay = DateTime(now.year, now.month, now.day, 23, 59, 59, 999);

    try {
      final QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('complaints')
          .where('timestamp', isGreaterThanOrEqualTo: startOfDay)
          .where('timestamp', isLessThanOrEqualTo: endOfDay)
          .orderBy('timestamp', descending: true)
          .limit(20) // Limit the complaints
          .get();

      return querySnapshot.docs;
    } catch (e) {
      print('Error fetching complaints: $e');
      return [];
    }
  }



  Future<void> _sendMessage() async {
    if (selectedTradeHash == null) {
      setState(() {
        _responseMessage = 'Select a trade to send a message.';
      });
      return;
    }

    const String apiUrl = 'https://b-backend-xe8q.onrender.com/paxful/send-message';
    final String messageText = _messageController.text;

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, String>{
          'message': messageText,
          'hash': selectedTradeHash.toString(),
        }),
      );

      if (response.statusCode == 200) {
        // Add message to Firestore
        final messageData = {
          'author': '2minmax_pro',
          'text': messageText,
          'timestamp': Timestamp.now(),
          'type': 'text',
        };

        await FirebaseFirestore.instance
            .collection('tradeMessages')
            .doc(selectedTradeHash)
            .update({
          'messages': FieldValue.arrayUnion([messageData])
        });

        setState(() {
          _responseMessage = 'Message sent successfully.';
          _messageController.clear();
        });
      } else {
        setState(() {
          _responseMessage = 'Failed to send message: ${response.statusCode}';
        });
      }
    } catch (error) {
      setState(() {
        _responseMessage = 'Error sending message: $error';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Expanded(
              flex: 3,
              child: FutureBuilder<List<DocumentSnapshot>>(
                future: _fetchComplaints(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  }

                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return Center(child: Text('No complaints available'));
                  }

                  return ListView.builder(
                    itemCount: snapshot.data!.length,
                    itemBuilder: (context, index) {
                      final complaint = snapshot.data![index];
                      final complaintData = complaint.data() as Map<String, dynamic>;
                      final complaintHash = complaintData['trade_hash'];
                      final timestamp = complaintData['timestamp'];
                      final resolved = complaintData['resolved'] ?? false;

                      return InkWell(
                        onTap: () {
                          setState(() {
                            selectedTradeHash = complaintHash;
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
                                'Complaint: $complaintHash',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 5),
                              Text(
                                '${_formatDateTime(_convertToDateTime(timestamp))}',
                                style: TextStyle(color: Colors.grey),
                              ),
                              SizedBox(height: 5),
                              Text(
                                'Status: ${resolved ? 'Resolved' : 'Unresolved'}',
                                style: TextStyle(color: resolved ? Colors.green : Colors.red),
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
                  ? Center(child: Text('Select a complaint to view messages'))
                  : Column(
                      children: [
                        Expanded(
                          child: StreamBuilder<DocumentSnapshot>(
                            stream: FirebaseFirestore.instance
                                .collection('tradeMessages')
                                .doc(selectedTradeHash)
                                .snapshots(),
                            builder: (context, snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return Center(
                                    child: CircularProgressIndicator());
                              }
                              if (!snapshot.hasData ||
                                  !snapshot.data!.exists) {
                                return Center(
                                    child: Text('No messages available'));
                              }

                              final tradeMessages =
                                  snapshot.data!.data() as Map<String, dynamic>;
                              final messages =
                                  List<Map<String, dynamic>>.from(
                                      tradeMessages['messages']);

                              return ListView.builder(
                                itemCount: messages.length,
                                itemBuilder: (context, index) {
                                  final message = messages[index];
                                  final messageTime = _formatDateTime(
                                      _convertToDateTime(message['timestamp']));
                                  final messageAuthor = message['author'];
                                  final messageType = message['type'];

                                  final isMine =
                                      messageAuthor == '2minmax_pro';

                                  String messageText;

                                  if (messageType ==
                                      'bank-account-instruction') {
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
                                    messageText =
                                        message['text'].toString();
                                  }

                                  return Align(
                                    alignment: isMine
                                        ? Alignment.centerRight
                                        : Alignment.centerLeft,
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: isMine
                                            ? Colors.blue[200]
                                            : Colors.grey[200],
                                        borderRadius:
                                            BorderRadius.circular(10),
                                      ),
                                      padding: EdgeInsets.all(10),
                                      margin: EdgeInsets.symmetric(
                                          vertical: 5, horizontal: 10),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            messageText,
                                            style: TextStyle(fontSize: 16),
                                          ),

                                          SizedBox(height: 5),

                                          Text(
                                            messageTime,
                                            style: TextStyle(
                                                fontSize: 12,
                                                color: Colors.grey),
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
                        SizedBox(height: 10),
                        _buildMessageComposer(),
                        SizedBox(height: 10),
                        Text(
                          _responseMessage,
                          style: TextStyle(color: Colors.green),
                        ),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }



  Widget _buildMessageComposer() {
    return Row(
      children: [
        Expanded(
          child: TextFormField(
            controller: _messageController,
            decoration: InputDecoration(
              hintText: 'Type your message...',
              border: OutlineInputBorder(),
            ),
          ),
        ),
        SizedBox(width: 10),
        FloatingActionButton(onPressed: _sendMessage,
        child: Icon(Icons.send),
        mini: true,
        )

      ],
    );
  }
}
