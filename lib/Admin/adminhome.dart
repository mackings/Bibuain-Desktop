import 'package:bdesktop/Admin/widgets/widget.dart';
import 'package:flutter/material.dart';

class Adminhome extends StatefulWidget {
  const Adminhome({super.key});

  @override
  State<Adminhome> createState() => _AdminhomeState();
}

class _AdminhomeState extends State<Adminhome> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
      ),
      body: Padding(
        padding: const EdgeInsets.only(left: 20,right: 20),
        child: Column(
          children: [ 
        
            Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                StatCard(
                  icon: Icons.attach_money,
                  title: "Current Month",
                  value: "\$9243.34",
                  percentageChange: "+5.24%",
                  positiveChange: true,
                ),
                StatCard(
                  icon: Icons.book,
                  title: "Course Sell",
                  value: "824 Course",
                  percentageChange: "+1.86%",
                  positiveChange: true,
                ),
                StatCard(
                  icon: Icons.school,
                  title: "Students this Month",
                  value: "1124 Student",
                  percentageChange: "-2.32%",
                  positiveChange: false,
                ),
                StatCard(
                  icon: Icons.visibility,
                  title: "Profile Views",
                  value: "2414",
                  percentageChange: "+24.1%",
                  positiveChange: true,
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