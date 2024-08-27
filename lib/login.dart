import 'dart:convert';
import 'dart:math';

import 'package:bdesktop/payers.dart';
import 'package:bdesktop/widgets/bubble.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';
import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart';


class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _usernameController = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> _checkAndProceed(BuildContext context) async {
    String username = _usernameController.text.trim();
    
    if (username.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please enter a username')),
      );
      return;
    }

    try {
      // Check if username exists in Firestore
      DocumentSnapshot staffDoc = await _firestore.collection('staff').doc(username).get();
      
      if (staffDoc.exists) {
        // Username exists, proceed with existing data
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => Payers(username: username),
          ),
        );
      } else {
        // Username doesn't exist, create new staff
        bool success = await _addStaff(username);
        
        if (success) {
          // After adding, proceed to next screen
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => Payers(username: username),
            ),
          );
        } else {
          // Handle the error case
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to add staff. Please try again.')),
          );
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('An error occurred: $e')),
      );
    }
  }

  // Function to add staff via POST request
  Future<bool> _addStaff(String username) async {
    final String url = 'https://tester-1wva.onrender.com/paxful/addstaff'; // API URL

    final Map<String, dynamic> requestBody = {
      "staffId": username,
      "staffDetails": {
        "name": username, // Assuming username as name for now
        "email": "example@example.com", // Replace with actual email if available
        "role": "Payer", 
      }
    };

    try {
      var response = await http.post(
        Uri.parse(url),
        headers: {
          "Content-Type": "application/json",
        },
        body: jsonEncode(requestBody),
      );
      
      if (response.statusCode == 200) {
        return true;
      } else {
        print('Failed to add staff: ${response.statusCode} - ${response.body}');
        return false;
      }
    } catch (e) {
      print('Error adding staff: $e');
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Sizer(
      builder: (context, orientation, deviceType) {
        return Scaffold(
          backgroundColor: Colors.white,
          body: Stack(
            children: [
              // Background bubbles (if needed for design purposes)
              Positioned.fill(
                child: Stack(
                  children: List.generate(5, (index) => Bubble(
                    size: 50.0 + Random().nextDouble() * 10,
                    color: Colors.blueAccent,
                    duration: Duration(seconds: 10),
                  )),
                ),
              ),
              // Main content
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Trainer App",
                      style: GoogleFonts.poppins(
                        fontSize: 25.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Container(
                      width: 60.w,
                      padding: EdgeInsets.symmetric(horizontal: 8.0),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: TextField(
                        controller: _usernameController,
                        textCapitalization: TextCapitalization.words,
                        decoration: InputDecoration(
                          labelText: 'Username',
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                    SizedBox(height: 20),
                    Container(
                      width: 60.w,
                      height: 4.h,
                      child: ElevatedButton(
                        onPressed: () => _checkAndProceed(context),
                        child: Text(
                          'Start',
                          style: GoogleFonts.poppins(color: Colors.white),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}