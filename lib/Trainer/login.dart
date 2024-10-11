import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:bdesktop/Admin/adminhome.dart';
import 'package:bdesktop/Mobile/home.dart';
import 'package:bdesktop/Trainer/payers.dart';
import 'package:bdesktop/widgets/bubble.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';
import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {

  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  bool _isPasswordVisible = false;  // For toggling password visibility
  bool _isLoading = false;  // For showing loading indicator

  Future<void> _saveUsernameToPrefs(String username) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('username', username);
  }

Future<void> _loginUser(BuildContext context) async {
  String username = _usernameController.text.trim();
  String password = _passwordController.text.trim();

  if (username.isEmpty || password.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Please enter both username and password')),
    );
    return;
  }

  setState(() {
    _isLoading = true;  // Start loading
  });

  try {
    DocumentSnapshot staffDoc = await _firestore.collection('Traineestaff').doc(username).get();

    if (staffDoc.exists && staffDoc['password'] == password) {
      await _saveUsernameToPrefs(username);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Logged in successfully')),
      );

      String role = staffDoc['role'];  // Get the user's role

      if (role == 'HR') {
        // Navigate to HR-specific page
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => AdminHome(),  // Replace HRPage with the actual HR page widget
          ),
        );
      } else {
        // Default behavior based on platform
        if (Platform.isWindows) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => Payers(username: username),
            ),
          );
        } else {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => Apphome(username: username),
            ),
          );
        }
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Invalid username or password')),
      );
    }
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('An error occurred: $e')),
    );
  } finally {
    setState(() {
      _isLoading = false;  // Stop loading
    });
  }
}


  @override
  Widget build(BuildContext context) {
    return Sizer(
      builder: (context, orientation, deviceType) {
        return Scaffold(
          appBar: AppBar(),
          backgroundColor: Colors.white,
          body: Stack(
            children: [
              Positioned.fill(
                child: Stack(
                  children: List.generate(5, (index) => Bubble(
                    size: 50.0 + Random().nextDouble() * 10,
                    color: Colors.blueAccent,
                    duration: Duration(seconds: 10),
                  )),
                ),
              ),
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Trainer App.",
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
                    SizedBox(height: 2.h),
                    Container(
                      width: 60.w,
                      padding: EdgeInsets.symmetric(horizontal: 8.0),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: TextField(
                        controller: _passwordController,
                        obscureText: !_isPasswordVisible,
                        decoration: InputDecoration(
                          labelText: 'Password',
                          border: InputBorder.none,
                          suffixIcon: IconButton(
                            icon: Icon(
                              _isPasswordVisible
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                            ),
                            onPressed: () {
                              setState(() {
                                _isPasswordVisible = !_isPasswordVisible;
                              });
                            },
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 20),
                    Column(
                      children: [
                        Container(
                          width: 60.w,
                          height: 4.h,
                          child: ElevatedButton(
                            onPressed: _isLoading
                                ? null  // Disable button when loading
                                : () => _loginUser(context),
                            child: _isLoading
                                ? CircularProgressIndicator(
                                    color: Colors.white,
                                  )
                                : Text(
                                    'Sign In',
                                    style: GoogleFonts.poppins(color: Colors.white),
                                  ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          ),
                        ),

                        
                      ],
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

