import 'dart:async';
import 'dart:convert';
import 'package:audioplayers/audioplayers.dart';
import 'package:bdesktop/widgets/paid.dart';
import 'package:circular_countdown_timer/circular_countdown_timer.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:sizer/sizer.dart';

class Payers extends StatefulWidget {
  final String username;

  const Payers({Key? key, required this.username}) : super(key: key);

  @override
  State<Payers> createState() => _PayersState();
}

class _PayersState extends State<Payers> {
  final TextEditingController _messageController = TextEditingController();
  String _responseMessage = '';

  String? selectedTradeHash;
  String? lastTradeHash;
  String? accumulatedBankName;
  String? accumulatedAccountNumber;
  String? accumulatedAccountHolder;

  String? recentAccountNumber;
  String? recentPersonName;
  String? recentBankName;
  String? recentBankCode;

  String? recentAccountNumber1;
  String? recentPersonName1;
  String? recentBankName1;
  dynamic fiatAmount;

  late String loggedInStaffID;

  bool isVerified = false;
  Set<String> verifiedAccounts = {};

  Map<String, String> bankCodes = {
    "Abbey Mortgage Bank": "801",
    "Above Only MFB": "51226",
    "Access Bank": "044",
    "Access": "044",
    "Access Bank (Diamond)": "063",
    "ALAT by WEMA": "035A",
    "Amju Unique MFB": "50926",
    "ASO Savings and Loans": "401",
    "Bainescredit MFB": "51229",
    "Bowen Microfinance Bank": "50931",
    "Carbon": "565",
    "Chipper cash": "120001",
    "9 payment service": "120001",
    "CEMCS Microfinance Bank": "50823",
    "Citibank Nigeria": "023",
    "Coronation Merchant Bank": "559",
    "Ecobank Nigeria": "050",
    "Ekondo Microfinance Bank": "562",
    "Eyowo": "50126",
    "Fidelity Bank": "070",
    "Firmus MFB": "51314",
    "First Bank of Nigeria": "011",
    "First Bank": "011",
    "First City Monument Bank": "214",
    "FCMB": "214",
    "FSDH Merchant Bank Limited": "501",
    "Globus Bank": "00103",
    "GoMoney": "100022",
    "Guaranty Trust Bank": "058",
    "GT Bank": "058",
    "GT": "058",
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
    "Kuda": "50211",
    "Lagos Building Investment Company Plc.": "90052",
    "Links MFB": "50549",
    "Lotus Bank": "303",
    "Mayfair MFB": "50563",
    "Moniepoint MFB": "50515",
    "Moniepoint": "50515",
    "Monie point": "50515",
    "Moni point": "50515",
    "Mint MFB": "50212",
    "Paga": "100002",
    "PalmPay": "999991",
    "Palm Pay": "999991",
    "Parallex Bank": "526",
    "Parkway - ReadyCash": "311",
    "Opay": "999992",
    "Petra Microfinance Bank Plc": "50746",
    "Polaris Bank": "076",
    "Providus Bank": "101",
    "QuickFund MFB": "51268",
    "Rand Merchant Bank": "502",
    "Rubies MFB": "51318",
    "Sparkle Microfinance Bank": "51320",
    "Stanbic IBTC Bank": "221",
    "Stanbic IBTC": "221",
    "Standard Chartered Bank": "068",
    "Sterling Bank": "232",
    "Suntrust Bank": "100",
    "TAJ Bank": "302",
    "Tangerine Money": "51269",
    "TCF MFB": "51211",
    "Titan Bank": "102",
    "Unical MFB": "50855",
    "Union Bank of Nigeria": "032",
    "Union Bank": "032",
    "United Bank For Africa": "033",
    "UBA": "033",
    "Unity Bank": "215",
    "VFD Microfinance Bank Limited": "566",
    "VFD": "566",
    "Wema Bank": "035",
    "Zenith Bank": "057",
    "Zenith": "057"
  };

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
    if (amount is double) {
      parsedAmount = amount;
    } else if (amount is String) {
      parsedAmount = double.tryParse(amount) ?? 0.0;
    } else {
      throw ArgumentError(
          'Input should be a double or a string representing a number');
    }

