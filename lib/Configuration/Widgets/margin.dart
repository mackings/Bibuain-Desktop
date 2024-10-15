import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class MarginDisplayWidget extends StatelessWidget {
  final String marginDisplay;
  final VoidCallback onUpdate;

  const MarginDisplayWidget({
    Key? key,
    required this.marginDisplay,
    required this.onUpdate,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Calculate sizes based on screen width (responsive)
        double containerWidth = constraints.maxWidth * 0.35; // 35% of the width
        double containerHeight = constraints.maxHeight * 0.25; // 25% of the height
        double fontSize = constraints.maxWidth * 0.08; // Dynamic font size

        return Container(
          width: containerWidth > 150 ? containerWidth : 150, // Ensure minimum width of 150
          height: containerHeight > 130 ? containerHeight : 130, // Ensure minimum height of 130
          decoration: BoxDecoration(
            color: Colors.purpleAccent,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 10),
                  child: Align(
                    alignment: Alignment.topLeft,
                    child: GestureDetector(
                      onTap: onUpdate, // Trigger callback on tap
                      child: Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFF030832),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(width: 0.5),
                        ),
                        child: const Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Text(
                            'Update Margin',
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                // Display the dynamic margin here
                Text(
                  marginDisplay,
                  style: GoogleFonts.montserrat(
                    fontSize: fontSize > 36 ? fontSize : 36, // Ensure minimum font size
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
