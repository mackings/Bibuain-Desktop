import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class StatsContainer extends StatelessWidget {

  final IconData icon;
  final String staffId;
  final String speed;
  final String paidTrades;
  final String unpaidTrades;
  final String totalAssignedTrades;
  final String? mispaid;
  final Color backgroundColor;

  const StatsContainer({
    required this.icon,
    required this.staffId,
    required this.speed,
    required this.paidTrades,
    required this.unpaidTrades,
    required this.totalAssignedTrades,
    required this.mispaid,
    required this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    // Convert mispaid to double and handle potential null value
    double mispaidValue = double.tryParse(mispaid ?? "0.00") ?? 0.0;

    // Format the amount with thousand separators
    final NumberFormat currencyFormat = NumberFormat('#,##0.00', 'en_US');
    final formattedMispaid = currencyFormat.format(mispaidValue);

    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(width: 0.5, color: Colors.black),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(child: Icon(icon, size: 28, color: Colors.black)),
              SizedBox(width: 10),
              Text(
                " $staffId",
                style: GoogleFonts.montserrat(color: Colors.black, fontWeight: FontWeight.w600),
              ),
            ],
          ),
          Divider( color: Colors.grey),
          SizedBox(height: 8),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(Icons.speed_sharp),
              SizedBox(width: 10),
              Text(
                speed == "null"? "0":speed,
                style: GoogleFonts.montserrat(color: Colors.black),
              ),
            ],
          ),

          SizedBox(height: 4),

          Row(
             mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [

              Text(
                "Paid Trades",
                style: GoogleFonts.montserrat(color: Colors.black),
              ),

               Text(
                "$paidTrades",
                style: GoogleFonts.montserrat(color: Colors.black),
              ),

            ],
          ),

          SizedBox(height: 4),

          Row(
             mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Unpaid Trades",
                style: GoogleFonts.montserrat(color: Colors.black),
              ),

               Text(
                "$unpaidTrades",
                style: GoogleFonts.montserrat(color: Colors.black),
              ),
            ],
          ),
          SizedBox(height: 4),

          Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Total Assigned Trades",
                style: GoogleFonts.montserrat(color: Colors.black),
              ),

                            Text(
                " $totalAssignedTrades",
                style: GoogleFonts.montserrat(color: Colors.black),
              ),
            ],
          ),

          SizedBox(height: 8),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [

               Text(
                "Mispaid:",
                style: GoogleFonts.montserrat(color: Colors.black),
              ),

              SizedBox(width: 30,),

               Text(
                "$mispaid",
                style: GoogleFonts.montserrat(color: Colors.black,
                fontWeight: FontWeight.w600),
              ),

              // Text(
              //   "N$formattedMispaid",
              //   style: GoogleFonts.montserrat(color: Colors.black,
              //   fontWeight: FontWeight.w600),
              // ),

            ],
          ),
        ],
      ),
    );
  }
}
