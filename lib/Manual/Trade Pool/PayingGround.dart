import 'dart:async';
import 'dart:convert';
import 'package:bdesktop/Manual/Api%20services/BankService.dart';
import 'package:bdesktop/Manual/Api%20services/RatesService.dart';
import 'package:bdesktop/Manual/Api%20services/TradeService.dart';
import 'package:bdesktop/Manual/Api%20services/clockinApi.dart';
import 'package:bdesktop/Trainer/login.dart';
import 'package:bdesktop/widgets/paid.dart';
import 'package:circular_countdown_timer/circular_countdown_timer.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sizer/sizer.dart';


class Payment extends StatefulWidget {
  final String username;

  const Payment({Key? key, required this.username}) : super(key: key);

  @override
  State<Payment> createState() => _PaymentState();
}

class _PaymentState extends State<Payment> {
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
  int? sellingPrice;
  int? costPrice;
  int? RealTime;

  final RateService _rateService = RateService();
  final TradeService _tradeService = TradeService();
  final accountService = AccountService();

  // FORMATTERS
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

  // FORMATTERS END

  ///  TRADE MONEY FUNCTIONS

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

  void verifyAccountWithService(
      BuildContext context, AccountService accountService) async {
    if (recentAccountNumber == null || recentBankCode == null) {
      print('Error: Account number or bank code is missing');
      return;
    }
    await accountService.verifyAccount(
      context,
      recentAccountNumber!,
      recentBankCode!,
      _initializeTimer,
    );
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


void handleIncomingMessages(
  List<Map<String, dynamic>> messages,
  BuildContext context,
  String? recentAccountNumber,
  String? recentPersonName,
  String? recentBankName,
  String? recentBankCode,
  AccountService accountService,
  void Function() initializeTimer, // Your timer initialization function
) {
  accountService.processMessages(
    messages,
    context,
    recentAccountNumber,
    recentPersonName,
    recentBankName,
    recentBankCode,
    initializeTimer,
  );
}





  Future<void> _removeTradeByHash() async {
    if (selectedTradeHash == null) {
      setState(() {
        _responseMessage = 'No trade selected.';
      });
      return;
    }

    try {
      // Check if the trade exists in Firestore
      final tradeDoc = await FirebaseFirestore.instance
          .collection('assignedTrades')
          .doc(selectedTradeHash)
          .get();

      if (tradeDoc.exists) {
        // Remove the trade from 'assignedTrades'
        await FirebaseFirestore.instance
            .collection('assignedTrades')
            .doc(selectedTradeHash)
            .delete();

        setState(() {
          _responseMessage =
              'Trade removed successfully. Waiting for next trade.';
          selectedTradeHash = null; // Reset selected trade hash
          // Reset other UI elements or variables if needed
          // Clear trade details, stop timers, etc.
          _timerService?.stop(); // Stop any active timers
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

// Example function to wait for the next trade or handle logic for waiting
  Future<void> _waitForNextTrade() async {
    // Listen for updates from Firestore for new trades
    FirebaseFirestore.instance
        .collection('assignedTrades')
        .snapshots()
        .listen((snapshot) {
      if (snapshot.docs.isNotEmpty) {
        // Automatically select the next trade if one comes in
        setState(() {
          selectedTradeHash = snapshot.docs.first.id; // Assign the new trade
          _responseMessage = 'New trade received: ${selectedTradeHash}';
        });
      } else {
        setState(() {
          _responseMessage = 'Waiting for new trades.';
        });
      }
    });
  }

  Future<void> _markTradeAsPaid(BuildContext context, String username) async {
    int elapsedTime = _timerService!.getElapsedTime();
    print("Marking trade at elapsed time: $elapsedTime");
    await _tradeService.markTradeAsPaid(
      tradeHash: selectedTradeHash!,
      elapsedTime: elapsedTime,
      amountPaid: fiatAmount,
      loggedInStaffID: loggedInStaffID,
      resetSelectedTrade: resetSelectedTrade,
    );
  }

  void resetSelectedTrade() {
    setState(() {
      selectedTradeHash = null;
    });
  }

//Complain

  Future<void> _markTradeAsCC(BuildContext context, String username) async {
    try {
      // int elapsedTime = _timerService!.getElapsedTime();
      //  print("Marking at >>>>>>>>>>>>> $elapsedTime");

      final response = await http.post(
        Uri.parse('https://tester-1wva.onrender.com/trade/mark'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'trade_hash': selectedTradeHash,
          'markedAt': 'complain', // Using the elapsed time
          'amountPaid': fiatAmount,
        }),
      );

      if (response.statusCode == 200) {
        print(">>>>> Marked ${response.body}");

        //1   _timerService!.stop(resetTime: true);

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

        // Reset UI elements and start listening for new trades
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            setState(() {
              selectedTradeHash = null;
            });
          }
        });

        setState(() {
          selectedTradeHash = null; // Reset selected trade
        });
      } else {
        print('Failed to mark trade as paid: ${response.body}');
      }
    } catch (e) {
      setState(() {
        selectedTradeHash = null;
      });
      print('Error making API call: $e');
    }
  }

  Future<Map<String, dynamic>> getTradeStats() async {
    int totalTrades = 0;
    int tradesMarkedWithNumbers = 0;
    int tradesMarkedAutomatic = 0;
    int tradesMarkedInvalid = 0; // Counter for invalid trades
    double totalSpeed = 0;
    int count = 0;

    // Fetch staff document from Firestore
    DocumentSnapshot staffDoc = await FirebaseFirestore.instance
        .collection('Allstaff')
        .doc(widget.username)
        .get();

    if (staffDoc.exists) {
      // Extract assigned trades
      List<dynamic> assignedTrades = staffDoc.get('assignedTrades');

      // Iterate through each trade
      for (var trade in assignedTrades) {
        totalTrades++; // Increment total trades counter

        if (trade['isPaid'] == true) {
          // If trade is paid, check for 'markedAt'
          String? markedAt = trade['markedAt'];

          if (markedAt == null ||
              markedAt.toLowerCase() == 'automatic' ||
              markedAt.toLowerCase() == 'expired') {
            tradesMarkedAutomatic++; // Trade marked automatically
          } else if (markedAt.toLowerCase() == 'complain') {
            tradesMarkedInvalid++; // Trade marked invalid
          } else {
            // Try parsing the markedAt string into a double
            double? markedAtValue = double.tryParse(markedAt);

            if (markedAtValue != null) {
              tradesMarkedWithNumbers++; // Trade marked with a number
              totalSpeed += markedAtValue; // Add speed to total
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
      'tradesMarkedInvalid': tradesMarkedInvalid, // Include invalid trades
      'averageSpeed': averageSpeed,
    };
  }

  ValueNotifier<String?> currentTradeNotifier = ValueNotifier<String?>(null);
  void _onCountdownComplete() {
    currentTradeNotifier.value = null;
  }
  //NOTIFIERS END

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        final unpaidTrades =
            assignedTrades.where((trade) => trade['isPaid'] == false).toList();
        if (unpaidTrades.isNotEmpty) {
          Map<String, dynamic> latestTrade = unpaidTrades.last;
          String latestTradeHash = latestTrade['trade_hash'];

          if (selectedTradeHash == null ||
              selectedTradeHash != latestTradeHash) {
            setState(() {
              selectedTradeHash = latestTradeHash;
              countdownComplete = false; // Reset countdown complete status
              countdownStartTime = DateTime.now(); // Set countdown start time
              _countdownController.restart(duration: _durationFromFirestore);
            });
          }
        }
      }
    });
  }

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
      // _remainingTime = 60;
    });
  }

  Future<double> calculateAverageSpeed() async {
    double totalSpeed = 0;
    int count = 0;

    // Fetch staff document from Firestore
    DocumentSnapshot staffDoc = await FirebaseFirestore.instance
        .collection('Allstaff')
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

  List<Map<String, dynamic>> assignedTrades = [];
  int? _durationFromFirestore;
  dynamic Loadingtime;
  Map<String, int> tradeCountdowns = {};
  TimerService? _timerService;

  void Kickstart() {
    if (_timerService != null) {
      _timerService!.start();
    } else {
      print("TimerService is not initialized.");
    }
  }

  void Kickstop() {
    if (_timerService != null) {
      _timerService!.stop();
    } else {
      print("TimerService is not initialized.");
    }
  }

  Future<void> _initializeTimer() async {
    int firestoreDuration = await _fetchDurationFromFirestore();
    print('Fetched duration: $firestoreDuration');

    _timerService = TimerService(
      onTick: (elapsedTime) {
        // Handle tick updates here if needed
      },
      duration: firestoreDuration,
      onComplete: () async {
        await _markTradeAsPaid(context, widget.username);
      },
    );
    print('_timerService initialized');
    _timerService!.start(); // Ensure _timerService is not null here
  }

  Future<int> _fetchDurationFromFirestore() async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('Duration')
          .doc('Duration')
          .get();

      if (doc.exists) {
        final data = doc.data();
        return data?['Duration'] ?? 0;
      } else {
        print('No duration data found.');
        return 0;
      }
    } catch (e) {
      print('Error fetching duration from Firestore: $e');
      return 0;
    }
  }

  String? token;
  Future<String?> _getTokenFromPrefs() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('token'); // Retrieve the token
  }

  Future<void> _loadToken() async {
    token = await _getTokenFromPrefs(); // Fetch the token
    print(token);
    setState(() {});
  }

  Future<void> _showClockInDialog() async {
    // Fetch the token from SharedPreferences
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token'); // Assuming you saved the token

    if (token == null) {
      // Handle case where the token is not found
      return;
    }
    showDialog(
      context: context,
      barrierDismissible: false, // Prevent dismissing the dialog
      builder: (context) {
        return AlertDialog(
          title: Text(
            'Starting Shift',
            style: GoogleFonts.montserrat(fontWeight: FontWeight.w600),
          ),
          content: Text(
            'Are you ready to Start your Shift?',
            style: GoogleFonts.montserrat(),
          ),
          actions: [
            TextButton(
              onPressed: () async {
                Map<String, dynamic> response =
                    await ApiService().clockIn(token);
                if (response['success'] == true) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                        content: Text(
                      'Clock in successful!',
                      style: GoogleFonts.montserrat(),
                    )),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                        content: Text(
                      'Clock in failed: ${response['message']}',
                      style: GoogleFonts.montserrat(),
                    )),
                  );
                }
                Navigator.of(context).pop(); // Close the dialog
              },
              child: Text(
                'Yes',
                style: GoogleFonts.montserrat(),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
                Navigator.of(context).pop();
              },
              child: Text(
                'No',
                style: GoogleFonts.montserrat(),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    _loadToken();
   // _showClockInDialog();
    _fetchDurationFromFirestore();
    selectedTradeHash == null ? Kickstop() : null;
    loggedInStaffID = widget.username;
    _listenToStaffChanges();
    setState(() {
      selectedTradeHash = null;
    });
    _rateService.calculatePrices(setState);
  }

  void _listenToStaffChanges() {
    _staffSubscription = FirebaseFirestore.instance
        .collection('Allstaff')
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
        .collection('manualmessages')
        .doc(tradeHash)
        .snapshots()
        .listen((tradeSnapshot) {});
  }

  Stopwatch stopwatch = Stopwatch();
  Timer? printTimer;

  @override
  void dispose() {
    _timerService?.stop();
    _staffSubscription.cancel();
    _tradeMessagesSubscription.cancel();
    currentTradeNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        actions: [
          GestureDetector(
            onTap: () {
              setState(() {
                selectedTradeHash = null;
              });

              Navigator.pushReplacement(context,
                  MaterialPageRoute(builder: (context) => LoginPage()));
            },
            child: Container(
              height: 40,
              width: 90,
              decoration: BoxDecoration(
                  color: Colors.black, borderRadius: BorderRadius.circular(10)),
              child: Center(
                  child: Text(
                'Sign Out',
                style: GoogleFonts.montserrat(
                    fontWeight: FontWeight.w400, color: Colors.white),
              )),
            ),
          ),
          SizedBox(
            width: 20,
          )
        ],
      ),
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
                    return Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  } else if (snapshot.hasData) {
                    final int totalTrades = snapshot.data!['totalTrades'];
                    final int tradesMarkedAutomatic =
                        snapshot.data!['tradesMarkedAutomatic'];
                    final int tradesMarkedWithNumbers =
                        snapshot.data!['tradesMarkedWithNumbers'];
                    final int tradesMarkedInvalid = snapshot.data![
                        'tradesMarkedInvalid']; // Retrieve invalid trades
                    final double averageSpeed = snapshot.data!['averageSpeed'];

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              "Hello,",
                              style: GoogleFonts.poppins(
                                  fontSize: 10.sp, fontWeight: FontWeight.w500),
                            ),
                            SizedBox(width: 1.w),
                            Text(widget.username),
                          ],
                        ),
                        SizedBox(height: 2.h),
                        Container(
                          child: Padding(
                            padding: const EdgeInsets.all(15.0),
                            child: _buildTradeStatsContainer(
                              context,
                              totalTrades,
                              tradesMarkedAutomatic,
                              tradesMarkedWithNumbers,
                              tradesMarkedInvalid, // Pass invalid trades to the container
                              averageSpeed,
                            ),
                          ),
                        ),
                      ],
                    );
                  } else {
                    return Text('No data available');
                  }
                },
              ),
            ),
            
            SizedBox(
              width: 4.w,
            ),

            Expanded(
              flex: 4,
              child: StreamBuilder<DocumentSnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('Allstaff')
                    .doc(loggedInStaffID)
                    .snapshots(),
                builder: (context, staffSnapshot) {
                  if (staffSnapshot.connectionState ==
                      ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  }
                  if (!staffSnapshot.hasData || !staffSnapshot.data!.exists) {
                    _timerService?.stop();
                    return Center(child: Text('No assigned trades'));
                  }

                  final assignedTrades = List<Map<String, dynamic>>.from(
                    staffSnapshot.data!['assignedTrades'] ?? [],
                  );

                  if (assignedTrades.isEmpty) {
                    // Stop the timer when no trades are assigned
                    _timerService?.stop();
                    return Align(
                        alignment: Alignment.centerRight,
                        child: Padding(
                          padding: const EdgeInsets.only(right: 70),
                          child: Text(
                            'Welcome ${widget.username}',
                            style: GoogleFonts.montserrat(fontSize: 26),
                          ),
                        ));
                  }

                  // Filter out paid trades
                  final unpaidTrades = assignedTrades
                      .where((trade) => trade['isPaid'] == false)
                      .toList();

                  if (unpaidTrades.isEmpty) {
                    // Stop the timer when no unpaid trades exist
                    _timerService?.stop();
                    Kickstop();

                    return Align(
                      alignment: Alignment.center,
                      child: Padding(
                        padding: const EdgeInsets.only(left: 150),
                        child: Text(
                          'No Assigned Trade Yet.',
                          style: GoogleFonts.montserrat(),
                        ),
                      ),
                    );
                  }

                  Map<String, dynamic> latestTrade = unpaidTrades.last;
                  String latestTradeHash = latestTrade['trade_hash'];

                  if (selectedTradeHash == null ||
                      selectedTradeHash != latestTradeHash) {
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      if (mounted) {
                        setState(() {
                          selectedTradeHash = latestTradeHash;
                        });

                        // Start the timer when a new trade is assigned
                      }
                    });
                  }

                  return StreamBuilder<DocumentSnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('manualmessages')
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
                                width: MediaQuery.of(context).size.width - 20,
                                height: 70,
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      FutureBuilder<double>(
                                        future: calculateAverageSpeed(),
                                        builder: (context, snapshot) {
                                          if (snapshot.connectionState ==
                                              ConnectionState.waiting) {
                                            return CircularProgressIndicator();
                                          } else if (snapshot.hasError) {
                                            return Text(
                                                'Error: ${snapshot.error}');
                                          } else if (snapshot.hasData) {
                                            return GestureDetector(
                                              onTap: () {},
                                              child: Row(
                                                children: [
                                                  Icon(
                                                    Icons.run_circle_sharp,
                                                    size: 50,
                                                  ),
                                                  SizedBox(
                                                    width: 10,
                                                  ),
                                                  Text(
                                                    '${snapshot.data!.toStringAsFixed(2)} sec',
                                                    style: GoogleFonts.poppins(
                                                      fontSize: 12,
                                                      fontWeight:
                                                          FontWeight.w500,
                                                      color: Colors.black,
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
                                _buildSellerChatDetailsUI(
                                  context,
                                  recentPersonName,
                                  recentAccountNumber,
                                  recentBankName,
                                  latestTrade['fiat_amount_requested'] ?? 'N/A',
                                ),
                              ],
                            ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              GestureDetector(
                                onTap: () async {
                                  showDialog(
                                      context: context,
                                      builder: (context) {
                                        return ConfirmCCDialog(onConfirm: () {
                                          _markTradeAsCC(
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
                                  //  _timerService?.stop();
                                  // print(
                                  //     " Timer Stopped >>>>>>>>>>>>>>> ${_timerService!._elapsedTime} Secs");
                                  showDialog(
                                      context: context,
                                      builder: (context) {
                                        return ConfirmPayDialog(onConfirm: () {
                                          _timerService!.stop();
                                          print(
                                              "Timer Stopped at >>>>>>>>> ${_timerService!._elapsedTime}");

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
                              //  _processMessages(messages);
                              handleIncomingMessages(messages, 
                              context, 
                              recentAccountNumber, 
                              recentPersonName, 
                              recentBankName, 
                              recentBankCode, 
                              accountService, 
                              _initializeTimer);
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
      SizedBox(height: 3.h),
      _buildDetailsContainer(
          context, accountHolder, accountNumber, bankName, amount,
          isChatDetails: false),
      SizedBox(height: 7.h),
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
            _buildDetailRow('Amount:', formatNairas(amount), 18.sp),
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
        onTap: () async {},
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
    BuildContext context,
    int totalTrades,
    int tradesMarkedAutomatic,
    int tradesMarkedWithNumbers,
    int tradesMarkedInvalid, // Add invalid trades
    double averageSpeed) {
  return Column(
    children: [
      Container(
        decoration: BoxDecoration(
          border: Border.all(width: 0.5),
          borderRadius: BorderRadius.circular(10),
        ),
        width: MediaQuery.of(context).size.width * 0.5, // Responsive width
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "Activity Stats",
                style: GoogleFonts.montserrat(
                  textStyle: TextStyle(
                    fontSize: 17, // Adjust font size as needed
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              SizedBox(height: 8),
              _buildStatRow('Total Trades: ', totalTrades.toString(), 12),
              Divider(),
              _buildStatRow(
                  'Trades Unmarked: ', tradesMarkedAutomatic.toString(), 12),
              Divider(),
              _buildStatRow(
                  'Trades Marked: ', tradesMarkedWithNumbers.toString(), 12),
              Divider(),
              _buildStatRow('Invalid Trades: ', tradesMarkedInvalid.toString(),
                  12), // Display invalid trades
              Divider(),
              _buildStatRow('Total Speed: ',
                  '${averageSpeed.toStringAsFixed(2)} sec', 14),
            ],
          ),
        ),
      ),
    ],
  );
}

Widget _buildStatRow(String title, String value, double fontSize) {
  return Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
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

class TimerService {
  Timer? _timer;
  int _elapsedTime = 0;
  final void Function(int) onTick;
  final int duration;
  final Future<void> Function() onComplete;

  TimerService({
    required this.onTick,
    required this.duration,
    required this.onComplete,
  });

  // Start the timer only if no timer is currently running
  void start() {
    // Prevent starting another timer if one is already running
    if (_timer != null && _timer!.isActive) {
      print("Timer is already running.");
      return;
    }

    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      _elapsedTime++;
      onTick(_elapsedTime);
      print('Elapsed time: $_elapsedTime seconds');

      if (_elapsedTime >= duration) {
        stop();
        onComplete();
      }
    });

    print("Timer started.");
  }

  // Stop the timer and reset it properly
  void stop({bool resetTime = false}) {
    if (_timer != null) {
      _timer!.cancel();
      _timer = null; // Ensure the timer is set to null after stopping
      print("Timer stopped at $_elapsedTime seconds");
    }

    if (resetTime) {
      _elapsedTime = 0;
    }
  }

  int getElapsedTime() => _elapsedTime;
}
