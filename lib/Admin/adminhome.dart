import 'dart:math';

import 'package:bdesktop/Admin/widgets/Acontainer.dart';
import 'package:bdesktop/Admin/widgets/bar.dart';
import 'package:bdesktop/Admin/widgets/widget.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
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
        _staffDataFetched =
            _staffDataFromPrefs['data'] ?? {}; // Ensure this is set for UI
        print(_staffDataFetched);
      });
    }
  }

  Future<void> _updateSeconds() async {
    final seconds = _secondsController.text;
    final response = await http.post(
      Uri.parse('https://your-api-url-to-update-seconds'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'seconds': seconds}),
    );

    if (response.statusCode == 200) {
      // Handle successful update
    } else {
      // Handle failure
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
          title: Text('Set Test Attempt Seconds'),
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
                _updateSeconds();
              },
              child: Text('Save'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final staffStatistics = _staffDataFetched['staffStatistics'] ?? [];
    final totalUnassignedTrades =
        _staffDataFetched['totalUnassignedTrades']?.toString() ?? '0';

    return Scaffold(
      appBar: AppBar(
        title: Text('Admin Overview',
            style: GoogleFonts.montserrat(
                color: Colors.black, fontWeight: FontWeight.w600)),
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.only(left: 60, right: 60, top: 60),
          child: Column(
            children: [

Row(
  mainAxisAlignment: MainAxisAlignment.spaceBetween,
  children: [

    AContainer(
      mispaid: null,
      icon: Icons.attach_money,
      staffId: "Total Unassigned Trades",
      speed: totalUnassignedTrades,
      paidTrades: "",
      unpaidTrades: "",
      totalAssignedTrades: "",
      backgroundColor: Colors.blue,
    ),

    SizedBox(width: 60),

    // Spacing between the two widgets

Expanded(
  child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Row(
        children: [
          Text("Points at a",style: GoogleFonts.montserrat(),),
          SizedBox(width: 10,),
          Text("Glance",style: GoogleFonts.montserrat(
            color: Colors.blue,
            fontWeight: FontWeight.w600
          ),),
        ],
      ),
      
      SizedBox(height: 10,),

      Container(
        height: 220,
        decoration: BoxDecoration(
          border: Border.all(width: 0.2),
          borderRadius: BorderRadius.circular(8),
          //color: const Color.fromARGB(255, 68, 64, 64)
        ),
        child: BarChart(
          BarChartData(
            alignment: BarChartAlignment.spaceAround,
            maxY: 150, // Set maxY as your target value
            barTouchData: BarTouchData(enabled: false),
            gridData: FlGridData(show: false), // Hide the dotted lines
            titlesData: FlTitlesData(
              show: true,
              topTitles: AxisTitles(
                sideTitles: SideTitles(showTitles: false), // Hide numbers at the top
              ),
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 40, // Adjust the size to fit your titles
                  getTitlesWidget: (value, meta) {
                    final int index = value.toInt();
                    if (index >= 0 && index < staffStatistics.length) {
                      return Text(
                        staffStatistics[index]['staffId'] ?? 'N/A',
                        style: GoogleFonts.montserrat(
                          fontWeight: FontWeight.w400,
                          color: Colors.black
                        )
                      );
                    }
                    return Container();
                  },
                ),
              ),
              leftTitles: AxisTitles(
                sideTitles: SideTitles(showTitles: false), // Hide numbers on the left
              ),
              rightTitles: AxisTitles(
                sideTitles: SideTitles(showTitles: false), // Hide numbers on the right
              ),
            ),
            borderData: FlBorderData(show: false), // Remove borders if necessary
            barGroups: List.generate(staffStatistics.length, (index) {
              final staff = staffStatistics[index];
              final performanceScore = double.tryParse(staff['performanceScore'] ?? '0.0') ?? 0.0;
        
              return BarChartGroupData(
                x: index,
                barRods: [
                  // Background bar representing the full bar (target)
                  BarChartRodData(
                    toY: 100, // Full bar (target)
                    color: Colors.black, // Background color for full bar
                    width: 15,
                  ),
                  // Foreground bar representing the user's actual score
                  BarChartRodData(
                    toY: performanceScore.clamp(1.0, double.infinity), // Actual performance score
                    color: Colors.orange, // Color for the user's score
                    width: 15,
                  ),
                ],
              );
            }),
          ),
        ),
      ),
    ],
  ),
)


  ],
),

              Row(
              //  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 20),

                       Text(
                        'Staff Statistics',
                        style: GoogleFonts.montserrat(
                          color: Colors.black,
                          fontWeight: FontWeight.w600,
                          fontSize: 18
                          ),
                      ),

                      SizedBox(height: 20),
                      
                      Wrap(
                        spacing: 16.0, // Space between items horizontally
                        runSpacing: 16.0, // Space between rows
                        children: staffStatistics.map<Widget>((staff) {
                          return StatsContainer(
                            icon: Icons.person_3_outlined,
                            staffId: staff['staffId'] ?? 'N/A',
                            speed: staff['averageSpeed'] ?? 'N/A',
                            paidTrades: staff['paidTrades']?.toString() ?? '0',
                            unpaidTrades:
                                staff['unpaidTrades']?.toString() ?? '0',
                            totalAssignedTrades:
                                staff['totalAssignedTrades']?.toString() ?? '0',
                                mispaid: staff['mispayment']['actualTotal']?? '0',
                            backgroundColor: Colors.white,
                          );
                        }).toList(),
                      ),
                      SizedBox(height: 20),

                      SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: _showSetSecondsDialog,
                        child: Text('Set Seconds'),
                      ),
                      SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: _fetchData,
                        child: Text('Fetch Data'),
                      ),
                      SizedBox(height: 20),
                      _loading
                          ? CircularProgressIndicator()
                          : SizedBox.shrink(),
                    ],
                  ),
                ],
              ),
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
