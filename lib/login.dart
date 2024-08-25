import 'dart:math';

import 'package:bdesktop/payers.dart';
import 'package:bdesktop/widgets/bubble.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';
// Make sure to import your bubble widget

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _usernameController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Sizer(
      builder: (context, orientation, deviceType) {
        return Scaffold(
          backgroundColor: Colors.white,
          body: Stack(
            children: [
              // Background bubbles
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
                    Text("Trainer App.", style: GoogleFonts.poppins(
                      fontSize: 25.sp,
                      fontWeight: FontWeight.w600
                    )),
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
                          border: InputBorder.none, // Remove default border
                        ),
                      ),
                    ),
                    SizedBox(height: 20),
                    Container(
                      width: 60.w,
                      height: 4.h, // Make button full width
                      child: ElevatedButton(
                        onPressed: () {
                          if (_usernameController.text.isNotEmpty) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => Payers(
                                  username: _usernameController.text,
                                ),
                              ),
                            );
                          } else {
                            // Show an error if the username is empty
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Please enter a username')),
                            );
                          }
                        },
                        child: Text('Start', style: GoogleFonts.poppins(color: Colors.white)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue, // Background color
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10), // Rounded corners
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
