import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart'; // Import for date formatting

class Transactions extends StatefulWidget {
  const Transactions({super.key});

  @override
  State<Transactions> createState() => _TransactionsState();
}

class _TransactionsState extends State<Transactions> {
  String? _username;
  List<dynamic> transactionHistory = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUsername();
  }

  Future<void> _loadUsername() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _username = prefs.getString('username');
    });
    if (_username != null) {
      await fetchTransactionHistory();
    }
  }

Future<void> fetchTransactionHistory() async {
  final url = Uri.parse('https://tester-1wva.onrender.com/staff/${_username}/history');
  try {
    final response = await http.get(url);
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        transactionHistory = data['data'].reversed.toList(); // Reverse the list here
        isLoading = false;
      });
    } else {
      // Handle error
      setState(() {
        isLoading = false;
      });
      print("Error: ${response.statusCode}");
    }
  } catch (e) {
    setState(() {
      isLoading = false;
    });
    print("Error: $e");
  }
}


String formatTimestamp(Map<String, dynamic> timestamp) {
  final seconds = timestamp['_seconds'] as int;
  final nanoseconds = timestamp['_nanoseconds'] as int;

  // Create a DateTime object in UTC, then convert to local time
  final date = DateTime.fromMillisecondsSinceEpoch(
    seconds * 1000 + nanoseconds ~/ 1000000,
    isUtc: true,
  ).toLocal(); // Convert to local time

  // Format the DateTime object in the desired format
  final formatter = DateFormat('MMMM d, h:mm a');
  return formatter.format(date);
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          'History',
          style: GoogleFonts.montserrat(
            fontWeight: FontWeight.w500,
            fontSize: 18,
          ),
        ),
        actions: [
          Icon(Icons.dashboard),
        ],
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : transactionHistory.isEmpty
              ? Center(
                  child: Text(
                    "No transaction history available",
                    style: GoogleFonts.montserrat(
                      fontSize: 16,
                      color: Colors.grey,
                    ),
                  ),
                )
              : Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ListView.builder(
                    itemCount: transactionHistory.length,
                    itemBuilder: (context, index) {
                      final transaction = transactionHistory[index];
                      return ListTile(
                        title: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              transaction['name'] ?? "Bibuain",
                              style: GoogleFonts.montserrat(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              "-N${transaction['amountPaid'] ?? 'Pending'}",
                              style: GoogleFonts.montserrat(
                                color: Colors.red,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (transaction['assignedAt'] != null)
                              Text(
                                "Paid on ${formatTimestamp(transaction['assignedAt'])}",
                                style: GoogleFonts.montserrat(color: Colors.grey),
                              )
                            else
                              Text(
                                "Paid in ${transaction['markedAt']} Seconds",
                                style: GoogleFonts.montserrat(color: Colors.grey),
                              ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
    );
  }
}
