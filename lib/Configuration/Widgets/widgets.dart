import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class PriceContainer extends StatelessWidget {
  final String cpLabel; // For "CP"
  final String spLabel; // For "SP"
  final String cpPrice; // Cost Price
  final String spPrice; // Selling Price

  const PriceContainer({
    Key? key,
    required this.cpLabel,
    required this.spLabel,
    required this.cpPrice,
    required this.spPrice,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // CP (Cost Price) Container
        Stack(
          children: [
            // Long Container (Price)
            Container(
              margin: const EdgeInsets.only(left: 50, top: 10), // Aligns it with the small CP container
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Color(0xFF030832),
                borderRadius: BorderRadius.circular(12),
              ),
              width: 250, // Long container
              child: Text(
                '$cpPrice NGN BTC',
                style: GoogleFonts.montserrat(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
            // Small CP Container
            Container(
              padding: const EdgeInsets.all(8.0),
              decoration: BoxDecoration(
                color: Colors.blue,
                borderRadius: BorderRadius.circular(8),
              ),
              width: 40,
              child: Center(
                child: Text(
                  cpLabel,
                  style: GoogleFonts.montserrat(
                    fontSize: 14,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 20), // Space between CP and SP containers
        // SP (Selling Price) Container
        Stack(
          children: [
            // Long Container (Price)
            Container(
              margin: const EdgeInsets.only(left: 50, top: 10), // Aligns it with the small SP container
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Color(0xFF030832),
                borderRadius: BorderRadius.circular(12),
              ),
              width: 250, // Long container
              child: Text(
                '$spPrice NGN BTC',
                style: GoogleFonts.montserrat(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
            // Small SP Container
            Container(
              padding: const EdgeInsets.all(8.0),
              decoration: BoxDecoration(
                color: Colors.grey,
                borderRadius: BorderRadius.circular(8),
              ),
              width: 40,
              child: Center(
                child: Text(
                  spLabel,
                  style: GoogleFonts.montserrat(
                    fontSize: 16,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}