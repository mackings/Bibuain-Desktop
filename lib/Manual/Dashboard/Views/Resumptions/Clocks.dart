import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:sizer/sizer.dart';


class Clocks extends StatefulWidget {
  const Clocks({super.key});

  @override
  State<Clocks> createState() => _ClocksState();
}

class _ClocksState extends State<Clocks> {
  bool isClockedIn = false; // To track clock-in state
  String? username;
  String? token;

  @override
  void initState() {
    super.initState();
    _loadFromPrefs(); // Load user data from SharedPreferences
  }

  Future<void> _loadFromPrefs() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      username = prefs.getString('username');
      token = prefs.getString('token');
      // Load clock-in state using a unique key for each user
      isClockedIn = prefs.getBool('isClockedIn_$username') ?? false; 
      print(token);
    });
  }

  Future<void> _saveClockInState(bool state) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    // Save clock-in state using a unique key for each user
    await prefs.setBool('isClockedIn_$username', state); 
  }

  Future<void> _clockIn() async {
    if (token != null) {
      final response = await http.post(
        Uri.parse('https://b-backend-xe8q.onrender.com/clockin'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'token': token}),
      );

      if (response.statusCode == 200) {
        // Handle successful clock-in
        setState(() {
          isClockedIn = true; // Update state to clocked in
        });
        _saveClockInState(true); // Save clock-in state
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Clocked in successfully!")),
        );
      } else {
        // Handle error
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to clock in.")),
        );
      }
    }
  }

  Future<void> _clockOut() async {
    if (token != null) {
      final response = await http.post(
        Uri.parse('https://b-backend-xe8q.onrender.com/clockout'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'token': token}),
      );

      if (response.statusCode == 200) {
        // Handle successful clock-out
        setState(() {
          isClockedIn = false; // Update state to clocked out
        });
        _saveClockInState(false); // Save clock-in state
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Clocked out successfully!")),
        );
      } else {
        // Handle error
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to clock out.")),
        );
      }
    }
  }

  void _onSwitchChanged(bool value) {
    if (value) {
      _clockIn(); // Clock in if switch is turned on
    } else {
      _clockOut(); // Clock out if switch is turned off
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              username != null ? 'Hi, $username' : 'Loading user...',
              style: GoogleFonts.montserrat(fontSize: 12.sp, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 20),
            Transform.scale(
              scale: 1.5, // Adjust the scale factor as needed
              child: Switch(
                value: isClockedIn,
                onChanged: _onSwitchChanged,
                activeColor: Colors.green, // Color when the switch is on
                inactiveThumbColor: Colors.red, // Color when the switch is off
                inactiveTrackColor: Colors.red[200],
                activeTrackColor: Colors.green[200],
                materialTapTargetSize: MaterialTapTargetSize.padded, // Makes switch larger
              ),
            ),
            const SizedBox(height: 10),
            Text(
              isClockedIn ? "You are clocked in" : "You are clocked out",
              style: GoogleFonts.montserrat(
                  fontSize: 16, color: isClockedIn ? Colors.green : Colors.red),
            ),
          ],
        ),
      ),
    );
  }
}
