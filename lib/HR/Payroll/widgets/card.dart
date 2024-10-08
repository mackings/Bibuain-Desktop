import 'package:flutter/material.dart';

class StatCard extends StatelessWidget {
  final String title;
  final String value;
  final String subValue;
  final Color iconColor;
  final IconData icon;
  final Color percentageColor;
  final String percentageText;

  const StatCard({
    Key? key,
    required this.title,
    required this.value,
    required this.subValue,
    required this.iconColor,
    required this.icon,
    required this.percentageColor,
    required this.percentageText,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      width: 390,
      height: 150,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(width: 0.5,color: Colors.grey)
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundColor: iconColor,
                child: Icon(icon, color: Colors.white),
              ),
              SizedBox(width: 10),
              Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          SizedBox(height: 20),
          Text(
            value,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          // SizedBox(height: 5),
          // Text(
          //   subValue,
          //   style: TextStyle(fontSize: 14, color: Colors.grey),
          // ),

        ],
      ),
    );
  }
}
