import 'dart:convert';

import 'package:bdesktop/Mobile/home.dart';
import 'package:bdesktop/widgets/colors.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class Description extends StatefulWidget {
  final String? accountName;
  final String? bankImg;

  const Description({Key? key, this.accountName, this.bankImg})
      : super(key: key);

  @override
  State<Description> createState() => _DescriptionState();
}

class _DescriptionState extends State<Description> {
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _narrationController = TextEditingController();
  String? _username;

  Future<void> _loadUsername() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _username = prefs.getString('username');
    });
    print(_username);
  }

  @override
  void initState() {
    super.initState();
    _loadUsername();
  }

  void _submitTradeUpdate() async {
    String? amount = _amountController.text.replaceAll(',', '');
    String? narration = _narrationController.text;

    if (_username != null && amount.isNotEmpty && narration.isNotEmpty) {
      // Make the API call
      String url = 'https://tester-1wva.onrender.com/trade/update';
      Map<String, dynamic> payload = {
        "staffId": _username,
        "name": narration,
        "amountPaid": int.tryParse(amount) ?? 0,
      };

      try {
        var response = await http.post(
          Uri.parse(url),
          headers: {"Content-Type": "application/json"},
          body: jsonEncode(payload),
        );

        if (response.statusCode == 200) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Transfer Successful')),
          );
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) =>
                      Apphome(username: _username.toString())));
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to update trade')),
          );
        }
      } catch (e) {
        print('Error: $e');
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please fill in all fields')),
      );
    }
  }

  void _onKeypadClick(String value) {
    setState(() {
      if (value == 'delete') {
        if (_amountController.text.isNotEmpty) {
          _amountController.text = _amountController.text
              .substring(0, _amountController.text.length - 1);
        }
      } else {
        _amountController.text += value;
      }
      _formatAmount();
    });
  }

  // Format amount to include thousand separators
  void _formatAmount() {
    String currentText = _amountController.text.replaceAll(',', '');
    if (currentText.isNotEmpty) {
      final formatter = NumberFormat("#,###");
      _amountController.text = formatter.format(int.tryParse(currentText) ?? 0);
      _amountController.selection = TextSelection.fromPosition(
          TextPosition(offset: _amountController.text.length));
    }
  }

  Widget buildKeypadButton(String value) {
    return Expanded(
      child: InkWell(
        onTap: () => _onKeypadClick(value),
        child: Container(
          margin: EdgeInsets.symmetric(vertical: 10),
          alignment: Alignment.center,
          height: 60,
          child: Text(
            value,
            style: GoogleFonts.montserrat(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            if (widget.bankImg != null)
              Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: Image.network(widget.bankImg!, width: 40),
              ),
            Text(
              widget.accountName?.toLowerCase() ?? 'No Account Name',
              style: GoogleFonts.montserrat(
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
      resizeToAvoidBottomInset: true,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              SizedBox(
                height: 20,
              ),

              // Divider(),
              SizedBox(
                height: 10,
              ),
              Container(
                height: 45,
                width: 220,
                decoration: BoxDecoration(
                    color: myForm, borderRadius: BorderRadius.circular(5)),
                child: Center(
                    child: Text(
                  "NGN Balance : N1,000,000",
                  style: GoogleFonts.montserrat(color: Colors.grey),
                )),
              ),
              SizedBox(
                height: 30,
              ),

              Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 9),
                      decoration: BoxDecoration(
                        color: myForm,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(5.0),
                        child: TextFormField(
                          style: GoogleFonts.montserrat(),
                          controller: _amountController,
                          decoration: InputDecoration(
                            hintText: 'N',
                            border: InputBorder.none,
                          ),
                          readOnly: true,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 8),
                  Text(
                    'NGN',
                    style: GoogleFonts.montserrat(
                        fontWeight: FontWeight.w600, fontSize: 16),
                  ),
                ],
              ),
              SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 8),
                      decoration: BoxDecoration(
                        // border: Border.all(color: Colors.grey.shade400),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: TextFormField(
                        style: GoogleFonts.montserrat(),
                        controller: _narrationController,
                        decoration: InputDecoration(
                          hintText: 'Narration (e.g Sent f',
                          border: InputBorder.none,
                        ),
                        keyboardType: TextInputType.text,
                      ),
                    ),
                  ),
                  SizedBox(width: 8),
                  GestureDetector(
                      onTap: () {
                        _submitTradeUpdate();
                      },
                      child: Icon(
                        Icons.telegram_sharp,
                        size: 50,
                        color: myColor,
                      )),
                ],
              ),
              SizedBox(height: 70),

              Column(
                children: [
                  Row(
                    children: [
                      buildKeypadButton('1'),
                      buildKeypadButton('2'),
                      buildKeypadButton('3'),
                    ],
                  ),
                  Row(
                    children: [
                      buildKeypadButton('4'),
                      buildKeypadButton('5'),
                      buildKeypadButton('6'),
                    ],
                  ),
                  Row(
                    children: [
                      buildKeypadButton('7'),
                      buildKeypadButton('8'),
                      buildKeypadButton('9'),
                    ],
                  ),
                  Row(
                    children: [
                      buildKeypadButton('.'),
                      buildKeypadButton('0'),
                      buildKeypadButton('delete'),
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
