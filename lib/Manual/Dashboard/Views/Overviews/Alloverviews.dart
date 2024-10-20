import 'package:bdesktop/Manual/Dashboard/Api/StaffService.dart';
import 'package:bdesktop/Manual/Dashboard/Model/staffmodel.dart';
import 'package:bdesktop/Manual/Dashboard/widgets/OverviewCard.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sizer/sizer.dart';
import 'package:http/http.dart' as http;

class ALLStaffOverview extends StatefulWidget {
  const ALLStaffOverview({Key? key}) : super(key: key);

  @override
  State<ALLStaffOverview> createState() => _StaffOverviewState();
}

class _StaffOverviewState extends State<ALLStaffOverview> {
  int totalAssignedTrades = 0;
  int totalPaidTrades = 0;
  double totalMispaidTrades = 0;
  double totalSpeed = 0.0;
  double averageSpeed = 0.0;

  final StaffOverviewService _staffApiService = StaffOverviewService();
  StaffData? staff;
  String? username;

  @override
  void initState() {
    super.initState();
    fetchUsernameAndData(); // Fetch username and data when the widget is initialized
  }

  Future<void> fetchUsernameAndData() async {
    // Fetch username from SharedPreferences
    SharedPreferences prefs = await SharedPreferences.getInstance();
    username = prefs.getString('username'); // Retrieve the username

    if (username != null && username!.isNotEmpty) {
      await fetchStaffData(
          username!); // Call fetchStaffData with the fetched username
    } else {
      print('No username found in preferences');
    }
  }

