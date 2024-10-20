import 'dart:convert';
import 'dart:math';
import 'package:bdesktop/Manual/Authentication/Msignin.dart';
import 'package:bdesktop/widgets/bubble.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sizer/sizer.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:io';

class Msignup extends StatefulWidget {
  @override
  MsignupState createState() => MsignupState();
}

class MsignupState extends State<Msignup> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();

  bool _isLoading = false;
  String? _selectedRole; // Store the selected role
  final List<String> _roles = ['Payer', 'Team Lead', 'Technical Manager', 'HR'];

  Future<void> _saveUsernameToPrefs(String username) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('username', username);
  }

  Future<void> _checkAndProceed(BuildContext context) async {
    String username = _usernameController.text.trim();
    String password = _passwordController.text.trim();
    String name = _nameController.text.trim();
    String email = _emailController.text.trim();
    String role = _selectedRole ?? '';

    if (username.isEmpty ||
        password.isEmpty ||
        name.isEmpty ||
        email.isEmpty ||
        role.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please fill all fields')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      bool success = await _addStaff(username, password, name, email, role);

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Registered Successfuly')),
        );
        await _saveUsernameToPrefs(username);
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => Msignin()), // Redirect to appropriate page
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to register staff')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('An error occurred: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<bool> _addStaff(String username, String password, String name,
      String email, String role) async {
    final String url =
        'https://b-backend-xe8q.onrender.com/register'; // Replace with your API URL

    final Map<String, dynamic> requestBody = {
      "username": username,
      "password": password,
      "name": name,
      "email": email,
      "role": role,
    };

    try {
      print(requestBody);
      var response = await http.post(
        Uri.parse(url),
        headers: {
          "Content-Type": "application/json",
        },
        body: jsonEncode(requestBody),
      );

      if (response.statusCode == 201) {
        return true;
      } else {
        print(
            'Failed to register staff: ${response.statusCode} - ${response.body}');
        return false;
      }
    } catch (e) {
      print('Error registering staff: $e');
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
              // Bubble background
              Positioned.fill(
                child: Stack(
                  children: List.generate(
                      5,
                      (index) => Bubble(
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
                      "Bibuain Ent.",
                      style: GoogleFonts.poppins(
                        fontSize: 25.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 2.h),

                    _buildTextField(_usernameController, "Username"),
                    SizedBox(height: 1.h),
                    _buildTextField(_passwordController, "Password",
                        isPassword: true),
                    SizedBox(height: 1.h),
                    _buildTextField(_nameController, "Full Name"),
                    SizedBox(height: 1.h),
                    _buildTextField(_emailController, "Email"),
                    SizedBox(height: 1.h),

                    // Role Dropdown
                    _buildRoleDropdown(),

                    SizedBox(height: 20),

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
                                  'Sign Up',
                                  style: GoogleFonts.poppins(
                                    color: Colors.white, // Text color
                                    fontWeight: FontWeight.w600,
                                  ),
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

  Widget _buildTextField(TextEditingController controller, String label,
      {bool isPassword = false}) {
    return Container(
      width: 60.w,
      padding: EdgeInsets.symmetric(horizontal: 8.0),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(10),
      ),
      child: TextField(
        controller: controller,
        textCapitalization: TextCapitalization.words,
        obscureText: isPassword,
        decoration: InputDecoration(
          labelText: label,
          border: InputBorder.none,
        ),
      ),
    );
  }

  Widget _buildRoleDropdown() {
    return Container(
      width: 60.w,
      padding: EdgeInsets.symmetric(horizontal: 8.0),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(10),
      ),
      child: DropdownButtonFormField<String>(
        decoration: InputDecoration(
          border: InputBorder.none,
          fillColor: Colors.transparent, // Set fill color to transparent
        ),
        value: _selectedRole,
        hint: Text("Select Role"),
        items: _roles.map((role) {
          return DropdownMenuItem<String>(
            value: role,
            child: Text(role),
          );
        }).toList(),
        onChanged: (newValue) {
          setState(() {
            _selectedRole = newValue;
          });
        },
      ),
    );
  }
}