    String formattedAmount = parsedAmount.toStringAsFixed(2).replaceAllMapped(
          RegExp(r'\B(?=(\d{3})+(?!\d))'),
          (Match match) => ',',
        );
    return '₦$formattedAmount';
  }

  String formatNairas(dynamic newamount) {
    double parsedAmount;
    if (newamount is double) {
      parsedAmount = newamount;
    } else if (newamount is String) {
      parsedAmount = double.tryParse(newamount) ?? 0.0;
    } else {
      throw ArgumentError(
          'Input should be a double or a string representing a number');
    }

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

  // void _autoSelectLatestTrade(List<DocumentSnapshot> trades) {
  //   final latestTradeHash =
  //       trades.isNotEmpty ? trades.first.get('trade_hash') : null;
  //   if (latestTradeHash != lastTradeHash) {
  //     setState(() {
  //       selectedTradeHash = latestTradeHash;
  //       lastTradeHash = latestTradeHash;
  //     });
  //   }
  // }

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
        print(response.body);
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

  Future<void> _verifyAccount(BuildContext context) async {
    // Check if this account was already verified
    if (verifiedAccounts.contains(recentAccountNumber)) {
      print('Account $recentAccountNumber already verified');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Account $recentAccountNumber is already verified.',
            style: GoogleFonts.poppins(),
          ),
          duration: Duration(seconds: 5),
        ),
      );
      return;
    }

    final url = Uri.parse(
        'https://server-eight-beige.vercel.app/api/wallet/generateBankDetails/$recentAccountNumber/$recentBankCode');

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final accountName = data['data']['account_name'];
        print('Verified >>> : $data');
        print(">>>>${verifiedAccounts}<<<<<<<");

        // Show SnackBar with the account name
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '$accountName',
              style: GoogleFonts.poppins(),
            ),
            duration: Duration(seconds: 5),
          ),
        );

        setState(() {
          isVerified = true;
          verifiedAccounts
              .add(recentAccountNumber!); // Add account to verified set
        });
      } else {
        setState(() {
          isVerified = false;
        });

        print('Error: ${response.statusCode}');
      }
    } catch (e) {
      setState(() {
        isVerified = false;
      });

      print('Error: $e');
    }
  }

  Map<String, dynamic>? _checkForBankDetails(
      List<Map<String, dynamic>> messages) {
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

  void _processMessages(List<Map<String, dynamic>> messages) {
    String? newAccountNumber;
    String? newPersonName;
    String? newBankName;
    String? newBankCode;

    for (var message in messages) {
      final messageText = message['text'].toString();

      // Regex to find 10-digit account number
      final accountNumberRegex = RegExp(r'\b\d{10}\b');
      final accountNumberMatch = accountNumberRegex.firstMatch(messageText);

      // Regex to find names in the format "First Last" or just a single name
      final nameRegex = RegExp(r'\b[A-Z][a-z]*\b(?:\s\b[A-Z][a-z]*\b)?');
      final nameMatch = nameRegex.firstMatch(messageText);

      // Find the bank name from the bankCodes map
      String? bankNameMatch;
      for (var bankName in bankCodes.keys) {
        if (messageText.toLowerCase().contains(bankName.toLowerCase())) {
          bankNameMatch = bankName;
          newBankCode = bankCodes[bankName];
          break;
        }
      }

      if (accountNumberMatch != null) {
        newAccountNumber = accountNumberMatch.group(0);
      }
      if (nameMatch != null) {
        newPersonName = nameMatch.group(0);
      }
      if (bankNameMatch != null) {
        newBankName = bankNameMatch;
      }
    }

    if (newAccountNumber != recentAccountNumber ||
        newPersonName != recentPersonName ||
        newBankName != recentBankName ||
        newBankCode != recentBankCode) {
      setState(() {
        recentAccountNumber = newAccountNumber;
        recentPersonName = newPersonName;
        recentBankName = newBankName;
        recentBankCode = newBankCode;

        print("Name: >> $recentPersonName");
        print('Account Nos: >>> $recentAccountNumber');
        print('Bank: >>>> $recentBankName');
        print('Bank Code: >>>> $recentBankCode');

        _verifyAccount(context);
      });
    }
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

  Future<void> _markTradeAsPaid(BuildContext context, String username) async {
    if (countdownStartTime == null) {
      print("Countdown has not started yet!");
      return;
    }

    DateTime tradePaidTime = DateTime.now();
    Duration timeTaken = tradePaidTime.difference(countdownStartTime!);
    print(">>>>>> PAID AFTER : ${timeTaken.inSeconds} seconds");

    try {
      final response = await http.post(
        Uri.parse('https://tester-1wva.onrender.com/trade/mark'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'trade_hash': selectedTradeHash,
          'markedAt': '${timeTaken.inSeconds}'
        }),
      );

      if (response.statusCode == 200) {
        print(">>>>> Marked ${response.body}");

        await FirebaseFirestore.instance
            .collection('staff')
            .doc(loggedInStaffID)
            .update({
          'assignedTrades': FieldValue.arrayRemove([selectedTradeHash]),
        });

        await FirebaseFirestore.instance
            .collection('trades')
            .doc(selectedTradeHash)
            .update({
          'isPaid': true,
        });

        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            setState(() {
              selectedTradeHash = null;
              countdownComplete = true;
              Countdown.reset();
            });
          }
        });

        setState(() {
          selectedTradeHash = null;
        });
      } else {
        print('Failed to mark trade as paid: ${response.body}');
      }
    } catch (e) {
      print('Error making API call: $e');
    }
  }