  Future<void> fetchStaffData(String username) async {
    StaffResponse? response = await _staffApiService.fetchStaffData(username);

    if (response != null && response.success) {
      staff = response.data;

      setState(() {
        totalAssignedTrades = staff!.assignedTrades.length;

        // Count the total number of paid trades
        totalPaidTrades = staff!.assignedTrades
            .where((trade) => trade.isPaid && trade.amountPaid != null)
            .length;

        // Calculate total mispaid trades
        totalMispaidTrades = staff!.assignedTrades
            .where((trade) =>
                double.tryParse(trade.amountPaid?.toString() ?? '0') !=
                double.tryParse(trade.fiatAmountRequested.toString()))
            .length
            .toDouble();

        // Calculate total speed
        totalSpeed = staff!.assignedTrades
            .where((trade) =>
                trade.markedAt != null &&
                !trade.markedAt!.contains('complain')) // Filter out 'complain'
            .map((trade) =>
                double.tryParse(trade.markedAt!) ?? 0) // Convert to double
            .fold(0.0, (sum, speed) => sum + speed); // Sum speeds

        // Count valid trades for average calculation
        int speedCount = staff!.assignedTrades
            .where((trade) =>
                trade.markedAt != null && !trade.markedAt!.contains('complain'))
            .length; // Count valid trades

        // Calculate average speed
        averageSpeed = speedCount > 0
            ? totalSpeed / speedCount
            : 0; // Avoid division by zero
      });
    } else {
      print('Failed to load staff data: ${response?.message}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Sizer(
      builder: (context, orientation, deviceType) {
        return Scaffold(
          body: SingleChildScrollView(
            // Make the entire body scrollable
            padding: EdgeInsets.all(16.sp),
            child: LayoutBuilder(
              builder: (context, constraints) {
                bool isWideScreen = constraints.maxWidth > 600;

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "General Overview",
                      style: GoogleFonts.montserrat(
                        fontSize: 10.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 3.h),

                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          // First StatCard
                          Container(
                            width:
                                40.w, // Make the card responsive to screen size
                            child: OverviewCard(
                              title: 'Total Assigned Trades',
                              value: totalAssignedTrades.toString(),
                              icon: Icons.group,
                              backgroundColor: Color(0xFF7B61FF),
                            ),
                          ),
                          SizedBox(width: 2.w),

                          // Second StatCard
                          Container(
                            width: 40.w,
                            child: OverviewCard(
                              title: 'Total Paid Trades',
                              value:
                                  '${totalPaidTrades.toString()}', // Format to 2 decimal places
                              icon: Icons.receipt,
                              backgroundColor: Color(0xFF61A0FF),
                            ),
                          ),
                          SizedBox(width: 2.w),

                          // Third StatCard
                          Container(
                            width: 40.w,
                            child: OverviewCard(
                              title: 'Total Mispaid Trades',
                              value: totalMispaidTrades
                                  .toStringAsFixed(0), // Display as a count
                              icon: Icons.attach_money,
                              backgroundColor: Color(0xFFFF6961),
                            ),
                          ),
                          SizedBox(width: 2.w),

                          // Fourth StatCard (new card)
                          Container(
                            width: 40.w,
                            child: OverviewCard(
                              title: 'Average Speed',
                              value: averageSpeed.toStringAsFixed(
                                  2), // Show two decimal places
                              icon: Icons.speed,
                              backgroundColor: Color(0xFFFFC107),
                            ),
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: 16.sp),

// Transaction History Section

                    Text(
                      "Transactions",
                      style: GoogleFonts.montserrat(
                        fontSize: 10.sp,
                        fontWeight: FontWeight.w600
                      ),
                    ),
                    SizedBox(height: 15.sp),

                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12.sp),
                        color: Colors.white,
                        border: Border.all(color: Colors.black, width: 0.5),
                      ),
                      padding: EdgeInsets.all(16.sp),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Table with Titles
                          Table(
                            columnWidths: const {
                              0: FlexColumnWidth(
                                  2), // Adjust the width ratios as needed
                              1: FlexColumnWidth(2),
                              2: FlexColumnWidth(2),
                              3: FlexColumnWidth(2),
                              4: FlexColumnWidth(2),
                              5: FlexColumnWidth(2),
                              6: FlexColumnWidth(2),
                            },
                            // Remove vertical lines
                            border: TableBorder(
                              horizontalInside: BorderSide(
                                  color: Colors.grey.withOpacity(0.5)),
                              bottom: BorderSide(color: Colors.grey),
                              // No vertical lines
                              left: BorderSide.none,
                              right: BorderSide.none,
                              top: BorderSide.none,
                            ),
                            children: [
                              // Titles for the columns with extra padding
                              TableRow(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(
                                        bottom: 15.0), // Add bottom padding
                                    child: Text("Account",
                                        style: GoogleFonts.montserrat(
                                            fontWeight: FontWeight.bold)),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(
                                        bottom: 8.0), // Add bottom padding
                                    child: Text("Amount (N)",
                                        style: GoogleFonts.montserrat(
                                            fontWeight: FontWeight.bold)),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(
                                        bottom: 8.0), // Add bottom padding
                                    child: Text("Paid (N)",
                                        style: GoogleFonts.montserrat(
                                            fontWeight: FontWeight.bold)),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(
                                        bottom: 8.0), // Add bottom padding
                                    child: Text("Handle",
                                        style: GoogleFonts.montserrat(
                                            fontWeight: FontWeight.bold)),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(
                                        bottom: 8.0), // Add bottom padding
                                    child: Text("Marked",
                                        style: GoogleFonts.montserrat(
                                            fontWeight: FontWeight.bold)),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(
                                        bottom: 8.0), // Add bottom padding
                                    child: Text("Assigned",
                                        style: GoogleFonts.montserrat(
                                            fontWeight: FontWeight.bold)),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(
                                        bottom: 8.0), // Add bottom padding
                                    child: Text("Hash",
                                        style: GoogleFonts.montserrat(
                                            fontWeight: FontWeight.bold)),
                                  ),
                                ],
                              ),

                              // Scrollable List of Assigned Trades
...staff?.assignedTrades.map((trade) {
  return TableRow(
    children: [
      Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0), // Add vertical padding
        child: Text(trade.account, style: GoogleFonts.montserrat()),
      ),
      Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0), // Add vertical padding
        child: Text(
          NumberFormat('#,##0').format(double.parse(trade.fiatAmountRequested)),
          style: GoogleFonts.montserrat(),
        ),
      ),
      Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0), // Add vertical padding
        child: Text(
          trade.amountPaid != null
              ? NumberFormat('#,##0').format(double.tryParse(trade.amountPaid.toString()) ?? 0)
              : "Not Paid",
          style: GoogleFonts.montserrat(),
        ),
      ),
      Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0), // Add vertical padding
        child: Text(trade.handle, style: GoogleFonts.montserrat()),
      ),
      Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0), // Add vertical padding
        child: Text(trade.markedAt ?? "Current", style: GoogleFonts.montserrat(color: Colors.red)),
      ),
      Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0), // Add vertical padding
        child: Text(
          DateFormat('MMM d, h:mm a').format(
            DateTime.parse(trade.assignedAt).add(Duration(hours: 1)) // Adjust the assignedAt time
          ),
          style: GoogleFonts.montserrat(),
        ),
      ),
      Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0), // Add vertical padding
        child: SelectableText(trade.tradeHash, style: GoogleFonts.montserrat()),
      ),
    ],
  );
}).toList() ?? [],

                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        );
      },
    );
  }
}
