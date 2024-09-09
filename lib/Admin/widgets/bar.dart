import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class SimpleBarChart extends StatelessWidget {
  final int totalUnassignedTrades;

  SimpleBarChart({required this.totalUnassignedTrades});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Column(
          children: [
            BarChart(
              BarChartData(
                barGroups: [
                  BarChartGroupData(
                    x: 0,
                    barRods: [
                      BarChartRodData(
                        fromY: totalUnassignedTrades.toDouble(),
                        color: Colors.blue,
                        width: 20, toY: 90.0,
                      ),
                    ],
                  ),
                  // You can add more bars here
                ],
                titlesData: FlTitlesData(
                  show: true,
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (double value, TitleMeta meta) {
                        return Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text(
                            'Trade ${value.toInt() + 1}', // Displaying "Trade 1", "Trade 2", etc.
                            style: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false), // Hide left axis labels
                  ),
                  topTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false), // Hide top axis
                  ),
                  rightTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false), // Hide right axis
                  ),
                ),
                gridData: FlGridData(show: false), // Hide grid
                borderData: FlBorderData(show: false), // Hide chart borders
              ),
            ),
          ],
        ),
      ],
    );
  }
}
