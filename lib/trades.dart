import 'dart:convert';
import 'package:bdesktop/widgets/paid.dart';
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

  String formatNaira(dynamic amount) {
    double parsedAmount;

    // Check if the input is already a double, if not, try to parse it
    if (amount is double) {
      parsedAmount = amount;
    } else if (amount is String) {
      parsedAmount = double.tryParse(amount) ?? 0.0;
    } else {
      throw ArgumentError(
          'Input should be a double or a string representing a number');
    }

    // Convert the amount to a string with commas as thousand separators
    String formattedAmount = parsedAmount.toStringAsFixed(2).replaceAllMapped(
          RegExp(r'\B(?=(\d{3})+(?!\d))'),
          (Match match) => ',',
        );
    return '₦$formattedAmount';
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

  Future<void> _VerifyAccount() async {
    const String apiUrl =
        'https://nubapi.com/verify?account_number={3121613812}&bank_code={011}';
    final String messageText = _messageController.text;

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
      );
      if (response.statusCode == 200) {
        print(response.body);
      } else {
        print(response.body);
      }
    } catch (error) {
      print(error);
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

        // Match "You must pay <b>100,000 NGN</b>" format
        RegExp amountRegExp1 = RegExp(r'you must pay <b>([\d,.]+)\s*(\w+)</b>');
        Match? amountMatch1 = amountRegExp1.firstMatch(text);
        if (amountMatch1 != null) {
          String amount = amountMatch1.group(1)!; // Extract the amount
          String currency = amountMatch1.group(2)!; // Extract the currency
          print('Amount: $amount $currency');
          return {
            'amount': amount,
            'currency': currency,
          };
        }

        // Match "(137,518.2 NGN) is now in escrow." format
        RegExp amountRegExp2 =
            RegExp(r'\(([\d,.]+)\s*(\w+)\) is now in escrow');
        Match? amountMatch2 = amountRegExp2.firstMatch(text);
        if (amountMatch2 != null) {
          String amount = amountMatch2.group(1)!; // Extract the amount
          String currency = amountMatch2.group(2)!; // Extract the currency
          print('Amount in escrow: $amount $currency');
          return {
            'amount_in_escrow': amount,
            'currency': currency,
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
                          final bankName = bankDetails['bank_name'] ?? '';
                          final accountNumber =
                              bankDetails['account_number'] ?? '';
                          final amount = bankDetails['amount'] ?? '';
                          final currency = bankDetails['currency'] ?? '';

                          return Container(
                            decoration: BoxDecoration(
                              border: Border.all(width: 0.5),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            width: MediaQuery.of(context).size.width - 30,
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
                                      Text(
                                        accumulatedAccountHolder ?? 'N/A',
                                        style: GoogleFonts.poppins(
                                            textStyle: TextStyle(
                                                fontSize: 5.sp,
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
                                        "Account Number :",
                                        style: GoogleFonts.poppins(
                                            textStyle: TextStyle(
                                                fontSize: 8.sp,
                                                fontWeight: FontWeight.w600)),
                                      ),
                                      Text(
                                        accountNumber,
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
                                        bankName,
                                        style: GoogleFonts.poppins(
                                            textStyle: TextStyle(
                                                fontSize: 13.sp,
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
                                        "Amount:",
                                        style: GoogleFonts.poppins(
                                            textStyle: TextStyle(
                                                fontSize: 8.sp,
                                                fontWeight: FontWeight.w600)),
                                      ),
                                      Text(
                                        "$currency $amount",
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
                          );
                        }
                      }

//Shared Account

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
                            width: MediaQuery.of(context).size.width - 20,
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                color: Colors.blue),
                            child: Column(
                              children: [],
                            ),
                          ),
                          SizedBox(
                            height: 3.h,
                          ),
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
                                                fontWeight: FontWeight.w700)),
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
                                        "${formatNaira(Amount).toString()}",
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
                          SizedBox(
                            height: 5.h,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                height: 4.h,
                                width: 30.w,
                                child: Center(
                                    child: Text(
                                  "To CC",
                                  style:
                                      GoogleFonts.poppins(color: Colors.white),
                                )),
                                decoration: BoxDecoration(
                                    color: Colors.black,
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(color: Colors.white)),
                              ),
                              GestureDetector(
                                onTap: () {
                                  showDialog(
                                      context: context,
                                      builder: (context) {
                                        return ConfirmPayDialog(onConfirm: () {
                                          _MarkPaid();
                                          Navigator.pop(context);
                                        }, onCancel: () {
                                          Navigator.pop(context);
                                        });
                                      });
                                },
                                child: Container(
                                  height: 4.h,
                                  width: 30.w,
                                  child: Center(
                                      child: Text(
                                    "Mark Paid",
                                    style: GoogleFonts.poppins(
                                        color: Colors.black),
                                  )),
                                  decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(color: Colors.black)),
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
                                      GestureDetector(
                                          onTap: () {
                                            _VerifyAccount();
                                          },
                                          child: Icon(Icons.chat, size: 40)),
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
                                            ? Colors.blue[400]
                                            : Colors.grey[300],
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
                                          Text(messageText,
                                              style: GoogleFonts.poppins()),
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
