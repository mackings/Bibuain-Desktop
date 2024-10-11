import 'package:flutter/material.dart';
import 'package:bdesktop/Performance/model/model.dart';
import 'package:intl/intl.dart';

class StaffDetailPage extends StatelessWidget {
  final StaffPerformanceModel staff;

  StaffDetailPage({required this.staff});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(staff.name), // Display staff name in the AppBar
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                // Left-side container with salary and other details
                Container(
                  padding: const EdgeInsets.all(16),
                  width: MediaQuery.of(context).size.width * 0.3,
                  decoration: BoxDecoration(
                    color: Colors.blue.shade900,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildProfileDetail("Basic Salary", "70,000"),
                      _buildProfileDetail("Leave Bonus", "10 days"),
                      _buildProfileDetail("Total Savings", "12,000"),
                      _buildProfileDetail("HMO", "Inactive"),
                    ],
                  ),
                ),
                SizedBox(width: 16),


                // Profile overview and stats
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Profile overview
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _buildOverviewCard(context, "Total Trade", "${staff.assignedTrades.length}"),
                          _buildOverviewCard(context, "Amount Spent", "${_calculateTotalAmountSpent(staff.assignedTrades)}"),
                          _buildOverviewCard(context, "Average Speed", "23s"),
                        ],
                      ),
                      SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _buildCircularPercentageChart(context),
                          _buildScoreBoard(context),
                          _buildAssessmentSheet(context),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _calculateTotalAmountSpent(List<AssignedTrade> assignedTrades) {
    double total = 0.0;

    for (var trade in assignedTrades) {
      // Convert amountPaid to double and accumulate
      total += double.tryParse(trade.amountPaid) ?? 0.0; // Handle possible parsing errors
    }

    // Format total in Naira with thousand separators
    final formatter = NumberFormat.currency(locale: 'en_NG', symbol: '₦', decimalDigits: 0);
    return formatter.format(total); // Format total with Naira symbol
  }




  // Helper function to build profile details
  Widget _buildProfileDetail(String title, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: TextStyle(color: Colors.white)),
          Text(value, style: TextStyle(color: Colors.white)),
        ],
      ),
    );
  }

  // Helper function to build overview cards
  Widget _buildOverviewCard(BuildContext context, String title, String value) {
    return Container(
      padding: const EdgeInsets.all(16),
      width: MediaQuery.of(context).size.width * 0.20,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(width: 0.5)

      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          SizedBox(height: 8),
          Text(value, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  // Circular percentage chart placeholder (you can customize or use any chart package)
  Widget _buildCircularPercentageChart(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      width: MediaQuery.of(context).size.width * 0.25,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            spreadRadius: 2,
            blurRadius: 5,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Trade Percentage", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          SizedBox(height: 8),
          // Add a circular progress indicator or pie chart here
          Text("9 Payer in Total", style: TextStyle(fontSize: 16)),
        ],
      ),
    );
  }

  // Scoreboard section placeholder
  Widget _buildScoreBoard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      width: MediaQuery.of(context).size.width * 0.25,
      decoration: BoxDecoration(
        color: Colors.blue.shade800,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            spreadRadius: 2,
            blurRadius: 5,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Score Board", style: TextStyle(fontSize: 16, color: Colors.white)),
          SizedBox(height: 8),
          _buildScoreRow("Attendance", "10"),
          _buildScoreRow("Punctuality", "10"),
          _buildScoreRow("Payment", "10"),
          _buildScoreRow("Assessment", "20"),
          _buildScoreRow("O.T Exam", "40%"),
        ],
      ),
    );
  }

  Widget _buildScoreRow(String title, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: TextStyle(color: Colors.white)),
        Text(value, style: TextStyle(color: Colors.white)),
      ],
    );
  }

  // Assessment sheet placeholder
  Widget _buildAssessmentSheet(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      width: MediaQuery.of(context).size.width * 0.25,
      decoration: BoxDecoration(
        color: Colors.blue.shade800,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            spreadRadius: 2,
            blurRadius: 5,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Assessment Sheet", style: TextStyle(fontSize: 16, color: Colors.white)),
          SizedBox(height: 8),
          _buildAssessmentRow("Attendance", "6572/6500"),
          _buildAssessmentRow("Avg Speed", "23s/30s"),
          _buildAssessmentRow("Trade%", "60%"),
          _buildAssessmentRow("Speed%", "23%"),
          _buildAssessmentRow("Score", "85%"),
        ],
      ),
    );
  }

  Widget _buildAssessmentRow(String title, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: TextStyle(color: Colors.white)),
        Text(value, style: TextStyle(color: Colors.white)),
      ],
    );
  }
}