Future<Map<String, dynamic>> getTradeStats() async {
  int totalTrades = 0;
  int tradesMarkedWithNumbers = 0;
  int tradesMarkedAutomatic = 0;
  double totalSpeed = 0;
  int count = 0;

  // Fetch staff document from Firestore
  DocumentSnapshot staffDoc = await FirebaseFirestore.instance
      .collection('staff')
      .doc(widget.username)
      .get();

  if (staffDoc.exists) {
    // Extract assigned trades
    List<dynamic> assignedTrades = staffDoc.get('assignedTrades');

    // Iterate through each trade
    for (var trade in assignedTrades) {
      totalTrades++;  // Increment total trades counter

      if (trade['isPaid'] == true) {
        // If trade is paid, check for 'markedAt'
        String? markedAt = trade['markedAt'];

        if (markedAt == null) {
          tradesMarkedAutomatic++;  // Trade marked automatically
        } else {
          // Parse the 'markedAt' string into a double if it exists
          double? markedAtValue = double.tryParse(markedAt);
          
          if (markedAtValue != null) {
            tradesMarkedWithNumbers++;  // Trade marked with a number
            totalSpeed += markedAtValue;  // Add speed to total
            count++;
          }
        }
      }
    }
  }

  // Calculate the average speed
  double averageSpeed = count > 0 ? totalSpeed / count : 0;

  // Return the data as a map
  return {
    'totalTrades': totalTrades,
    'tradesMarkedAutomatic': tradesMarkedAutomatic,
    'tradesMarkedWithNumbers': tradesMarkedWithNumbers,
    'averageSpeed': averageSpeed,
  };
}

