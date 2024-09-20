import 'dart:math';
import 'package:bdesktop/Admin/widgets/Acontainer.dart';
import 'package:bdesktop/Admin/widgets/widget.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class AdminHome extends StatefulWidget {
  const AdminHome({super.key});

  @override
  State<AdminHome> createState() => _AdminHomeState();
}

class _AdminHomeState extends State<AdminHome> {
  final _secondsController = TextEditingController();
  Map<String, dynamic> _staffDataFromPrefs = {};
  Map<String, dynamic> _staffDataFetched = {};
  bool _loading = false;

  double _totalMispayment = 0;
  double _totalFiatRequested = 0;
  double _totalAmountPaid = 0;
  int _totalPaidTrades = 0;
  int _totalUnpaidTrades = 0;
  int _totalAssignedTrades = 0;
  int _totalStaffCount = 0;

  @override
  void initState() {
    super.initState();
    _loadStaffDataFromPrefs();
  }



  Future<void> _loadStaffDataFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final staffDataString = prefs.getString('staffData');
    if (staffDataString != null) {
      setState(() {
        _staffDataFromPrefs = jsonDecode(staffDataString);
        _staffDataFetched = _staffDataFromPrefs['data'] ?? {};
        print(_staffDataFetched);

        _calculateTotals();
      });
    }
  }

  void _calculateTotals() {
    double totalMispayment = 0;
    double totalFiatRequested = 0;
    double totalAmountPaid = 0;
    int totalPaidTrades = 0;
    int totalUnpaidTrades = 0;
    int totalAssignedTrades = 0;
    int totalStaffCount = 0;

    if (_staffDataFetched != null && _staffDataFetched.isNotEmpty) {
      final staffStatistics = _staffDataFetched['staffStatistics'] as List;

      totalStaffCount = staffStatistics.length;

      for (var staff in staffStatistics) {
        totalMispayment += double.tryParse(staff['mispayment'].toString()) ?? 0;
        totalFiatRequested +=
            double.tryParse(staff['totalFiatRequested'].toString()) ?? 0;
        totalAmountPaid +=
            double.tryParse(staff['totalAmountPaid'].toString()) ?? 0;
        totalPaidTrades += (staff['paidTrades'] as num?)?.toInt() ?? 0;
        totalUnpaidTrades += (staff['unpaidTrades'] as num?)?.toInt() ?? 0;
        totalAssignedTrades +=
            (staff['totalAssignedTrades'] as num?)?.toInt() ?? 0;
      }

      setState(() {
        _totalMispayment = totalMispayment;
        _totalFiatRequested = totalFiatRequested;
        _totalAmountPaid = totalAmountPaid;
        _totalPaidTrades = totalPaidTrades;
        _totalUnpaidTrades = totalUnpaidTrades;
        _totalAssignedTrades = totalAssignedTrades;
        _totalStaffCount = totalStaffCount;

        print('Calculated Total Mispayment: $totalMispayment');
        print(
            'Expected Total Mispayment: ${_staffDataFetched['mispayment']['expectedTotal']}');
      });
    }
  }

  Future<void> _updateSecondsInFirestore(int seconds) async {
    try {
      await FirebaseFirestore.instance
          .collection('Duration')
          .doc('Duration')
          .update({'Duration': seconds});

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(
          'Seconds Updated Successfully',
          style: GoogleFonts.montserrat(),
        )),
      );

      print('Seconds updated successfully.');
    } catch (e) {
      print('Error updating seconds in Firestore: $e');
    }
  }

  Future<void> _fetchData() async {
    setState(() {
      _loading = true;
    });
    final response = await http.get(
      Uri.parse('https://tester-1wva.onrender.com/staff/trade-statistics'),
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final prefs = await SharedPreferences.getInstance();
      prefs.setString('staffData', response.body);
      setState(() {
        _staffDataFetched = data['data'] ?? {}; // Update fetched data
        _loading = false;
      });
      print("Live $data");
    } else {
      setState(() {
        _loading = false;
      });
    }
  }

  void _showSetSecondsDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Set Timer',
            style: GoogleFonts.montserrat(
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
          ),
          content: TextField(
            controller: _secondsController,
            decoration: InputDecoration(
              labelText: 'Seconds',
            ),
            keyboardType: TextInputType.number,
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                final int seconds = int.tryParse(_secondsController.text) ?? 0;
                _updateSecondsInFirestore(seconds);
              },
              child: Text(
                'Save',
                style: GoogleFonts.montserrat(
                  fontWeight: FontWeight.w400,
                  color: Colors.black,
                ),
              ),
            ),
          ],
        );
      },
    );
  }



  String _selectedStaffId = '';
  final TextEditingController _numberOfTradesController =
      TextEditingController();
  Future<void> _showAssignDialog() async {
    final staffIds = await _fetchStaffIds();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return AlertDialog(
              title: Text('Assign Trade'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DropdownButton<String>(
                    value: _selectedStaffId.isEmpty ? null : _selectedStaffId,
                    hint: Text('Select Staff'),
                    items: staffIds.map((staffId) {
                      return DropdownMenuItem<String>(
                        value: staffId,
                        child: Text(staffId),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedStaffId = value ?? '';
                        print(_selectedStaffId);
                      });
                    },
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Container(
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(7),
                        border: Border.all(width: 0.5)),
                    child: Padding(
                      padding: const EdgeInsets.all(5.0),
                      child: TextField(
                          controller: _numberOfTradesController,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                              border: InputBorder.none,
                              hintText: "Enter Number of Trades",
                              helperStyle: GoogleFonts.montserrat())),
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (_selectedStaffId.isNotEmpty &&
                        _numberOfTradesController.text.isNotEmpty) {
                      _assignTrades();
                      Navigator.of(context).pop();
                    }
                  },
                  child: Text('Assign'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<List<String>> _fetchStaffIds() async {
    final firestore = FirebaseFirestore.instance;
    final snapshot = await firestore.collection('staff').get();
    return snapshot.docs.map((doc) => doc.id).toList();
  }

  Future<void> _assignTrades() async {
    final staffId = _selectedStaffId;
    final numberOfTrades = _numberOfTradesController.text;

    final url = 'https://tester-1wva.onrender.com/assign/manual';

    final body = jsonEncode({
      'staffId': staffId,
      'numberOfTrades': numberOfTrades,
    });

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: body,
      );

      if (response.statusCode == 200) {
        // Handle successful response
        print('Trade assigned successfully');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Trade Assigned Successfully')),
        );
      } else {
        // Handle error response
        print('Failed to assign trade');
      }
    } catch (e) {
      // Handle any errors
      print('Error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final staffStatistics = _staffDataFetched['staffStatistics'] ?? [];
    final totalUnassignedTrades =
        _staffDataFetched['totalUnassignedTrades']?.toString() ?? '0';
    String formattedTotalAmountPaid =
        NumberFormat('#,##0.00').format(_totalAmountPaid);
    return Scaffold(
  appBar: AppBar(
    title: Text(
      'Admin Overview',
      style: GoogleFonts.montserrat(
        color: Colors.black, 
        fontWeight: FontWeight.w600,
      ),
    ),
    automaticallyImplyLeading: false,
    actions: [
      ElevatedButton(
        onPressed: _showAssignDialog,
        child: Text(
          'Assign Trade',
          style: GoogleFonts.montserrat(
            fontWeight: FontWeight.w400,
            color: Colors.black,
          ),
        ),
      ),
      SizedBox(width: 30),
      ElevatedButton(
        onPressed: _showSetSecondsDialog,
        child: Text(
          'Set Speed',
          style: GoogleFonts.montserrat(
            fontWeight: FontWeight.w400,
            color: Colors.black,
          ),
        ),
      ),
      SizedBox(width: 20),
      ElevatedButton(
        onPressed: _fetchData,
        child: Text(
          'Refresh',
          style: GoogleFonts.montserrat(
            fontWeight: FontWeight.w400,
            color: Colors.black,
          ),
        ),
      ),
      SizedBox(width: 20),
      _loading
          ? Padding(
              padding: const EdgeInsets.all(8.0),
              child: CircularProgressIndicator(),
            )
          : SizedBox.shrink(),
    ],
  ),
  body: SingleChildScrollView(
    child: Padding(
      padding: const EdgeInsets.only(left: 20,right: 20), // Adjusted padding for responsiveness
      child: Column(
        children: [

          SizedBox(height: 60),

          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // AContainer wrapped in Flexible for responsiveness
              Flexible(
                flex: 1,
                child: AContainer(
                  mispaid: _staffDataFetched != null &&
                          _staffDataFetched['mispayment'] != null
                      ? "${_staffDataFetched['mispayment']['expectedTotal']}"
                      : "N/A",
                  icon: Icons.attach_money,
                  staffId: "N ${formattedTotalAmountPaid}",
                  paidTrades: "${_totalStaffCount}",
                  unpaidTrades: "${_totalUnpaidTrades}",
                  totalAssignedTrades: "",
                  backgroundColor: Colors.black,
                ),
              ),
              
              SizedBox(width: MediaQuery.of(context).size.width * 0.05), // Space between AContainer and BarChart

              // Expanded BarChart widget for dynamic resizing
              Expanded(
                flex: 2, // BarChart takes more space
                child: Padding(
                  padding: const EdgeInsets.only(top: 100),
                  child: Container(
                    height: 220, // Fixed height for the bar chart container
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Builder(
                      builder: (context) {
                        double maxPerformanceScore = staffStatistics.isNotEmpty
                            ? staffStatistics
                                .map((staff) => double.tryParse(staff['performanceScore']?.toString() ?? '0.0') ?? 0.0)
                                .reduce((a, b) => a > b ? a : b)
                            : 0.0; // Fallback value if the list is empty
                  
                        double maxY = maxPerformanceScore > 0 ? maxPerformanceScore * 1.2 : 150;
                  
                        if (staffStatistics.isEmpty) {
                          return Center(
                            child: Text(
                              'No data available',
                              style: TextStyle(fontSize: 16, color: Colors.black),
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
                                getTooltipItem: (group, groupIndex, rod, rodIndex) {
                                  final staff = staffStatistics[groupIndex];
                                  final performanceScore = double.tryParse(
                                          staff['performanceScore']?.toString() ?? '0.0') ??
                                      0.0;
                  
                                  return BarTooltipItem(
                                    'Performance: ${performanceScore.toStringAsFixed(2)}',
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
                                sideTitles: SideTitles(showTitles: false),
                              ),
                              bottomTitles: AxisTitles(
                                sideTitles: SideTitles(
                                  showTitles: true,
                                  reservedSize: 30,
                                  getTitlesWidget: (value, meta) {
                                    final int index = value.toInt();
                                    if (index >= 0 && index < staffStatistics.length) {
                                      return Text(
                                        staffStatistics[index]['staffId'] ?? 'N/A',
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
                                sideTitles: SideTitles(showTitles: false),
                              ),
                              rightTitles: AxisTitles(
                                sideTitles: SideTitles(showTitles: false),
                              ),
                            ),
                            borderData: FlBorderData(show: false),
                            barGroups: List.generate(staffStatistics.length, (index) {
                              final staff = staffStatistics[index];
                              final performanceScore = (double.tryParse(
                                          staff['performanceScore']?.toString() ?? '0.0') ??
                                      0.0)
                                  .toDouble();
                              final normalizedScore = (performanceScore / (maxPerformanceScore > 0 ? maxPerformanceScore : 1)) * maxY;
                  
                              return BarChartGroupData(
                                x: index,
                                barRods: [
                                  BarChartRodData(
                                    toY: 10, // Example static bar
                                    color: Colors.black,
                                    width: 15,
                                  ),
                                  BarChartRodData(
                                    toY: normalizedScore.clamp(1.0, maxY),
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

SizedBox(height: 30),
          // Wrap for staff statistics
          Wrap(
            spacing: 16.0, // Horizontal space between items
            runSpacing: 16.0, // Vertical space between rows
            children: staffStatistics.map<Widget>((staff) {
              return Container(
                width: MediaQuery.of(context).size.width / 4 - 24, // 4 items per row
                child: StatsContainer(
                  icon: Icons.person_3_outlined,
                  staffId: staff['staffId'] ?? 'N/A',
                  speed: staff['averageSpeed']?.toString() ?? '0',
                  paidTrades: staff['paidTrades']?.toString() ?? '0',
                  unpaidTrades: staff['unpaidTrades']?.toString() ?? '0',
                  totalAssignedTrades: staff['totalAssignedTrades']?.toString() ?? '0',
                  mispaid: ((double.tryParse(staff['totalFiatRequested']?.toString() ?? '0') ?? 0) -
                          (double.tryParse(staff['totalAmountPaid']?.toString() ?? '0') ?? 0))
                      .toStringAsFixed(2),
                  backgroundColor: Colors.white,
                ),
              );
            }).toList(),
          ),

          SizedBox(height: 20),
        ],
      ),
    ),
  ),
);


  }
}

class BarChartWidget extends StatefulWidget {
  final List<dynamic> staffStatistics;

  const BarChartWidget({required this.staffStatistics});

  @override
  _BarChartWidgetState createState() => _BarChartWidgetState();
}

class _BarChartWidgetState extends State<BarChartWidget> {
  int touchedIndex = -1;
  bool isPlaying = false;

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1,
      child: Stack(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                const Text(
                  'Staff Performance',
                  style: TextStyle(
                    color: Colors.green,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(
                  height: 4,
                ),
                const Text(
                  'Performance Scores',
                  style: TextStyle(
                    color: Colors.green,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(
                  height: 38,
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: BarChart(
                      isPlaying ? randomData() : mainBarData(),
                      swapAnimationDuration: const Duration(milliseconds: 250),
                    ),
                  ),
                ),
                const SizedBox(
                  height: 12,
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8),
            child: Align(
              alignment: Alignment.topRight,
              child: IconButton(
                icon: Icon(
                  isPlaying ? Icons.pause : Icons.play_arrow,
                  color: Colors.green,
                ),
                onPressed: () {
                  setState(() {
                    isPlaying = !isPlaying;
                    if (isPlaying) {
                      refreshState();
                    }
                  });
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  BarChartGroupData makeGroupData(
    int x,
    double y, {
    bool isTouched = false,
    Color barColor = Colors.blue,
    double width = 15,
  }) {
    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(
          toY: isTouched ? y + 1 : y,
          color: isTouched ? Colors.yellow : barColor,
          width: width,
          borderSide: isTouched
              ? BorderSide(color: Colors.yellow)
              : const BorderSide(color: Colors.white, width: 0),
        ),
      ],
      showingTooltipIndicators: [0],
    );
  }

  BarChartData mainBarData() {
    return BarChartData(
      barTouchData: BarTouchData(
        touchTooltipData: BarTouchTooltipData(
          getTooltipItem: (group, groupIndex, rod, rodIndex) {
            return BarTooltipItem(
              '${widget.staffStatistics[group.x]['staffId']}\n',
              const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
              children: <TextSpan>[
                TextSpan(
                  text: rod.toY.toString(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            );
          },
        ),
        touchCallback: (FlTouchEvent event, barTouchResponse) {
          setState(() {
            if (!event.isInterestedForInteractions ||
                barTouchResponse == null ||
                barTouchResponse.spot == null) {
              touchedIndex = -1;
              return;
            }
            touchedIndex = barTouchResponse.spot!.touchedBarGroupIndex;
          });
        },
      ),
      titlesData: FlTitlesData(
        show: true,
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            getTitlesWidget: (value, meta) {
              int index = value.toInt();
              return Text(
                (index >= 0 && index < widget.staffStatistics.length)
                    ? widget.staffStatistics[index]['staffId'] ?? ''
                    : '',
                style: TextStyle(fontSize: 12),
              );
            },
            reservedSize: 30,
          ),
        ),
        // leftTitles: const AxisTitles(
        //   sideTitles: SideTitles(
        //     showTitles: true,
        //     reservedSize: 40,
        //     getTitlesWidget: (value, meta) {
        //       return Text(value.toInt().toString());
        //     },
        //   ),
        // ),
      ),
      borderData: FlBorderData(show: false),
      barGroups: List.generate(widget.staffStatistics.length, (index) {
        double yValue = double.tryParse(
                widget.staffStatistics[index]['performanceScore'] ?? '0') ??
            0;
        if (yValue.isNaN || yValue.isInfinite) {
          yValue = 0;
        }
        return makeGroupData(index, yValue, isTouched: index == touchedIndex);
      }),
    );
  }

  BarChartData randomData() {
    return BarChartData(
      barTouchData: BarTouchData(enabled: false),
      titlesData: FlTitlesData(
        show: true,
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(showTitles: true),
        ),
        leftTitles: AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
      ),
      barGroups: List.generate(7, (i) {
        return makeGroupData(
          i,
          Random().nextDouble() * 20,
          barColor: Colors.primaries[Random().nextInt(Colors.primaries.length)],
        );
      }),
    );
  }

  Future<void> refreshState() async {
    setState(() {});
    await Future.delayed(const Duration(milliseconds: 300));
    if (isPlaying) {
      await refreshState();
    }
  }
}
