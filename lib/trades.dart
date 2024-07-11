import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;

class Trades extends StatefulWidget {
  const Trades({Key? key}) : super(key: key);

  @override
  State<Trades> createState() => _TradesState();
}

class _TradesState extends State<Trades> {
  final TextEditingController _messageController = TextEditingController();
  final TextEditingController _hashController = TextEditingController();
  String _responseMessage = '';

  String? selectedTradeHash;
  String? lastTradeHash;

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

  void _autoSelectLatestTrade(List<DocumentSnapshot> trades) {
    final latestTradeHash =
        trades.isNotEmpty ? trades.first.get('trade_hash') : null;
    if (latestTradeHash != lastTradeHash) {
      setState(() {
        selectedTradeHash = latestTradeHash;
        lastTradeHash = latestTradeHash;
      });
    }
  }

  Future<void> _sendMessage() async {
    const String apiUrl =
        'https://b-backend-xe8q.onrender.com/paxful/send-message';
    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, String>{
          'message': _messageController.text,
          'hash': selectedTradeHash.toString()
        }),
      );

      if (response.statusCode == 200) {
        setState(() {
          _responseMessage = 'Message sent successfully.';
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
      appBar: AppBar(
        title: Text('Trades'),
      ),
      body: Row(
        children: [
          Expanded(
            flex: 1,
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('trades')
                  .orderBy('timestamp', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(child: Text('No trades available'));
                }

                final trades = snapshot.data!.docs;
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  _autoSelectLatestTrade(trades);
                });

                return ListView.builder(
                  itemCount: trades.length,
                  itemBuilder: (context, index) {
                    final trade = trades[index].data() as Map<String, dynamic>;
                    final tradeHash = trade['trade_hash'];
                    final tradeTime =
                        _convertToDateTime(trade['timestamp']).toString();

                    return ListTile(
                      title: Text('Trade Hash: $tradeHash'),
                      subtitle: Text('Time: $tradeTime'),
                      selected: selectedTradeHash == tradeHash,
                      onTap: () {
                        setState(() {
                          selectedTradeHash = tradeHash;
                        });
                      },
                    );
                  },
                );
              },
            ),
          ),

          VerticalDivider(),

          Expanded(
            flex: 2,
            child: selectedTradeHash == null
                ? Center(child: Text('No trade selected'))
                : Column(
                    children: [
                      Expanded(
                        child: StreamBuilder<DocumentSnapshot>(
                          key: ValueKey(selectedTradeHash),
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
                              // Show some trade data if no messages are found
                              return FutureBuilder<DocumentSnapshot>(
                                future: FirebaseFirestore.instance
                                    .collection('trades')
                                    .doc(selectedTradeHash)
                                    .get(),
                                builder: (context, tradeSnapshot) {
                                  if (tradeSnapshot.connectionState ==
                                      ConnectionState.waiting) {
                                    return Center(
                                        child: CircularProgressIndicator());
                                  }
                                  if (!tradeSnapshot.hasData ||
                                      !tradeSnapshot.data!.exists) {
                                    return Center(
                                        child: Text('No trade data available'));
                                  }

                                  final tradeData = tradeSnapshot.data!.data()
                                      as Map<String, dynamic>;
                                  print(tradeData); // Debugging line
                                  final bankAccounts = tradeData['bank_accounts'];
                                  if (bankAccounts != null && bankAccounts.isNotEmpty) {
                                    final tradeDetails = '''
                                      Name: ${bankAccounts['to']['holder_name']}
                                      Account Number: ${bankAccounts['to']['account_number']}
                                      Time: ${_formatDateTime(_convertToDateTime(tradeData['timestamp']))}
                                      Bank Name: ${bankAccounts['to']['bank_name']}
                                      Trade Hash: ${tradeData['trade_hash']}
                                    ''';
                                    return Center(child: Text(tradeDetails));
                                  } else {
                                    return Center(child: Text('No bank account details available\nRequest for an Account Number.'));
                                  }
                                },
                              );
                            }

                            final tradeMessages =
                                snapshot.data!.data() as Map<String, dynamic>;
                            final messages = List<Map<String, dynamic>>.from(
                                tradeMessages['messages']);
                            final myUsername =
                                '2minmax_pro';

                            return ListView.builder(
                              itemCount: messages.length,
                              itemBuilder: (context, index) {
                                final message = messages[index];
                                final messageTime = _formatDateTime(
                                    _convertToDateTime(message['timestamp']));
                                final messageAuthor = message['author'];
                                final messageType = message['type'];

                                final isMine = messageAuthor == myUsername;

                                String messageText;

                                if (messageType == 'bank-account-instruction') {
                                  final bankAccount =
                                      message['text']['bank_account'];
                                  messageText = '''
                                    Bank Name: ${bankAccount['bank_name']}
                                    Account Number: ${bankAccount['account_number'].toString()}
                                    Holder Name: ${bankAccount['holder_name']}
                                    Amount: ${bankAccount['amount'].toString()}
                                    Currency: ${bankAccount['currency'].toString()}
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
                                      crossAxisAlignment: isMine
                                          ? CrossAxisAlignment.end
                                          : CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          messageText,
                                          style: TextStyle(fontSize: 16),
                                        ),
                                        SizedBox(height: 5),
                                        Text(
                                          messageTime,
                                          style: TextStyle(
                                              fontSize: 12, color: Colors.grey),
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
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Row(
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
                              mini: true,
                              onPressed: _sendMessage,
                              child: Icon(Icons.send),
                            ),
                          ],
                        ),
                      ),
                      if (_responseMessage.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            _responseMessage,
                            style: TextStyle(
                              color: _responseMessage.startsWith('Failed')
                                  ? Colors.red
                                  : Colors.green,
                            ),
                          ),
                        ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}