//Paxful Rates

  Future fetchPaxfulrates() async {
    const String url = 'https://tester-1wva.onrender.com/paxful/paxful/rates';
    try {
      // Make a POST request
      final http.Response response = await http.post(
        Uri.parse(url),
      );
      if (response.statusCode == 200) {
        // Decode the response body
        final Map<String, dynamic> responseData = json.decode(response.body);

        // Extract the price and convert it to an int
        double price = responseData['price'];
        int priceAsInt = price.toInt();
        print('Paxful USD RATE: $priceAsInt');

        return priceAsInt;
      } else {
        print('Failed to fetch price: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Error: $e');
      return null;
    }
  }

  Future fetchBinanceRates() async {
    // Define the URL
    const String url = 'https://tester-1wva.onrender.com/paxful/binance/rates';

    try {
      // Make the POST request
      final http.Response response = await http.post(
        Uri.parse(url),
      );

      // Check if the response was successful
      if (response.statusCode == 200) {
        // Decode the response body
        final Map<String, dynamic> responseData = json.decode(response.body);

        // Extract the price from the response
        int price = responseData['price'];
        print('Binance USD RATE: ${price.toString()}');

        return price;
      } else {
        // If the server did not return a 200 OK response,
        // throw an exception.
        print('Failed to fetch Binance price: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Error: $e');
      return null;
    }
  }

  int? sellingPrice;
  int? costPrice;
  //final int markup = 250000;
  //final int SystemOverride = 1587;

  void calculatePrices() async {
    int paxfulRate = await fetchPaxfulrates();
    int binanceRate = await fetchBinanceRates();
    int systemOverride = 1587;
    int markup = 250000;

    if (paxfulRate != null && binanceRate != null) {
      final formatter = NumberFormat("#,##0");

      String formattedPaxfulRate = formatter.format(paxfulRate);
      String formattedBinanceRate = formatter.format(binanceRate);
      String formattedSystemOverride = formatter.format(systemOverride);
      String formattedMarkup = formatter.format(markup);

      // Print the formatted rates before any calculation

      print("Paxful Rate: $formattedPaxfulRate");
      print("Binance Rate: $formattedBinanceRate");
      print("System Override: $formattedSystemOverride");
      print("Markup: $formattedMarkup");

      // Continue with calculations using the original int values
      int sellingPrice = paxfulRate * systemOverride;

      print("Selling Price: $sellingPrice");

      if (paxfulRate > binanceRate) {
        // Calculate the difference between the rates
        int rateDifference = paxfulRate - binanceRate;
        print("Rate Diff Pax/Bin: $rateDifference");

        // Calculate the cost price using the given logic
        int costPrice = (rateDifference + 00) + sellingPrice;

        print("Cost Price when Paxful is higher: $costPrice");

        setState(() {
          this.sellingPrice = sellingPrice;
          this.costPrice = costPrice;
        });

      } else {
        // Calculate the cost price when Binance rate is higher
        int rateDifference = paxfulRate - binanceRate;
        int costPrice = systemOverride - sellingPrice;

        print("Cost Price when Binance is higher: $costPrice");
        print("Rate Diff Pax/Bin: $rateDifference");

        setState(() {
          this.sellingPrice = sellingPrice;
          this.costPrice = costPrice;
        });
      } 
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  late StreamSubscription<DocumentSnapshot> _staffSubscription;
  late StreamSubscription<DocumentSnapshot> _tradeMessagesSubscription;
  final Countdown = CountDownController();

  final _countdownController = CountDownController();
  int remainingTime = 12;
  Timer? _timer;
  int _remainingTime = 60;
  bool countdownComplete = false;
  DateTime? countdownStartTime;
  Timer? autoMarkPaidTimer;

  void startCountdown() {
    countdownStartTime =
        DateTime.now(); // Capture start time when countdown begins
    print("Countdown started at: $countdownStartTime");
  }

  void _startTimer() {
    Timer.periodic(Duration(seconds: 1), (timer) {
      if (mounted && remainingTime > 0) {
        setState(() {
          remainingTime--;
        });
      } else {
        timer.cancel();
      }
    });
  }

  void _removeCurrentTrade() async {
    String currentTradeHash = selectedTradeHash!;
    DocumentReference staffRef =
        FirebaseFirestore.instance.collection('staff').doc(loggedInStaffID);

    await FirebaseFirestore.instance.runTransaction((transaction) async {
      DocumentSnapshot staffSnapshot = await transaction.get(staffRef);

      if (staffSnapshot.exists) {
        List<Map<String, dynamic>> assignedTrades =
            List<Map<String, dynamic>>.from(
                staffSnapshot['assignedTrades'] ?? []);
        assignedTrades
            .removeWhere((trade) => trade['trade_hash'] == currentTradeHash);
        transaction.update(staffRef, {'assignedTrades': assignedTrades});
      }
    });

    setState(() {
      _remainingTime = 60;
    });
  }

  ValueNotifier<String?> currentTradeNotifier = ValueNotifier<String?>(null);
  void _onCountdownComplete() {
    currentTradeNotifier.value = null;
  }

  Future<double> calculateAverageSpeed() async {
    double totalSpeed = 0;
    int count = 0;

    // Fetch staff document from Firestore
    DocumentSnapshot staffDoc = await FirebaseFirestore.instance
        .collection('staff')
        .doc(widget.username)
        .get();

    if (staffDoc.exists) {
      // Extract assigned trades
      List<dynamic> assignedTrades = staffDoc.get('assignedTrades');

      for (var trade in assignedTrades) {
        if (trade['isPaid'] == true && trade['markedAt'] != null) {
          // Parse the markedAt string into a double
          double markedAt = double.tryParse(trade['markedAt']) ?? 0;

          totalSpeed += markedAt;
          count++;
        }
      }
    }

    // Calculate average speed in seconds
    return count > 0 ? totalSpeed / count : 0;
  }

  @override
  void initState() {
    super.initState();
    loggedInStaffID = widget.username;
    _listenToStaffChanges();
    setState(() {
      selectedTradeHash = null;
    });
    calculatePrices();
  }

  void _listenToStaffChanges() {
    _staffSubscription = FirebaseFirestore.instance
        .collection('staff')
        .doc(loggedInStaffID)
        .snapshots()
        .listen((staffSnapshot) {
      if (staffSnapshot.exists) {
        // Extract the list of assigned trade objects
        final assignedTrades = List<Map<String, dynamic>>.from(
          staffSnapshot.data()?['assignedTrades'] ?? [],
        );

        if (assignedTrades.isNotEmpty) {
          // Get the latest trade object and extract the trade_hash
          Map<String, dynamic> latestTrade = assignedTrades.last;
          String latestTradeHash = latestTrade['trade_hash'];

          setState(() {
            selectedTradeHash = latestTradeHash;
          });

          _listenToTradeMessages(latestTradeHash);
        }
      }
    });
  }

  void _listenToTradeMessages(String tradeHash) {
    _tradeMessagesSubscription = FirebaseFirestore.instance
        .collection('tradeMessages')
        .doc(tradeHash)
        .snapshots()
        .listen((tradeSnapshot) {});
  }

  @override
  void dispose() {
    _staffSubscription.cancel();
    _tradeMessagesSubscription.cancel();
    _timer?.cancel();
    currentTradeNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.only(left: 20, right: 20, top: 70),
        child: Row(
          children: [

Expanded(
  flex: 2,
  child: FutureBuilder<Map<String, dynamic>>(
    future: getTradeStats(),
    builder: (context, snapshot) {
      if (snapshot.connectionState == ConnectionState.waiting) {
        return Center(child: CircularProgressIndicator());  // Loading indicator
      } else if (snapshot.hasError) {
        return Text('Error: ${snapshot.error}');  // Error message
      } else if (snapshot.hasData) {
      
        final int totalTrades = snapshot.data!['totalTrades'];
        final int tradesMarkedAutomatic = snapshot.data!['tradesMarkedAutomatic'];
        final int tradesMarkedWithNumbers = snapshot.data!['tradesMarkedWithNumbers'];
        final double averageSpeed = snapshot.data!['averageSpeed'];
  
        // Use the container widget to display trade stats
        return Container(
          child: _buildTradeStatsContainer(
            context, totalTrades, tradesMarkedAutomatic, 
            tradesMarkedWithNumbers, averageSpeed),
        );
      } else {
        return Text('No data available');
      }
    },
  ),
),

SizedBox(width: 4.w,),




            Expanded(
              flex: 4,
              child: StreamBuilder<DocumentSnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('staff')
                    .doc(loggedInStaffID)
                    .snapshots(),
                builder: (context, staffSnapshot) {
                  if (staffSnapshot.connectionState ==
                      ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  }
                  if (!staffSnapshot.hasData || !staffSnapshot.data!.exists) {
                    return Center(child: Text('No assigned trades'));
                  }

                  final assignedTrades = List<Map<String, dynamic>>.from(
                    staffSnapshot.data!['assignedTrades'] ?? [],
                  );

                  if (assignedTrades.isEmpty) {
                    return Center(child: Text('No trades assigned.'));
                  }

                  // Filter out paid trades
                  final unpaidTrades = assignedTrades
                      .where((trade) => trade['isPaid'] == false)
                      .toList();

                  if (unpaidTrades.isEmpty) {
                    return Align(
                        alignment: Alignment.centerRight,
                        child: Text(
                          'No Assigned Trade Yet.',
                          style: GoogleFonts.poppins(fontSize: 10.sp),
                        ));
                  }

                  Map<String, dynamic> latestTrade = unpaidTrades.last;
                  String latestTradeHash = latestTrade['trade_hash'];

                  if (selectedTradeHash == null ||
                      selectedTradeHash != latestTradeHash) {
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      if (mounted) {
                        setState(() {
                          selectedTradeHash = latestTradeHash;
                          countdownComplete =
                              false; // Reset countdown complete status
                        });
                      }
                    });
                  }

                  return StreamBuilder<DocumentSnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('tradeMessages')
                        .doc(selectedTradeHash)
                        .snapshots(),
                    builder: (context, tradeSnapshot) {
                      if (tradeSnapshot.connectionState ==
                          ConnectionState.waiting) {
                        return Center(child: CircularProgressIndicator());
                      }

                      if (!tradeSnapshot.hasData ||
                          !tradeSnapshot.data!.exists) {
                        if (autoMarkPaidTimer == null) {
                          autoMarkPaidTimer =
                              Timer(Duration(seconds: 10), () async {
                            if (!tradeSnapshot.hasData ||
                                !tradeSnapshot.data!.exists) {
                              await _markTradeAsPaid(context, 'Auto');
                            }
                          });
                        }
                      }

                      final tradeMessages =
                          tradeSnapshot.data!.data() as Map<String, dynamic>? ??
                              {};
                      final messages = List<Map<String, dynamic>>.from(
                          tradeMessages['messages'] ?? []);

                      Map<String, dynamic>? bankDetails =
                          _checkForBankDetails(messages);

                      return Column(
                        children: [

                          Align(
                            alignment: Alignment.topLeft,
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(width: 0.5),
                                  ),
                                width: MediaQuery.of(context).size.width-20.w,
                                height: 7.h,
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.only(left: 7),
                                            child: CircularCountDownTimer(
                                              key: ValueKey(selectedTradeHash),
                                              width: 35,
                                              height: 35,
                                              duration: 12,
                                              fillColor: Colors.black,
                                              ringColor: Colors.blue,
                                              controller: _countdownController,
                                              autoStart: true,
                                              onStart: () {
                                                countdownStartTime = DateTime.now();
                                                print(
                                                    "Countdown started at: $countdownStartTime");
                                              },
                                              onComplete: () async {
                                                DateTime tradePaidTime = DateTime.now();
                                                Duration timeTaken = tradePaidTime
                                                    .difference(countdownStartTime!);
                                                print(
                                                    "Trade marked as paid after: ${timeTaken.inSeconds} seconds");
                                                if (isVerified == true) {
                                            
                                                  try {
                                                    final response = await http.post(
                                                      Uri.parse(
                                                          'https://tester-1wva.onrender.com/trade/mark'),
                                                      headers: {
                                                        'Content-Type': 'application/json'
                                                      },
                                                      body: jsonEncode({
                                                        'trade_hash': latestTradeHash,
                                                        'markedAt': 'Automatic'
                                                      }),
                                                    );
                                            
                                                    if (response.statusCode == 200) {
                                                      print(response.body);
                                            
                                                      print(
                                                          'Trade marked as paid successfully.');
                                            
                                                      await FirebaseFirestore.instance
                                                          .collection('staff')
                                                          .doc(loggedInStaffID)
                                                          .update({
                                                        'assignedTrades':
                                                            FieldValue.arrayRemove(
                                                                [latestTrade]),
                                                      });
                                            
                                                      await FirebaseFirestore.instance
                                                          .collection('trades')
                                                          .doc(latestTradeHash)
                                                          .update({
                                                        'isPaid': true,
                                                      });
                                            
                                                      // Reset UI state and wait for the next trade
                                                      WidgetsBinding.instance
                                                          .addPostFrameCallback((_) {
                                                        if (mounted) {
                                                          setState(() {
                                                            selectedTradeHash = null;
                                                            countdownComplete = true;
                                                            Countdown.reset();
                                                            _countdownController.reset();
                                                            remainingTime = 12;
                                                          });
                                                        }
                                                      });
                                            
                                                      setState(() {
                                                        selectedTradeHash = null;
                                                      });
                                                    } else {
                                                      print(
                                                          'Failed to mark trade as paid: ${response.body}');
                                                    }
                                                  } catch (e) {
                                                    print('Error making API calls: $e');
                                                  }
                                                } else {
                                                  print('Invalid Account');
                                                }
                                              },
                                            ),
                                          ),
                                         SizedBox(width: 3.w,),
                                         Text("Countdown",style: GoogleFonts.poppins(
                                          fontSize: 7.sp,
                                          fontWeight: FontWeight.w500
                                         ),)
                                        ],
                                      ),

            FutureBuilder<double>(
              future: calculateAverageSpeed(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return CircularProgressIndicator();
                } else if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                } else if (snapshot.hasData) {
                  return GestureDetector(
                    onTap: () {
                  
                    },
                    child: Row(
                      children: [
                        Icon(Icons.run_circle_sharp,size: 55,),
                        SizedBox(width: 3.w,),
                        Text(
                          '${snapshot.data!.toStringAsFixed(2)} sec',
                          style: GoogleFonts.poppins(
                              fontSize: 13.sp,
                              fontWeight: FontWeight.w500,
                              color: Colors.black
                              ),
                        ),
                      ],
                    ),
                  );
                } else {
                  return Text('No data');
                }
              },
            ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),


                          if (bankDetails != null)
                            Column(
                              children: [
                                // HeaderContainer(
                                //   sellingPrice: sellingPrice,
                                //   costPrice: costPrice,
                                // ),
                                
                                _buildSellerDetailsUI(
                                  context,
                                  bankDetails['holder_name'] ?? 'N/A',
                                  bankDetails['account_number'] ?? 'N/A',
                                  bankDetails['bank_name'] ?? 'N/A',
                                  latestTrade['fiat_amount_requested'] ?? 'N/A',
                                )
                              ],
                            )
                          else
                            Column(
                              children: [
                                // HeaderContainer(
                                //   sellingPrice: sellingPrice,
                                //   costPrice: costPrice,
                                // ),
                                _buildSellerChatDetailsUI(
                                  context,
                                  recentPersonName,
                                  recentAccountNumber,
                                  recentBankName,
                                  latestTrade['fiat_amount_requested'] ?? 'N/A',
                                ),
                              ],
                            ),

                          ///UPDATEZ

                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              GestureDetector(
                                onTap: () async {
                                  fetchPaxfulrates();
                                },
                                child: Container(
                                  height: 4.h,
                                  width: 30.w,
                                  child: Center(
                                      child: Text(
                                    "To CC",
                                    style: GoogleFonts.poppins(
                                        color: Colors.white),
                                  )),
                                  decoration: BoxDecoration(
                                      color: Colors.black,
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(color: Colors.white)),
                                ),
                              ),
                              GestureDetector(
                                onTap: () {
                                  showDialog(
                                      context: context,
                                      builder: (context) {
                                        return ConfirmPayDialog(onConfirm: () {
                                          _markTradeAsPaid(
                                              context, widget.username);
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
                          ),
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
                  ? Center(child: Text(''))
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
                                return Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text("", style: GoogleFonts.poppins())
                                    ],
                                  ),
                                );
                              }

                              final tradeMessages = snapshot.data!.data()
                                      as Map<String, dynamic>? ??
                                  {};
                              final messages = List<Map<String, dynamic>>.from(
                                  tradeMessages['messages'] ?? []);

                              // Process messages
                              WidgetsBinding.instance.addPostFrameCallback((_) {
                                _processMessages(messages);
                              });

                              return ListView.builder(
                                itemCount: messages.length,
                                itemBuilder: (context, index) {
                                  final message = messages[index];
                                  final messageTime = _formatDateTime(
                                      _convertToDateTime(message['timestamp']));
                                  final messageAuthor = message['author'];
                                  final isMine = [
                                    '2minmax_pro',
                                    'Turbopay',
                                    '2minutepay'
                                  ].contains(messageAuthor);

                                  String messageText;
                                  if (message['text'] is Map<String, dynamic> &&
                                      message['text']
                                          .containsKey('bank_account')) {
                                    final bankAccount =
                                        message['text']['bank_account'];
                                    final name = bankAccount['holder_name'];
                                    final amount = bankAccount['amount'];
                                    final bank = bankAccount['bank_name'];
                                    messageText =
                                        'Name: $name\nAmount: $amount\nBank: $bank';
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

Widget _buildSellerDetailsUI(BuildContext context, String accountHolder,
    String accountNumber, String bankName, String amount) {
  return Column(
    children: [
      // _buildHeaderContainer(context),
      SizedBox(height: 3.h),
      _buildDetailsContainer(
          context, accountHolder, accountNumber, bankName, amount,
          isChatDetails: false),
      SizedBox(height: 7.h),
      // _buildFooterButtons(context),
    ],
  );
}

Widget _buildSellerChatDetailsUI(BuildContext context, String? personName,
    String? accountNumber, String? bankName, String amount) {
  return Column(
    children: [
      //_buildHeaderContainer(context),
      SizedBox(height: 3.h),
      _buildDetailsContainer(context, personName ?? 'N/A',
          accountNumber ?? 'Typing...', bankName ?? 'Typing...', amount,
          isChatDetails: true),
      SizedBox(height: 7.h),
      // _buildFooterButtons(context),
    ],
  );
}




Widget _buildDetailsContainer(BuildContext context, String accountHolder,
    String accountNumber, String bankName, String amount,
    {required bool isChatDetails}) {
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
              isChatDetails ? "Seller's Chat Details" : "Seller's Details",
              style: GoogleFonts.poppins(
                textStyle:
                    TextStyle(fontSize: 10.sp, fontWeight: FontWeight.w600),
              ),
            ),
            SizedBox(height: 2.h),
            _buildDetailRow('Account Name :', accountHolder, 5.sp),
            Divider(),
            _buildDetailRow('Account Number :', accountNumber, 8.sp),
            Divider(),
            _buildDetailRow('Bank Name:', bankName, 8.sp),
            Divider(),
            _buildDetailRow('Amounts:', formatNairas(amount), 18.sp),
          ],
        )),
  );
}

Widget _buildDetailRow(String title, String value, double textSize) {
  return Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Text(
        title,
        style: GoogleFonts.poppins(
            textStyle:
                TextStyle(fontSize: textSize, fontWeight: FontWeight.w600)),
      ),
      Text(
        value,
        style: GoogleFonts.poppins(
            textStyle:
                TextStyle(fontSize: textSize, fontWeight: FontWeight.w600)),
      ),
    ],
  );
}

Widget _buildFooterButtons(BuildContext context) {
  return Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      GestureDetector(
        onTap: () async {
          final player = AudioPlayer();
          await player.play(
              UrlSource('https://www.val9ja.com.ng/hottest/rema-hehehe/'));
        },
        child: _buildFooterButton(context, "To CC", Colors.black, Colors.white),
      ),
      GestureDetector(
        onTap: () {
          showDialog(
            context: context,
            builder: (context) {
              return ConfirmPayDialog(onConfirm: () async {
                // _MarkPaid();

                // await _markTradeAsPaid(context);
                Navigator.pop(context);
              }, onCancel: () {
                Navigator.pop(context);
              });
            },
          );
        },
        child: _buildFooterButton(
            context, "Mark Paid", Colors.white, Colors.black),
      ),
    ],
  );
}

