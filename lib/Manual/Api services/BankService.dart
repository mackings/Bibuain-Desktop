import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:google_fonts/google_fonts.dart';

class AccountService {


  final Map<String, String> bankCodes = {

    "Abbey Mortgage Bank": "801",
    "Above Only MFB": "51226",
    "Access Bank": "044",
    "Access": "044",
    "Access Bank (Diamond)": "063",
    "ALAT by WEMA": "035A",
    "Amju Unique MFB": "50926",
    "ASO Savings and Loans": "401",
    "Bainescredit MFB": "51229",
    "Bowen Microfinance Bank": "50931",
    "Carbon": "565",
    "Chipper cash": "120001",
    "9 payment service": "120001",
    "CEMCS Microfinance Bank": "50823",
    "Citibank Nigeria": "023",
    "Coronation Merchant Bank": "559",
    "Ecobank Nigeria": "050",
    "Ekondo Microfinance Bank": "562",
    "Eyowo": "50126",
    "Fidelity Bank": "070",
    "Firmus MFB": "51314",
    "First Bank of Nigeria": "011",
    "First Bank": "011",
    "First City Monument Bank": "214",
    "FCMB": "214",
    "FSDH Merchant Bank Limited": "501",
    "Globus Bank": "00103",
    "GoMoney": "100022",
    "Guaranty Trust Bank": "058",
    "GT Bank": "058",
    "GT": "058",
    "Hackman Microfinance Bank": "51233",
    "Hasal Microfinance Bank": "50383",
    "Heritage Bank": "030",
    "Ibile Microfinance Bank": "51244",
    "Infinity MFB": "50457",
    "Jaiz Bank": "301",
    "Kadpoly MFB": "50502",
    "Keystone Bank": "082",
    "Kredi Money MFB LTD": "50211",
    "Kuda Bank": "50211",
    "Kuda": "50211",
    "Lagos Building Investment Company Plc.": "90052",
    "Links MFB": "50549",
    "Lotus Bank": "303",
    "Mayfair MFB": "50563",
    "Moniepoint MFB": "50515",
    "Moniepoint": "50515",
    "Monie point": "50515",
    "Moni point": "50515",
    "Mint MFB": "50212",
    "Paga": "100002",
    "PalmPay": "999991",
    "Palm Pay": "999991",
    "Parallex Bank": "526",
    "Parkway - ReadyCash": "311",
    "Opay": "999992",
    "Petra Microfinance Bank Plc": "50746",
    "Polaris Bank": "076",
    "Providus Bank": "101",
    "QuickFund MFB": "51268",
    "Rand Merchant Bank": "502",
    "Rubies MFB": "51318",
    "Sparkle Microfinance Bank": "51320",
    "Stanbic IBTC Bank": "221",
    "Stanbic IBTC": "221",
    "Standard Chartered Bank": "068",
    "Sterling Bank": "232",
    "Suntrust Bank": "100",
    "TAJ Bank": "302",
    "Tangerine Money": "51269",
    "TCF MFB": "51211",
    "Titan Bank": "102",
    "Unical MFB": "50855",
    "Union Bank of Nigeria": "032",
    "Union Bank": "032",
    "United Bank For Africa": "033",
    "UBA": "033",
    "Unity Bank": "215",
    "VFD Microfinance Bank Limited": "566",
    "VFD": "566",
    "Wema Bank": "035",
    "Zenith Bank": "057",
    "Zenith": "057"
  };



  bool isVerified = false;
  Set<String> verifiedAccounts = {};

  /// Function to verify account
  Future<void> verifyAccount(
    BuildContext context,
    String recentAccountNumber,
    String recentBankCode,
    void Function() initializeTimer, // Pass in the timer initialization method
  ) async {
    if (verifiedAccounts.contains(recentAccountNumber)) {
      print('Account $recentAccountNumber already verified');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '$recentAccountNumber Has been Verified.',
            style: GoogleFonts.poppins(),
          ),
          duration: const Duration(seconds: 5),
        ),
      );
      return;
    }

    final url = Uri.parse(
        'https://server-eight-beige.vercel.app/api/wallet/generateBankDetails/$recentAccountNumber/$recentBankCode');

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        initializeTimer(); // Call the timer initialization method
        final data = json.decode(response.body);
        final accountName = data['data']['account_name'];
        print('Verified >>> : $data');

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '$accountName Verified for Payment.',
            style: GoogleFonts.poppins(),
          ),
          duration: const Duration(seconds: 5),
        ),
      );

        verifiedAccounts.add(recentAccountNumber);
        isVerified = true;
      } else {
        isVerified = false;
        print('Error: ${response.statusCode}');
      }
    } catch (e) {
      isVerified = false;
      print('Error: $e');
    }
  }

  /// Function to process incoming messages and extract relevant account information
  


  void processMessages(
    List<Map<String, dynamic>> messages,
    BuildContext context,
    String? recentAccountNumber,
    String? recentPersonName,
    String? recentBankName,
    String? recentBankCode,
    void Function() initializeTimer,
  ) {
    String? newAccountNumber;
    String? newPersonName;
    String? newBankName;
    String? newBankCode;

    for (var message in messages) {
      final messageText = message['text'].toString();

      // Regex to find 10-digit account number
      final accountNumberRegex = RegExp(r'\b\d{10}\b');
      final accountNumberMatch = accountNumberRegex.firstMatch(messageText);
      final nameRegex = RegExp(r'\b[A-Z][a-z]*\b(?:\s\b[A-Z][a-z]*\b)?');
      final nameMatch = nameRegex.firstMatch(messageText);

      // Find the bank name from the bankCodes map
      String? bankNameMatch;
      for (var bankName in bankCodes.keys) {
        if (messageText.toLowerCase().contains(bankName.toLowerCase())) {
          bankNameMatch = bankName;
          newBankCode = bankCodes[bankName];
          break;
        }
      }

      if (accountNumberMatch != null) {
        newAccountNumber = accountNumberMatch.group(0);
      }
      if (nameMatch != null) {
        newPersonName = nameMatch.group(0);
      }
      if (bankNameMatch != null) {
        newBankName = bankNameMatch;
      }
    }

    // If any changes in account number, person name, bank name, or bank code, update the state and verify account
    if (newAccountNumber != recentAccountNumber ||
        newPersonName != recentPersonName ||
        newBankName != recentBankName ||
        newBankCode != recentBankCode) {
          
      recentAccountNumber = newAccountNumber;
      recentPersonName = newPersonName;
      recentBankName = newBankName;
      recentBankCode = newBankCode;

      print("Name: >> $recentPersonName");
      print('Account Nos: >>> $recentAccountNumber');
      print('Bank: >>>> $recentBankName');
      print('Bank Code: >>>> $recentBankCode');

      // Call the account verification function
      verifyAccount(
        context,
        recentAccountNumber!,
        recentBankCode!,
        initializeTimer, // Pass the timer initialization method
      );
    }
  }


}
