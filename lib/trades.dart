import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:sizer/sizer.dart';

class Trades extends StatefulWidget {
  const Trades({Key? key}) : super(key: key);

  @override
  State<Trades> createState() => _TradesState();
}

class _TradesState extends State<Trades> {
  final TextEditingController _messageController = TextEditingController();
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
    final String messageText = _messageController.text;

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, String>{
          'message': messageText,
          'hash': selectedTradeHash.toString()
        }),
      );

      if (response.statusCode == 200) {
        // Add message to Firestore
        final messageData = {
          'author': '2minmax_pro',
          'text': messageText,
          'timestamp': Timestamp.now(),
          'type': 'text'
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

  Future<void> _MarkPaid() async {
    const String apiUrl = 'https://b-backend-xe8q.onrender.com/paxful/pay';
    final String messageText = _messageController.text;

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body:
            jsonEncode(<String, String>{'hash': selectedTradeHash.toString()}),
      );

      print('Hash for Marking ${selectedTradeHash}');

      if (response.statusCode == 200) {
        print(response.body);
        setState(() {
          _responseMessage = 'Message sent successfully.';
          // _messageController.clear();
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

  List<String> bankNames = [
    "Abbey Mortgage Bank",
    "Above Only MFB",
    "Access Bank",
    "Access Bank (Diamond)",
    "ALAT by WEMA",
    "Amju Unique MFB",
    "ASO Savings and Loans",
    "Bainescredit MFB",
    "Bowen Microfinance Bank",
    "Carbon",
    "CEMCS Microfinance Bank",
    "Citibank Nigeria",
    "Coronation Merchant Bank",
    "Ecobank Nigeria",
    "Ekondo Microfinance Bank",
    "Eyowo",
    "Fidelity Bank",
    "Firmus MFB",
    "First Bank of Nigeria",
    "First City Monument Bank",
    "FSDH Merchant Bank Limited",
    "Globus Bank",
    "GoMoney",
    "Guaranty Trust Bank",
    "Hackman Microfinance Bank",
    "Hasal Microfinance Bank",
    "Heritage Bank",
    "Ibile Microfinance Bank",
    "Infinity MFB",
    "Jaiz Bank",
    "Kadpoly MFB",
    "Keystone Bank",
    "Kredi Money MFB LTD",
    "Kuda Bank",
    "Lagos Building Investment Company Plc.",
    "Links MFB",
    "Lotus Bank",
    "Mayfair MFB",
    "Moniepoint MFB"
        "Mint MFB",
    "Paga",
    "PalmPay",
    "Parallex Bank",
    "Parkway - ReadyCash",
    "Opay",
    "Petra Mircofinance Bank Plc",
    "Polaris Bank",
    "Providus Bank",
    "QuickFund MFB",
    "Rand Merchant Bank",
    "Rubies MFB",
    "Sparkle Microfinance Bank",
    "Stanbic IBTC Bank",
    "Standard Chartered Bank",
    "Sterling Bank",
    "Suntrust Bank",
    "TAJ Bank",
    "Tangerine Money",
    "TCF MFB",
    "Titan Bank",
    "Unical MFB",
    "Union Bank of Nigeria",
    "United Bank For Africa",
    "Unity Bank",
    "VFD Microfinance Bank Limited",
    "Wema Bank",
    "Zenith Bank"
  ];

  String? accumulatedBankName;
  String? accumulatedAccountNumber;
  String? accumulatedAccountHolder;

  Map<String, dynamic>? _checkForBankDetails(
      List<Map<String, dynamic>> messages) {
    for (var message in messages) {
      if (message['type'] != 'bank-account-instruction') {
        String text = message['text'].toString().toLowerCase();
        RegExp numberRegExp = RegExp(r'\b\d{10}\b');
        if (numberRegExp.hasMatch(text)) {
          for (String bankName in bankNames) {
            if (text.contains(bankName.toLowerCase())) {
              print('Bank Name: $bankName');
              print('Account Number: ${numberRegExp.stringMatch(text)}');
              accumulatedBankName = bankName;
              accumulatedAccountNumber = numberRegExp.stringMatch(text);
              return {
                'bank_name': bankName,
                'account_number': numberRegExp.stringMatch(text),
              };
            }
          }
        }

        // Check for amount in the format <b>23,769.68 NGN</b>
        RegExp amountRegExp = RegExp(r'<b>([\d,.]+)\s*(\w+)</b>');
        Match? amountMatch = amountRegExp.firstMatch(text);
        if (amountMatch != null) {
          String amount = amountMatch.group(1)!; // Extract the amount
          String currency = amountMatch.group(2)!; // Extract the currency
          print('Amount: $amount $currency');
          // Return or store the amount and currency as needed
          return {
            'amount': amount,
            'currency': currency,
            // Add other necessary details as per your message structure
          };
        }
      }
    }
    return null;
  }

  Future<void> _markAsComplaint() async {
    if (selectedTradeHash == null) {
      setState(() {
        _responseMessage = 'No trade selected.';
      });
      return;
    }

    try {
      final tradeDoc = await FirebaseFirestore.instance
          .collection('trades')
          .doc(selectedTradeHash)
          .get();

      if (tradeDoc.exists) {
        final tradeData = tradeDoc.data() as Map<String, dynamic>;

        await FirebaseFirestore.instance
            .collection('complaints')
            .doc(selectedTradeHash)
            .set(tradeData);

        await FirebaseFirestore.instance
            .collection('trades')
            .doc(selectedTradeHash)
            .update({'status': 'unresolved'});

        setState(() {
          _responseMessage = 'Trade marked as complaint successfully.';
        });
      } else {
        setState(() {
          _responseMessage = 'Trade not found.';
        });
      }
    } catch (e) {
      setState(() {
        _responseMessage = 'An error occurred: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.only(left: 20, right: 20, top: 40),
        child: Row(
          children: [
            Expanded(
              flex: 4,
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('trades')
                    .orderBy('timestamp', descending: true)
                    .limit(1) // Limit to the latest trade only
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  }
                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return Center(child: Text('No trades available'));
                  }

                  final trade = snapshot.data!.docs.first;
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    _autoSelectLatestTrade([trade]);
                  });

                  final tradeData = trade.data() as Map<String, dynamic>;
                  final tradeHash = tradeData['trade_hash'];

                  return StreamBuilder<DocumentSnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('tradeMessages')
                        .doc(tradeHash)
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Center(child: CircularProgressIndicator());
                      }
                      if (!snapshot.hasData || !snapshot.data!.exists) {
                        return Center(
                            child: Text(
                                'No messages available for the latest trade'));
                      }

                      final tradeMessages =
                          snapshot.data!.data() as Map<String, dynamic>;
                      final messages = List<Map<String, dynamic>>.from(
                          tradeMessages['messages']);

                      final bankAccountMessage = messages.firstWhere(
                        (message) =>
                            message['type'] == 'bank-account-instruction',
                        orElse: () => {},
                      );

                      if (bankAccountMessage.isEmpty) {
                        Map<String, dynamic>? bankDetails =
                            _checkForBankDetails(messages);

                        if (bankDetails != null) {
                          final bankAccountDetails = '''
                            Bank Name: ${bankDetails['bank_name']}
                            Account Number: ${bankDetails['account_number']}
                          ''';

                          return Container(
                            padding: EdgeInsets.all(10),
                            margin: EdgeInsets.symmetric(vertical: 5),
                            decoration: BoxDecoration(
                              color: Colors.grey[200],
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(bankAccountDetails),
                          );
                        } else {
                          return Center(
                              child: Text(
                                  'No bank account instructions available for the latest trade'));
                        }
                      }

                      final bankAccount =
                          bankAccountMessage['text']['bank_account'];
                      final bankAccountDetails = '''
                        Bank Name: ${bankAccount['bank_name']}
                        Account Number: ${bankAccount['account_number']}
                        Holder Name: ${bankAccount['holder_name']}
                        Amount: ${bankAccount['amount']}
                        Currency: ${bankAccount['currency']}
                      ''';

                      final Account_name = bankAccount['holder_name'];
                      final Account_number = bankAccount['account_number'];
                      final Bank_name = bankAccount['bank_name'];
                      final Amount = bankAccount['amount'];

                      return Column(
                        children: [

                          Container(
                            height: 8.h,
                            width: MediaQuery.of(context).size.width-20,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              color: Colors.blue
                            ),
                            child: Column(
                              children: [
                               // Text("Hello")

                              ],
                            ),
                          ),
                          SizedBox(height: 2.h,),
                          Container(
                            decoration: BoxDecoration(
                              border: Border.all(width: 0.5),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            width: MediaQuery.of(context).size.width - 30.w,
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    "Seller's details",
                                    style: GoogleFonts.poppins(
                                        textStyle: TextStyle(
                                            fontSize: 10.sp,
                                            fontWeight: FontWeight.w600)),
                                  ),
                                  SizedBox(height: 2.h),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        "Account Name :",
                                        style: GoogleFonts.poppins(
                                            textStyle: TextStyle(
                                                fontSize: 5.sp,
                                                fontWeight: FontWeight.w600)),
                                      ),
                                      Text(Account_name),
                                    ],
                                  ),
                                  Divider(),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        "Account Number :",
                                        style: GoogleFonts.poppins(
                                            textStyle: TextStyle(
                                                fontSize: 8.sp,
                                                fontWeight: FontWeight.w600)),
                                      ),
                                      Text(
                                        Account_number,
                                        style: GoogleFonts.poppins(
                                            textStyle: TextStyle(
                                                fontSize: 12.sp,
                                                fontWeight: FontWeight.w600)),
                                      ),
                                    ],
                                  ),
                                  Divider(),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        "Bank Name:",
                                        style: GoogleFonts.poppins(
                                            textStyle: TextStyle(
                                                fontSize: 8.sp,
                                                fontWeight: FontWeight.w600)),
                                      ),
                                      Text(
                                        Bank_name,
                                        style: GoogleFonts.poppins(
                                            textStyle: TextStyle(
                                                fontSize: 13.sp,
                                                fontWeight: FontWeight.w600)),
                                      ),
                                    ],
                                  ),
                                  Divider(),
                                  // Text(Amount)
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        "Amount:",
                                        style: GoogleFonts.poppins(
                                            textStyle: TextStyle(
                                                fontSize: 8.sp,
                                                fontWeight: FontWeight.w600)),
                                      ),
                                      Text(
                                        "N${Amount}",
                                        style: GoogleFonts.poppins(
                                            textStyle: TextStyle(
                                                fontSize: 18.sp,
                                                fontWeight: FontWeight.w600)),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                          SizedBox(height: 5.h,),

                          Row(
                            children: [
                              Container(
                                height: 5.h,
                                width: 20.w,
                                child: Center(child: Text("To CC",style: GoogleFonts.poppins(),)),
                                decoration: BoxDecoration(
                                  color: Colors.black,
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                    color: Colors.white
                                  )
                                ),
                              )
                            ],
                          )


                        ],
                      );
                    },
                  );
                },
              ),
            ),
            SizedBox(width: 20),
            Expanded(
              flex: 3,
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
                                return Center(
                                    child: CircularProgressIndicator());
                              }
                              if (!snapshot.hasData || !snapshot.data!.exists) {
                                return Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.chat, size: 40),
                                      Text("No Messages",
                                          style: GoogleFonts.poppins())
                                    ]);
                              }

                              final tradeMessages =
                                  snapshot.data!.data() as Map<String, dynamic>;
                              final messages = List<Map<String, dynamic>>.from(
                                  tradeMessages['messages']);
                              final myUsername = '2minmax_pro';

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

                                  if (messageType ==
                                      'bank-account-instruction') {
                                    final bankAccount =
                                        message['text']['bank_account'];
                                    final Account_name =
                                        bankAccount['holder_name'];
                                    final Account_number =
                                        bankAccount['account_number'];
                                    final Bank_name = bankAccount['bank_name'];
                                    final Amount = bankAccount['amount'];

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
                                //_sendMessage,
                                //_markAsComplaint,
                               // _MarkPaid,
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
                                    ? Colors.transparent
                                    : Colors.transparent,
                              ),
                            ),
                          ),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
