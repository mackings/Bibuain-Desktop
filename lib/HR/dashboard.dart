import 'package:bdesktop/HR/Apiservice.dart';
import 'package:bdesktop/HR/Payroll/createpayroll.dart';
import 'package:bdesktop/HR/Query/queryhome.dart';
import 'package:bdesktop/HR/models/staffmodel.dart';
import 'package:bdesktop/HR/widgets/activewidgets.dart';
import 'package:bdesktop/HR/widgets/widget.dart';
import 'package:bdesktop/Manual/Api%20services/clockinApi.dart';
import 'package:bdesktop/Performance/views/performanced.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class HR extends StatefulWidget {
  final String? username;
  const HR({Key? key, required this.username}) : super(key: key);

  @override
  State<HR> createState() => _HRState();
}

class _HRState extends State<HR> {
  List<Staff> staffList = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchStaffData();
  }

  Future<void> fetchStaffData() async {
    try {
      StaffApiService apiService = StaffApiService();
      staffList = await apiService.fetchStaffs();
    } catch (e) {
      print("Error fetching staff data: $e");
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF030832),
        automaticallyImplyLeading: false,
        title: Text(
          "Human Resources",
          style: GoogleFonts.montserrat(
              fontWeight: FontWeight.w600, color: Colors.white),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 30),
            child: Row(
              children: [
                Text(
                  "Hello",
                  style: GoogleFonts.montserrat(
                      fontWeight: FontWeight.w600, color: Colors.white),
                ),
                SizedBox(width: 10),
                Text(
                  "${widget.username}",
                  style: GoogleFonts.montserrat(
                      fontWeight: FontWeight.w600, color: Colors.white),
                ),
              ],
            ),
          ),
        ],
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                children: [
                  SizedBox(height: 50),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      DashboardCard(
                        title: "Team Performance",
                        iconData: Icons.bar_chart,
                        color: Colors.purple,
                        bcolor: Color(0xFFD9D9D9),
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => Performancedashboard())
                           );
                        },
                      ),
                      DashboardCard(
                        title: "All Staffs",
                        iconData: Icons.people_outline,
                        color: Colors.blue,
                        bcolor: Color(0xFFDAF9FF),
                        onTap: () {},
                      ),
                      DashboardCard(
                        title: "Payroll",
                        iconData: Icons.account_balance_outlined,
                        color: Color(0xFFDB3C40),
                        bcolor: Color(0xFFFFD4D0),
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => Createpayroll())
                           );
                        },
                      ),
                      DashboardCard(
                        title: "Messages",
                        iconData: Icons.chat_sharp,
                        color: Color(0xFFFEA500),
                        bcolor: Color(0xFFFFEAD0),
                        onTap: () {

                         Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => Queryhome())
                           );
                        },
                      ),
                      DashboardCard(
                        title: "Query",
                        iconData: Icons.report_problem_outlined,
                        color: Color(0xFF2B7D05),
                        bcolor: Color(0xFFC0FFC2),
                        onTap: () {},
                      ),
                    ],
                  ),
                  SizedBox(height: 30),
                  
                  Padding(
                    padding: const EdgeInsets.only(left: 25, right: 25),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          flex: 1,
                          child: StaffInfoContainer(
                            title: "Active Staffs",
                            staffDetails: staffList,
                          ),
                        ),
                        SizedBox(width: 20),

                        
                        Expanded(
                          flex: 2,
                          child: Padding(
                            padding: const EdgeInsets.only(top: 100),
                            child: Container(
                              height: 220,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Builder(
                                builder: (context) {
                                  double maxAssignedTrades =
                                      staffList.isNotEmpty
                                          ? staffList
                                              .map((staff) => staff
                                                  .assignedTrades.length
                                                  .toDouble())
                                              .reduce((a, b) => a > b ? a : b)
                                          : 0.0;

                                  double maxY = maxAssignedTrades > 0
                                      ? maxAssignedTrades * 1.2
                                      : 150;

                                  if (staffList.isEmpty) {
                                    return Center(
                                      child: Text(
                                        'No data available',
                                        style: TextStyle(
                                            fontSize: 16, color: Colors.black),
                                      ),
                                    );
                                  }

                                  return BarChart(
                                    BarChartData(
                                      alignment: BarChartAlignment.spaceAround,
                                      maxY: maxY,
                                      barTouchData: BarTouchData(
                                        enabled: true,
                                        touchTooltipData: BarTouchTooltipData(
                                          getTooltipItem: (group, groupIndex,
                                              rod, rodIndex) {
                                            final staff = staffList[groupIndex];
                                            final assignedTradesCount = staff
                                                .assignedTrades.length
                                                .toDouble();

                                            return BarTooltipItem(
                                              'Assigned Trades: ${assignedTradesCount.toStringAsFixed(2)}',
                                              TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 14,
                                              ),
                                            );
                                          },
                                        ),
                                      ),
                                      gridData: FlGridData(show: true),
                                      titlesData: FlTitlesData(
                                        show: true,
                                        topTitles: AxisTitles(
                                          sideTitles:
                                              SideTitles(showTitles: false),
                                        ),
                                        bottomTitles: AxisTitles(
                                          sideTitles: SideTitles(
                                            showTitles: true,
                                            reservedSize: 30,
                                            getTitlesWidget: (value, meta) {
                                              final int index = value.toInt();
                                              if (index >= 0 &&
                                                  index < staffList.length) {
                                                return Text(
                                                  staffList[index].name ??
                                                      'N/A',
                                                  style: GoogleFonts.montserrat(
                                                    fontWeight: FontWeight.w400,
                                                    color: Colors.black,
                                                  ),
                                                );
                                              }
                                              return Container();
                                            },
                                          ),
                                        ),
                                        leftTitles: AxisTitles(
                                          sideTitles:
                                              SideTitles(showTitles: false),
                                        ),
                                        rightTitles: AxisTitles(
                                          sideTitles:
                                              SideTitles(showTitles: false),
                                        ),
                                      ),
                                      borderData: FlBorderData(show: false),
                                      barGroups: List.generate(staffList.length,
                                          (index) {
                                        final staff = staffList[index];
                                        final assignedTradesCount = staff
                                            .assignedTrades.length
                                            .toDouble();
                                        final normalizedCount =
                                            (assignedTradesCount /
                                                    (maxAssignedTrades > 0
                                                        ? maxAssignedTrades
                                                        : 1)) *
                                                maxY;

                                        return BarChartGroupData(
                                          x: index,
                                          barRods: [
                                            BarChartRodData(
                                              toY: 10, // Example static bar
                                              color: Colors.black,
                                              width: 15,
                                            ),
                                            BarChartRodData(
                                              toY: normalizedCount.clamp(
                                                  1.0, maxY),
                                              color: Colors.orange,
                                              width: 15,
                                            ),
                                          ],
                                        );
                                      }),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
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
