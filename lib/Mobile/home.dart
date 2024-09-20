import 'dart:convert';
import 'package:bdesktop/Mobile/fund.dart';
import 'package:bdesktop/Mobile/history.dart';
import 'package:bdesktop/Mobile/send.dart';
import 'package:bdesktop/Mobile/widgets/scroll.dart';
import 'package:bdesktop/widgets/colors.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

class Apphome extends StatefulWidget {
  final String username;

  const Apphome({Key? key, required this.username}) : super(key: key);

  @override
  State<Apphome> createState() => _ApphomeState();
}

class _ApphomeState extends State<Apphome> {
  List<dynamic> transactionHistory = [];
  bool isLoading = true;

  int _selectedIndex = 0;

  // This method will handle the bottom navigation item taps
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    // You can perform different actions or navigate to different screens here
    switch (index) {
      case 0:
        // Handle "Home" tap
        print('Home tapped');
        break;
      case 1:
        // Handle "Send" tap
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => SendMoney()));
        break;
      case 2:
        // Handle "Pay" tap
        print('Pay tapped');
        break;
      case 3:
        // Handle "Cards" tap
        print('Cards tapped');
        break;
      case 4:
        // Handle "More" tap
        print('More tapped');
        break;
    }
  }

  @override
  void initState() {
    super.initState();
    fetchTransactionHistory();
  }

  Future<void> fetchTransactionHistory() async {
    final url = Uri.parse(
        'https://tester-1wva.onrender.com/staff/${widget.username}/history');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print(data);
        setState(() {
          transactionHistory =
              data['data'].reversed.toList(); // Reverse the list here
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
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        automaticallyImplyLeading: false,
        title: Text(
          'Hi, ${widget.username}',
          style:
              GoogleFonts.montserrat(fontWeight: FontWeight.w700, fontSize: 17),
        ),
        actions: [
          Icon(Icons.message_sharp, color: myColor),
          SizedBox(width: 30),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.only(left: 20, right: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 10,
            ),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                    decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(width: 0.5, color: Colors.black),
                        borderRadius: BorderRadius.circular(10)),
                    child: Padding(
                      padding: const EdgeInsets.only(
                          left: 10, right: 10, top: 7, bottom: 7),
                      child: Text(
                        'Spend',
                        style: GoogleFonts.montserrat(
                            fontWeight: FontWeight.w600,
                            fontSize: 9,
                            color: Colors.black),
                      ),
                    )),
                Container(
                    decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(width: 0.5, color: Colors.black),
                        borderRadius: BorderRadius.circular(10)),
                    child: Padding(
                      padding: const EdgeInsets.only(
                          left: 20, right: 20, top: 7, bottom: 7),
                      child: Text(
                        'Save',
                        style: GoogleFonts.montserrat(
                            fontWeight: FontWeight.w600,
                            fontSize: 9,
                            color: Colors.black),
                      ),
                    )),
                Container(
                    decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(width: 0.5, color: Colors.black),
                        borderRadius: BorderRadius.circular(10)),
                    child: Padding(
                      padding: const EdgeInsets.only(
                          left: 20, right: 20, top: 7, bottom: 7),
                      child: Text(
                        'Borrow',
                        style: GoogleFonts.montserrat(
                            fontWeight: FontWeight.w600,
                            fontSize: 9,
                            color: Colors.black),
                      ),
                    )),
                Container(
                    decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(width: 0.5, color: Colors.black),
                        borderRadius: BorderRadius.circular(10)),
                    child: Padding(
                      padding: const EdgeInsets.only(
                          left: 20, right: 20, top: 7, bottom: 7),
                      child: Text(
                        'Invest',
                        style: GoogleFonts.montserrat(
                            fontWeight: FontWeight.w600,
                            fontSize: 9,
                            color: Colors.black),
                      ),
                    )),
              ],
            ),

            SizedBox(
              height: 15,
            ),

            Text(
              "Nigerian Naira",
              style: GoogleFonts.montserrat(
                  fontWeight: FontWeight.w600, fontSize: 13),
            ),
            SizedBox(
              height: 10,
            ),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "N1,000,000",
                  style: GoogleFonts.montserrat(
                      fontWeight: FontWeight.w700, fontSize: 20),
                ),
                CircleAvatar(
                  radius: 15,
                  child: Center(child: Text("...")),
                )
              ],
            ),

            SizedBox(
              height: 10,
            ),

            Text(
              "Last updated 1 mins 1sec ago",
              style: GoogleFonts.montserrat(color: Colors.grey),
            ),

            SizedBox(
              height: 20,
            ),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                GestureDetector(
                  onTap: () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) => Fund()));
                  },
                  child: Container(
                    height: MediaQuery.of(context).size.height *
                        0.06, // Responsive height
                    width: MediaQuery.of(context).size.width *
                        0.35, // Responsive width
                    decoration: BoxDecoration(
                      border: Border.all(width: 1.5, color: Colors.black),
                      borderRadius: BorderRadius.circular(6),
                      color: Colors.white,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Container(
                          decoration: BoxDecoration(
                              shape: BoxShape.circle, color: myColor),
                          child: Center(
                            child: Icon(
                              Icons.keyboard_arrow_up,
                              color: Colors.white,
                              size: MediaQuery.of(context).size.width *
                                  0.05, // Responsive icon size
                            ),
                          ),
                        ),
                        Text(
                          "Transfer",
                          style: GoogleFonts.montserrat(
                            color: myColor,
                            fontWeight: FontWeight.w600,
                            fontSize: MediaQuery.of(context).size.width *
                                0.04, // Responsive font size
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Container(
                  height: MediaQuery.of(context).size.height *
                      0.06, // Responsive height
                  width: MediaQuery.of(context).size.width *
                      0.35, // Responsive width
                  decoration: BoxDecoration(
                    border: Border.all(width: 1.5, color: Colors.black),
                    borderRadius: BorderRadius.circular(6),
                    color: Colors.white,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: myColor,
                        ),
                        child: Center(
                          child: Icon(
                            Icons.add,
                            color: Colors.white,
                            size: MediaQuery.of(context).size.width *
                                0.05, // Responsive icon size
                          ),
                        ),
                      ),
                      Text(
                        "Add Mon...",
                        style: GoogleFonts.montserrat(
                          color: myColor,
                          fontWeight: FontWeight.w600,
                          fontSize: MediaQuery.of(context).size.width *
                              0.04, // Responsive font size
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(
              height: 15,
            ),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Quick Access",
                  style: GoogleFonts.montserrat(),
                ),
                Text(
                  "Edit",
                  style: GoogleFonts.montserrat(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            SizedBox(
              height: 15,
            ),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                buildContainer(Icons.phone, 'Airtime', Colors.yellow),
                buildContainer(Icons.wifi, 'Internet', Colors.orange),
                buildContainer(Icons.wallet, 'Betting', Colors.blue),
                buildContainer(Icons.light, 'Electrici..', Colors.orange),
              ],
            ),

            SizedBox(
              height: 15,
            ),

            SizedBox(height: 15),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Transactions",
                  style: GoogleFonts.montserrat(fontWeight: FontWeight.bold),
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => Transactions()));
                  },
                  child: Text(
                    "View all",
                    style: GoogleFonts.montserrat(
                        fontWeight: FontWeight.bold, color: myColor),
                  ),
                ),
              ],
            ),
            SizedBox(height: 15),

            // Transaction History
            isLoading
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
                    : Expanded(
  child: Padding(
  padding: const EdgeInsets.all(8.0),
  child: ListView.builder(
    itemCount: transactionHistory.length,
    itemBuilder: (context, index) {
      final transaction = transactionHistory[index];

      // Apply all filter conditions
      if (transaction['name'] == 'No Name' ||
          transaction['amountPaid'] == '0' || 
          transaction['amountPaid'] == 'Pending' ||
          (transaction['markedAt'] == 'Automatic' || 
           transaction['markedAt'] == 'Pending' || 
           transaction['markedAt'] == 'complain')) {
        return SizedBox.shrink(); // Skips rendering this item
      }

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
              "N${transaction['amountPaid'] != null ? NumberFormat('#,##0').format(double.tryParse(transaction['amountPaid'].toString()) ?? 0) : 'Pending'}",
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
                "${formatTimestamp(transaction['assignedAt'])}",
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
),

          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        elevation: 15,
        type: BottomNavigationBarType.fixed,
        currentIndex: _selectedIndex, // Set the current selected index
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(
              icon: Icon(Icons.telegram_sharp), label: "Send"),
          BottomNavigationBarItem(
              icon: Icon(Icons.payments_rounded), label: "Pay"),
          BottomNavigationBarItem(
              icon: Icon(Icons.credit_card), label: "Cards"),
          BottomNavigationBarItem(
              icon: Icon(Icons.dashboard_customize), label: "More"),
        ],
      ),
    );
  }
}

Widget buildContainer(IconData icon, String label, Color iconColor) {
  return Container(
    decoration: BoxDecoration(
      color: Colors.white,
      border: Border.all(width: 0.5, color: Colors.black),
      borderRadius: BorderRadius.circular(10),
    ),
    child: Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          Icon(icon, size: 20, color: iconColor), // Use iconColor here
          SizedBox(height: 5),
          Text(
            label,
            style: GoogleFonts.montserrat(
                fontWeight: FontWeight.w600, color: Colors.black, fontSize: 12),
          ),
        ],
      ),
    ),
  );
}
