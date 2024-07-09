import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class Trades extends StatefulWidget {
  const Trades({Key? key}) : super(key: key);

  @override
  State<Trades> createState() => _TradesState();
}

class _TradesState extends State<Trades> {
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

  void _autoSelectLatestTrade(List<DocumentSnapshot> trades) {
    final latestTradeHash = trades.isNotEmpty ? trades.first.get('trade_hash') : null;
    if (latestTradeHash != lastTradeHash) {
      setState(() {
        selectedTradeHash = latestTradeHash;
        lastTradeHash = latestTradeHash;
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
                    final tradeTime = _convertToDateTime(trade['timestamp']).toString();

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
      : StreamBuilder<DocumentSnapshot>(
          key: ValueKey(selectedTradeHash),
          stream: FirebaseFirestore.instance
              .collection('tradeMessages')
              .doc(selectedTradeHash)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            }
            if (!snapshot.hasData || !snapshot.data!.exists) {
              return Center(child: Text('No messages available'));
            }

            final tradeMessages = snapshot.data!.data() as Map<String, dynamic>;
            final messages = List<Map<String, dynamic>>.from(tradeMessages['messages']);
            final myUsername = '2minmax_pro'; // Replace this with the actual username

            return ListView.builder(
              itemCount: messages.length,
              itemBuilder: (context, index) {
                final message = messages[index];
                final messageTime = _convertToDateTime(message['timestamp']).toString();
                final messageAuthor = message['author'];
                final messageType = message['type'];

                final isMine = messageAuthor == myUsername;

                String messageText;

                if (messageType == 'bank-account-instruction') {
                  final bankAccount = message['text']['bank_account'];
                  messageText = '''
                  Bank Name: ${bankAccount['bank_name']}
                  Account Number: ${bankAccount['account_number']}
                  Holder Name: ${bankAccount['holder_name']}
                  Amount: ${bankAccount['amount']}
                  Currency: ${bankAccount['currency']}
                  ''';
                } else {
                  messageText = message['text'];
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
                      crossAxisAlignment: isMine ? CrossAxisAlignment.end : CrossAxisAlignment.start,
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
    );
  }
}
