import 'dart:convert';
import 'package:bdesktop/Manual/Complains/Api/Complainservice.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:sizer/sizer.dart';

class TradeComplains extends StatefulWidget {
  const TradeComplains({Key? key}) : super(key: key);

  @override
  State<TradeComplains> createState() => _TradeComplainsState();
}

class _TradeComplainsState extends State<TradeComplains> {


  Future<void> _restoreTrade() async {
    if (selectedTradeHash == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No trade selected.')),
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Restoring trade...')),
    );

    try {
      print("Hash $selectedTradeHash");

      String resolveMessage =
          await _apiService.resolveComplaint(selectedTradeHash!);

      if (resolveMessage.contains('successfully')) {
        String resolveMessage =
            await _apiService.RemoveComplaint(selectedTradeHash!);

      } else {
    
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to restore trade')),
        );
      }
    } catch (e) {
      setState(() {
        _responseMessage = 'Error restoring trade: $e';
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  final ComplainApiService _apiService = ComplainApiService();
  final TextEditingController _messageController = TextEditingController();
  String _responseMessage = '';
  String? selectedTradeHash;

  // Convert dynamic timestamp to DateTime
  DateTime _convertToDateTime(dynamic timestamp) {
    if (timestamp is Timestamp) {
      return timestamp.toDate();
    } else if (timestamp is int) {
      return DateTime.fromMillisecondsSinceEpoch(timestamp);
    } else {
      return DateTime.now();
    }
  }

  // Format DateTime for display
  String _formatDateTime(DateTime dateTime) {
    return DateFormat.yMMMd().add_jm().format(dateTime);
  }

  // Handle marking trade as complaint using ApiService
  Future<void> _markAsComplain() async {
    if (selectedTradeHash == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No trade selected.')),
      );
      return;
    }

    String resultMessage =
        await _apiService.markAsComplaint(selectedTradeHash!);
    setState(() {
      _responseMessage = resultMessage;
      selectedTradeHash = null; // Reset after marking as complaint
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(resultMessage)),
    );
  }

  // Handle sending message using ApiService
  Future<void> _sendMessage() async {
    if (selectedTradeHash == null) {
      setState(() {
        _responseMessage = 'Select a trade to send a message.';
      });
      return;
    }

    final String messageText = _messageController.text;
    String resultMessage =
        await _apiService.sendMessage(selectedTradeHash!, messageText);

    setState(() {
      _responseMessage = resultMessage;
      if (resultMessage == 'Message sent successfully.') {
        _messageController.clear();
      }
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(resultMessage)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.only(left: 30, right: 30, top: 50),
        child: Row(
          children: [

            Expanded(
              flex: 3,
              child: FutureBuilder<List<DocumentSnapshot>>(
                future: _apiService
                    .fetchComplaints(), // Use ApiService to fetch complaints
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  }

                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return 
                    Padding(
                      padding: const EdgeInsets.only(left: 400),
                      child: Icon(Icons.settings_accessibility,size: 150,color: Colors.blue,),
                    );
                  }

                  return ListView.builder(
                    itemCount: snapshot.data!.length,
                    itemBuilder: (context, index) {
                      final complaint = snapshot.data![index];
                      final complaintData =
                          complaint.data() as Map<String, dynamic>;
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
                              borderRadius: BorderRadius.circular(10),
                              border:
                                  Border.all(width: 0.5, color: Colors.black),
                              color: Colors.white),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('$complaintHash',
                                  style: GoogleFonts.montserrat(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black)),
                              SizedBox(height: 5),
                              Text(
                                '${resolved ? 'Resolved' : 'Unresolved'}',
                                style: TextStyle(
                                    color:
                                        resolved ? Colors.green : Colors.red),
                              ),
                              SizedBox(height: 5),
                              Text(
                                '${_formatDateTime(_convertToDateTime(timestamp))}',
                                style: TextStyle(color: Colors.grey),
                              )
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
            SizedBox(width: 30.w),
            // Messages and Actions
            Expanded(
              flex: 4,
              child: selectedTradeHash == null
                  ? Center(child: Text(''))
                  : Column(
                      children: [
                        // Messages section

                        Align(
                          alignment: Alignment.centerRight,
                          child: GestureDetector(
                            onTap: () {
                              _restoreTrade();
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                  border: Border.all(
                                      width: 0.5, color: Colors.black)),
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                  "Restore Trade",
                                  style: GoogleFonts.montserrat(),
                                ),
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: StreamBuilder<DocumentSnapshot>(
                            stream: FirebaseFirestore.instance
                                .collection('manualmessages')
                                .doc(selectedTradeHash)
                                .snapshots(),
                            builder: (context, snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return Center(
                                    child: CircularProgressIndicator());
                              }
                              if (!snapshot.hasData || !snapshot.data!.exists) {
                                return Center(
                                    child: Text('No messages available'));
                              }

                              final tradeMessages =
                                  snapshot.data!.data() as Map<String, dynamic>;
                              final messages = List<Map<String, dynamic>>.from(
                                  tradeMessages['messages']);

                              return ListView.builder(
                                itemCount: messages.length,
                                itemBuilder: (context, index) {
                                  final message = messages[index];
                                  final messageTime = _formatDateTime(
                                      _convertToDateTime(message['timestamp']));
                                  final messageAuthor = message['author'];
                                  final messageType = message['type'];

                                  final isMine = messageAuthor == '2minmax_pro';

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
                                    messageText = message['text'].toString();
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
                                        borderRadius: BorderRadius.circular(10),
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
                        // Message composer
                        _buildMessageComposer(),
                        SizedBox(height: 10),
                        // Response message
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

  // Message composer widget
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
        FloatingActionButton(
          onPressed: _sendMessage,
          child: Icon(Icons.send),
          mini: true,
        ),
      ],
    );
  }
}
