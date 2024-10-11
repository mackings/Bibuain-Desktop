import 'package:bdesktop/Performance/Api/staffperformance.dart';
import 'package:bdesktop/Performance/model/model.dart';
import 'package:bdesktop/Performance/views/details.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';



class Performancedashboard extends StatefulWidget {
  const Performancedashboard({super.key});

  @override
  State<Performancedashboard> createState() => _PerformancedashboardState();
}

class _PerformancedashboardState extends State<Performancedashboard> {

  List<dynamic> staffList = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchStaffList();
  }


  Future<void> fetchStaffList() async {
    final service = StaffPerformanceService();
    try {
      final data = await service.fetchStaffs();
      setState(() {
        staffList = data;
        isLoading = false;
      });
    } catch (e) {
      print('Failed to load staff data: $e');
      setState(() {
        isLoading = false;
      });
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
  appBar: AppBar(
    backgroundColor: const Color(0xFF030832),
    iconTheme: const IconThemeData(
      color: Colors.white,
    ),
    title: Text(
      "Performance",
      style: GoogleFonts.montserrat(
      fontWeight: FontWeight.w600, color: Colors.white),
    ),
  ),
  body: isLoading
      ? const Center(child: CircularProgressIndicator())
      : staffList.isEmpty
          ? const Center(
              child: Text(
                'No data available',
                style: TextStyle(fontSize: 16, color: Colors.black),
              ),
            )
          : Padding(
              padding: const EdgeInsets.all(30.0),
              child: SingleChildScrollView(
                physics: BouncingScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start, 
                  children: [
                
                    const SizedBox(height: 16),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [

                           Text("Team's Glance",style: GoogleFonts.montserrat(
                            fontSize: 20,
                            fontWeight: FontWeight.w600
                           ),),

                           SizedBox(height: 10,),

                            Container(
                              width: 300, 
                              height: 200,
                              decoration: BoxDecoration(
                                color: Colors.blueAccent,
                                borderRadius: BorderRadius.circular(12),
                                image: DecorationImage(
                                  image: AssetImage("assets/img.png"),
                                  fit: BoxFit.cover
                                  )
                              ),
                              child: Padding(
                                padding: const EdgeInsets.only(left: 20,top: 10),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text("Total Employees",style: GoogleFonts.montserrat(
                                      color: Colors.white
                                    ),),
                                    SizedBox(height: 10,),
                                    Text("${staffList.length}",style: GoogleFonts.montserrat(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 70,
                                      color: Colors.white
                                    ),),
                                   
                                   SizedBox(height: 10,),
                                 Text("Data Sync till Date..",style: GoogleFonts.montserrat(
                                      color: Colors.white
                                    ),),
                                  ],
                                ),
                              ),
                              
                            ),
                          ],
                        ),
                
                        const SizedBox(width: 16),
                
                        Flexible(
                          child: Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                              ),
                            child: Padding(
                              padding: const EdgeInsets.only(top: 10,left: 20,right: 20,bottom: 20),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text("Leads by Sales",style: GoogleFonts.montserrat(
                                    fontWeight: FontWeight.w600
                                  ),),
                                  SizedBox(height: 10,),
                                  Container(
                                    padding: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      color: Color(0xFFF6F7FB),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Column(
                                      children: [
                                        
SingleChildScrollView(
  scrollDirection: Axis.horizontal,
  child: Container(
    height: 220,
    width: staffList.length * 190.0, // Adjust the width dynamically
    child: buildBarChart(), // The BarChart widget
  ),
)

                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                
                    const SizedBox(height: 16), 

                    //  Staff table 
Container(
  padding: const EdgeInsets.all(16),
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
  child: SingleChildScrollView(
    scrollDirection: Axis.horizontal,
    child: SingleChildScrollView(
  scrollDirection: Axis.horizontal, // Enable horizontal scrolling
  child: SizedBox(
    width: MediaQuery.of(context).size.width, // Set width to screen width
    child: DataTable(
      columns: const [
        DataColumn(label: Text('S/N')),
        DataColumn(label: Text('Name')),
        DataColumn(label: Text('Title')),  // Using 'role' from StaffPerformanceModel
        DataColumn(label: Text('Email')),
        DataColumn(label: Text('Actions')),
      ],
      rows: staffList.asMap().entries.map((entry) {
        int index = entry.key;
        StaffPerformanceModel staff = entry.value;

        return DataRow(cells: [
          DataCell(Text((index + 1).toString())), // Serial number
          DataCell(Text(staff.name)), // Access the 'name' property
          DataCell(Text(staff.role)), // Access the 'role' property as Title
          DataCell(Text(staff.email)), // Access the 'email' property
          DataCell(Row(
            children: [
              IconButton(
                icon: Icon(Icons.delete),
                onPressed: () {
                  // Handle delete action
                },
              ),
              IconButton(
                icon: Icon(Icons.arrow_forward),
                onPressed: () {
                  Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => StaffDetailPage(staff: staff),
      ),
    );
                },
              ),
            ],
          )),
        ]);
      }).toList(),
    ),
  ),
)


  ),
),

                  ],
                ),
              ),
            ),
);
}







