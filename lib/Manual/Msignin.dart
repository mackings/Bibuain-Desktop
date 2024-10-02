import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:bdesktop/Admin/adminhome.dart';
import 'package:bdesktop/Manual/Msignup.dart';
import 'package:bdesktop/Manual/Trade%20Pool/PayingGround.dart';
import 'package:bdesktop/Trainer/payers.dart';
import 'package:bdesktop/widgets/bubble.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';
import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Msignin extends StatefulWidget {
  @override
  MsigninState createState() => MsigninState();
}

class MsigninState extends State<Msignin> {



  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  bool _isLoading = false;
// Method to save username and token to preferences
Future<void> _saveToPrefs(String username, String token) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.setString('username', username);
  await prefs.setString('token', token); // Save the token as well
}

Future<void> _checkAndProceed(BuildContext context) async {
  String username = _usernameController.text.trim();
  String password = _passwordController.text.trim(); // Get the password

  if (username.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Please enter a username')),
    );
    return;
  }

  if (password.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Please enter a password')),
    );
    return;
  }

  setState(() {
    _isLoading = true; // Start loading
  });

  try {
    final String url =
        'https://b-backend-xe8q.onrender.com/login'; // Login API URL
    final Map<String, dynamic> requestBody = {
      "username": username,
      "password": password,
    };

    // Send login request
    var response = await http.post(
      Uri.parse(url),
      headers: {
        "Content-Type": "application/json",
      },
      body: jsonEncode(requestBody),
    );

    if (response.statusCode == 200) {
      var data = jsonDecode(response.body);

      // Check if success is true
      if (data['success'] == true) {
        String token = data['data']['token']; // Access the token from the nested data

        // Save the username and token to preferences
        await _saveToPrefs(username, token);

        // Navigate to the Payment page
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => Payment(username: username),
          ),
        );
      } else {
        // Handle login failure (message will be in the response)
        String errorMessage = data['message'] ?? 'Login failed'; // Default error message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorMessage)),
        );
      }
    } else {
      // Handle HTTP errors (if any)
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('An error occurred: ${response.statusCode}')),
      );
    }
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('An error occurred: $e')),
    );
    print(e);
  } finally {
    setState(() {
      _isLoading = false; // Stop loading
    });
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
              Positioned.fill(
                child: Stack(
                  children: List.generate(
                    5,
                    (index) => Bubble(
                      size: 50.0 + Random().nextDouble() * 10,
                      color: Colors.blueAccent,
                      duration: Duration(seconds: 10),
                    ),
                  ),
                ),
              ),

              // Main content
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Bibuain Ent.",
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

                    SizedBox(height: 1.h),

                    Container(
                      width: 60.w,
                      padding: EdgeInsets.symmetric(horizontal: 8.0),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: TextField(
                        controller: _passwordController,
                        obscureText: true, // Obscures password input
                        decoration: InputDecoration(
                          labelText: 'Password',
                          border: InputBorder.none,
                        ),
                      ),
                    ),

                    SizedBox(height: 2.h),

                    // Loading indicator or Login button
                    _isLoading
                        ? CircularProgressIndicator() // Show loading spinner
                        : Container(
                            width: 60.w,
                            height: 4.h, // Set desired height
                            decoration: BoxDecoration(
                              color: Colors.blue, // Background color
                              borderRadius:
                                  BorderRadius.circular(10), // Rounded corners
                            ),
                            child: InkWell(
                              onTap: () =>
                                  _checkAndProceed(context), // Handle tap
                              child: Center(
                                child: Text(
                                  'Login',
                                  style: GoogleFonts.poppins(
                                    color: Colors.white, // Text color
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                          ),

                    // New User? Sign Up text
                    SizedBox(height: 1.h), 
                    RichText(
                      text: TextSpan(
                        style: GoogleFonts.poppins(
                          fontSize: 6.sp, 
                          color: Colors.black, 
                        ),
                        children: [
                          TextSpan(text: 'New Payer? '), // Regular text
                          TextSpan(
                            text: 'Sign Up',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.blue, // Sign Up text color
                              decoration: TextDecoration.underline, // Underline
                            ),
                            recognizer: TapGestureRecognizer()
                              ..onTap = () {
                                // Navigate to Sign Up page
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          Msignup()), // Replace with your Sign Up page
                                );
                              },
                          ),
                        ],
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