Widget _buildFooterButton(
    BuildContext context, String text, Color bgColor, Color textColor) {
  return Container(
    height: 4.h,
    width: 30.w,
    child: Center(
      child: Text(
        text,
        style: GoogleFonts.poppins(color: textColor),
      ),
    ),
    decoration: BoxDecoration(
      color: bgColor,
      borderRadius: BorderRadius.circular(10),
      border: Border.all(color: textColor),
    ),
  );
}

String formatNairas(dynamic newamount) {
  double parsedAmount;
  if (newamount is double) {
    parsedAmount = newamount;
  } else if (newamount is String) {
    parsedAmount = double.tryParse(newamount) ?? 0.0;
  } else {
    throw ArgumentError(
        'Input should be a double or a string representing a number');
  }

  // Convert the amount to a string with commas as thousand separators
  String formattednewAmount = parsedAmount.toStringAsFixed(2).replaceAllMapped(
        RegExp(r'\B(?=(\d{3})+(?!\d))'),
        (Match match) => ',',
      );
  return '₦$formattednewAmount';
}

class HeaderContainer extends StatelessWidget {
  final int? sellingPrice;
  final int? costPrice;

  HeaderContainer({
    required this.sellingPrice,
    required this.costPrice,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 8.h,
      width: MediaQuery.of(context).size.width - 20,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: Colors.blue,
      ),
      child: sellingPrice != null && costPrice != null
          ? Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text('Sale: ',
                          style: GoogleFonts.poppins(fontSize: 10.sp)),

                          Divider(
                            thickness: 1.0,
                            height: 1.5,
                            
                          ),

                      Text(' ${sellingPrice!.toStringAsFixed(2)}',
                          style: GoogleFonts.poppins(
                              fontSize: 12.sp, color: Colors.white)),
                    ],
                  ),
                  Row(
                    children: [
                      Text(
                        'Cost Price:',
                        style: GoogleFonts.poppins(fontSize: 10.sp),
                      ),
                      Text(' ${costPrice!.toStringAsFixed(2)}',
                          style: GoogleFonts.poppins(
                              fontSize: 12.sp, color: Colors.white)),
                    ],
                  ),
                ],
              ),
            )
          : Center(
              child: CircularProgressIndicator(),
            ),
    );
  }
}


