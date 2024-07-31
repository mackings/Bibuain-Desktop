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

  String formatNairas(dynamic newamount) {
    double parsedAmount;

    // Check if the input is already a double, if not, try to parse it
    if (newamount is double) {
      parsedAmount = newamount;
    } else if (newamount is String) {
      parsedAmount = double.tryParse(newamount) ?? 0.0;
    } else {
      throw ArgumentError(
          'Input should be a double or a string representing a number');
    }

    // Convert the amount to a string with commas as thousand separators
    String formattednewAmount =
        parsedAmount.toStringAsFixed(2).replaceAllMapped(
              RegExp(r'\B(?=(\d{3})+(?!\d))'),
              (Match match) => ',',
            );
    return '₦$formattednewAmount';
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

Map<String, String> bankCodes = {
  "Abbey Mortgage Bank": "801",
  "Above Only MFB": "51226",
  "Access Bank": "044",
  "Access Bank (Diamond)": "063",
  "ALAT by WEMA": "035A",
  "Amju Unique MFB": "50926",
  "ASO Savings and Loans": "401",
  "Bainescredit MFB": "51229",
  "Bowen Microfinance Bank": "50931",
  "Carbon": "565",
  "CEMCS Microfinance Bank": "50823",
  "Citibank Nigeria": "023",
  "Coronation Merchant Bank": "559",
  "Ecobank Nigeria": "050",
  "Ekondo Microfinance Bank": "562",
  "Eyowo": "50126",
  "Fidelity Bank": "070",
  "Firmus MFB": "51314",
  "First Bank of Nigeria": "011",
  "First City Monument Bank": "214",
  "FSDH Merchant Bank Limited": "501",
  "Globus Bank": "00103",
  "GoMoney": "100022",
  "Guaranty Trust Bank": "058",
  "Hackman Microfinance Bank": "51233",
  "Hasal Microfinance Bank": "50383",
  "Heritage Bank": "030",
  "Ibile Microfinance Bank": "51244",
  "Infinity MFB": "50457",
  "Jaiz Bank": "301",
  "Kadpoly MFB": "50502",
  "Keystone Bank": "082",
  "Kredi Money MFB LTD": "50211",
  "Kuda Bank": "50211",
  "Lagos Building Investment Company Plc.": "90052",
  "Links MFB": "50549",
  "Lotus Bank": "303",
  "Mayfair MFB": "50563",
  "Moniepoint MFB": "50515",
  "Mint MFB": "50212",
  "Paga": "100002",
  "PalmPay": "999991",
  "Parallex Bank": "526",
  "Parkway - ReadyCash": "311",
  "Opay": "100004",
  "Petra Microfinance Bank Plc": "50746",
  "Polaris Bank": "076",
  "Providus Bank": "101",
  "QuickFund MFB": "51268",
  "Rand Merchant Bank": "502",
  "Rubies MFB": "51318",
  "Sparkle Microfinance Bank": "51320",
  "Stanbic IBTC Bank": "221",
  "Standard Chartered Bank": "068",
  "Sterling Bank": "232",
  "Suntrust Bank": "100",
  "TAJ Bank": "302",
  "Tangerine Money": "51269",
  "TCF MFB": "51211",
  "Titan Bank": "102",
  "Unical MFB": "50855",
  "Union Bank of Nigeria": "032",
  "United Bank For Africa": "033",
  "Unity Bank": "215",
  "VFD Microfinance Bank Limited": "566",
  "Wema Bank": "035",
  "Zenith Bank": "057"
};


  String? accumulatedBankName;
  String? accumulatedAccountNumber;
  String? accumulatedAccountHolder;

  String? recentAccountNumber;
String? recentPersonName;
String? recentBankName;


Map<String, dynamic>? _checkForBankDetails(List<Map<String, dynamic>> messages) {
  for (var message in messages) {
    final text = message['text'];
    if (text != null && text is Map<String, dynamic>) {
      final bankAccount = text['bank_account'];
      if (bankAccount != null && bankAccount is Map<String, dynamic>) {
        final accountNumber = bankAccount['account_number'];
        final bankName = bankAccount['bank_name'];
        final holderName = bankAccount['holder_name'];
        
        if (accountNumber != null && bankName != null && holderName != null) {
          return {
            'account_number': accountNumber,
            'bank_name': bankName,
            'holder_name': holderName,
          };
        }
      }
    }
  }

  return null;
}


  dynamic fiatAmount;

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
        .limit(1) // Limit to the latest trade onlys
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
      final tradeHash = tradeData['trade_hash'] ?? 'N/A';
      final newamount = tradeData['fiat_amount_requested'] ?? 'N/A';
      final currency = tradeData['fiat_currency_code'] ?? 'N/A';

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
                child: Text('No messages available for the latest trade'));
          }

          final tradeMessages = snapshot.data!.data() as Map<String, dynamic> ?? {};
          final messages = List<Map<String, dynamic>>.from(tradeMessages['messages'] ?? []);

          Map<String, dynamic>? bankDetails = _checkForBankDetails(messages);

          if (bankDetails != null) {
            final bankName = bankDetails['bank_name'] ?? 'N/A';
            final accountNumber = bankDetails['account_number'] ?? 'N/A';
            final accumulatedAccountHolder = bankDetails['holder_name'] ?? 'N/A';

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
                  width: MediaQuery.of(context).size.width - 30,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Seller's Details",
                          style: GoogleFonts.poppins(
                              textStyle: TextStyle(
                                  fontSize: 10.sp,
                                  fontWeight: FontWeight.w600)),
                        ),
                        SizedBox(height: 2.h),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Account Name :",
                              style: GoogleFonts.poppins(
                                  textStyle: TextStyle(
                                      fontSize: 5.sp,
                                      fontWeight: FontWeight.w600)),
                            ),
                            Text(
                              accumulatedAccountHolder,
                              style: GoogleFonts.poppins(
                                  textStyle: TextStyle(
                                      fontSize: 5.sp,
                                      fontWeight: FontWeight.w600)),
                            ),
                          ],
                        ),
                        Divider(),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Amount:",
                              style: GoogleFonts.poppins(
                                  textStyle: TextStyle(
                                      fontSize: 8.sp,
                                      fontWeight: FontWeight.w600)),
                            ),
                            Text(
                              "${formatNairas(newamount)}",
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
                  height: 7.h,
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
                        style: GoogleFonts.poppins(color: Colors.white),
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
                          style: GoogleFonts.poppins(color: Colors.black),
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
          }

          return Center(child: Text('No bank account details found'));
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
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
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
                          Text("No Messages", style: GoogleFonts.poppins())
                        ]);
                  }

                  final tradeMessages =
                      snapshot.data!.data() as Map<String, dynamic>;
                  final messages = List<Map<String, dynamic>>.from(
                      tradeMessages['messages'] ?? []);
                  final myUsername = '2minmax_pro';
                  print(tradeMessages);

                  return ListView.builder(
                    itemCount: messages.length,
                    itemBuilder: (context, index) {
                      final message = messages[index];
                      final messageTime = _formatDateTime(
                          _convertToDateTime(message['timestamp']));
                      final messageAuthor = message['author'];
                      final messageType = message['type'];

                      final isMine = messageAuthor == myUsername;

                      String messageText = message['text'].toString();

                      // Regex to find 10-digit account number
                      final accountNumberRegex = RegExp(r'\b\d{10}\b');
                      final accountNumberMatch = accountNumberRegex.firstMatch(messageText);

                      // Regex to find names in the format "First Last"
                      final nameRegex = RegExp(r'\b[A-Z][a-z]+\s[A-Z][a-z]+\b');
                      final nameMatch = nameRegex.firstMatch(messageText);

                      // Find the bank name from the bankCodes map
                      String? bankNameMatch;
                      for (var bankName in bankCodes.keys) {
                        if (messageText.toLowerCase().contains(bankName.toLowerCase())) {
                          bankNameMatch = bankName;
                          break;
                        }
                      }

                      if (accountNumberMatch != null) {
                        recentAccountNumber = accountNumberMatch.group(0)!;
                      }
                      if (nameMatch != null) {
                        recentPersonName = nameMatch.group(0)!;
                      }
                      if (bankNameMatch != null) {
                        recentBankName = bankNameMatch;
                      }

                      // Print the captured details if available
                      if (recentAccountNumber != null &&
                          recentPersonName != null &&
                          recentBankName != null) {
                        final bankCode = bankCodes[recentBankName] ?? 'Unknown Code';
                        print('Account Number: $recentAccountNumber');
                        print('Person Name: $recentPersonName');
                        print('Bank Name: $recentBankName');
                        print('Bank Code: $bankCode');
                        // Clear recent details after printing
                        recentAccountNumber = null;
                        recentPersonName = null;
                        recentBankName = null;
                      }

                      return Align(
                        alignment: isMine
                            ? Alignment.centerRight
                            : Alignment.centerLeft,
                        child: Container(
                          decoration: BoxDecoration(
                            color: isMine ? Colors.blue[400] : Colors.grey[300],
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
                              Text(messageText, style: GoogleFonts.poppins()),
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
      ),
    );
  }
}
