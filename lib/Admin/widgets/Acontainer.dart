
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class AContainer extends StatelessWidget {

  final IconData icon;
  final String staffId;
  final String paidTrades;
  final String unpaidTrades;
  final String totalAssignedTrades;
  final String? mispaid;
  final Color backgroundColor;

  const AContainer({
    required this.icon,
    required this.staffId,
    required this.paidTrades,
    required this.unpaidTrades,
    required this.totalAssignedTrades,
    required this.mispaid,
    required this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    double mispaidValue = double.tryParse(mispaid ?? "0.00") ?? 0.0;
    final NumberFormat currencyFormat = NumberFormat('#,##0.00', 'en_US');
    final formattedMispaid = currencyFormat.format(mispaidValue);

    return Column(
      children: [
        Container(
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
        
              Row(
                children: [
        
                  CircleAvatar(child: Icon(icon, size: 28, color: Colors.black)),
                  SizedBox(width: 60),
                  Text(
                    " $staffId",
                    style: GoogleFonts.montserrat(color: Colors.black, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
        
              Divider(thickness: 1.5, height: 20, color: Colors.black),
        
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Icon(Icons.person_2),
                  SizedBox(width: 180,),
                  Text(
                    "$paidTrades",
                    style: GoogleFonts.montserrat(color: Colors.white,fontWeight: FontWeight.w600),
                  ),
                ],
              ),
              
               SizedBox(height: 4),
        
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Unpaid Trades:",
                    style: GoogleFonts.montserrat(color: Colors.black),
                  ),
                  SizedBox(width: 85,),
                   Text(
                    "$unpaidTrades",
                    style: GoogleFonts.montserrat(color: Colors.white,
                     fontWeight: FontWeight.w600),
                  ),
                ],
              ),
              
              SizedBox(height: 4),
        
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                      Text(
                    "Mispaid:",
                    style: GoogleFonts.montserrat(color: Colors.black),
                  ),
                  SizedBox(width: 50,),
                  Text(
                    "N$formattedMispaid",
                    style: GoogleFonts.montserrat(color: Colors.white,
                    fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