Widget _buildTradeStatsContainer(
    BuildContext context, int totalTrades, int tradesMarkedAutomatic,
    int tradesMarkedWithNumbers, double averageSpeed) {
  return Column(
    children: [
      Container(
        decoration: BoxDecoration(
          border: Border.all(width: 0.5),
          borderRadius: BorderRadius.circular(10),
        ),
        // Use 80% of the screen width for the container
        width: 50.w,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "Trade Stats",
                style: GoogleFonts.poppins(
                  textStyle: TextStyle(
                    fontSize: 10.sp, 
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              SizedBox(height: 2.h),
      
              _buildStatRow('Total Trades:', totalTrades.toString(), 5.sp),
              Divider(),
      
              _buildStatRow('Trades Marked Automatic:', tradesMarkedAutomatic.toString(), 5.sp),
              Divider(),
      
              _buildStatRow('Trades Marked With Numbers:', tradesMarkedWithNumbers.toString(), 5.sp),
              Divider(),
      
              _buildStatRow('Average Speed:', '${averageSpeed.toStringAsFixed(2)} sec', 5.sp),
            ],
          ),
        ),
      ),
    ],
  );
}



Widget _buildStatRow(String title, String value, double fontSize) {
  return Row(
   // mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Text(
        title,
        style: GoogleFonts.poppins(
          textStyle: TextStyle(fontSize: fontSize, fontWeight: FontWeight.w500),
        ),
      ),
      Text(
        value,
        style: GoogleFonts.poppins(
          textStyle: TextStyle(fontSize: fontSize, fontWeight: FontWeight.w400),
        ),
      ),
    ],
  );
}