Widget buildBarChart() {
  double maxAssignedTrades = staffList.isNotEmpty
      ? staffList
          .map((staff) => staff.assignedTrades.length.toDouble())
          .reduce((a, b) => a > b ? a : b)
      : 0.0;

  // Set the max Y-axis value for the chart, adding some buffer for display purposes
  double maxY = maxAssignedTrades > 0 ? maxAssignedTrades * 1.2 : 100;

  return BarChart(
    BarChartData(
      alignment: BarChartAlignment.spaceAround,
      maxY: maxY,
      barTouchData: BarTouchData(
        enabled: true,
        touchTooltipData: BarTouchTooltipData(
          getTooltipItem: (group, groupIndex, rod, rodIndex) {
            final staff = staffList[groupIndex];
            final assignedTradesCount = staff.assignedTrades.length;
            final paidTradesCount = staff.assignedTrades
                .where((trade) =>
                    trade is AssignedTrade &&
                    trade.isPaid &&
                    int.tryParse(trade.markedAt ?? '') != null) // Check if markedAt is a numeric string
                .length;

            return BarTooltipItem(
              '\nAssigned: $assignedTradesCount\nPaid: $paidTradesCount',
              const TextStyle(
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
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 30,
            getTitlesWidget: (value, meta) {
              final int index = value.toInt();
              if (index >= 0 && index < staffList.length) {
                return Column(
                  children: [
                    SizedBox(height: 10,),
                    Text(
                      staffList[index].name ?? 'N/A',
                      style: GoogleFonts.montserrat(
                        fontWeight: FontWeight.w400,
                        color: Colors.black,
                      ),
                    ),
                  ],
                );
              }
              return Container();
            },
          ),
        ),
        leftTitles: AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        rightTitles: AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
      ),
      borderData: FlBorderData(show: false),
      barGroups: List.generate(staffList.length, (index) {
        final staff = staffList[index];
        final assignedTradesCount = staff.assignedTrades.length.toDouble();
        final paidTradesCount = staff.assignedTrades
            .where((trade) =>
                trade is AssignedTrade &&
                trade.isPaid &&
                int.tryParse(trade.markedAt ?? '') != null) // Check if markedAt is a numeric string
            .length
            .toDouble();

        // Normalize the assigned trades count and paid trades count
        final normalizedAssignedCount = (assignedTradesCount /
                (maxAssignedTrades > 0 ? maxAssignedTrades : 1)) *
            maxY;
        final normalizedPaidCount = (paidTradesCount /
                (maxAssignedTrades > 0 ? maxAssignedTrades : 1)) *
            maxY;

        return BarChartGroupData(
          x: index,
          barRods: [
            BarChartRodData(
              toY: normalizedPaidCount, // Red part for paid trades
              color: Colors.redAccent, // Filled red part for paid trades
              width: 25, // Bar width
              // Background color represents the total assigned trades (white part)
              backDrawRodData: BackgroundBarChartRodData(
                show: true,
                toY: normalizedAssignedCount, // Full height for assigned trades
                color: Colors.white, // Unfilled part is white
              ),
            ),
          ],
        );
      }),
    ),
  );
}






}
