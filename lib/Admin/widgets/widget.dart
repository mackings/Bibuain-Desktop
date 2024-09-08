import 'package:flutter/material.dart';

// Reusable StatCard Widget
class StatCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final String percentageChange;
  final bool positiveChange;

  const StatCard({
    Key? key,
    required this.icon,
    required this.title,
    required this.value,
    required this.percentageChange,
    required this.positiveChange,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 24, color: Colors.grey),
              SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[700],
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          SizedBox(height: 8),
          Row(
            children: [
              Icon(
                positiveChange ? Icons.arrow_upward : Icons.arrow_downward,
                color: positiveChange ? Colors.green : Colors.red,
                size: 16,
              ),
              SizedBox(width: 4),
              Text(
                percentageChange,
                style: TextStyle(
                  color: positiveChange ? Colors.green : Colors.red,
                  fontSize: 14,
                ),
              ),
              SizedBox(width: 4),
              Text(
                "vs last month",
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
