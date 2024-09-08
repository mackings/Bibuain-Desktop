import 'dart:convert';
import 'package:bdesktop/Mobile/description.dart';
import 'package:bdesktop/Mobile/home.dart';
import 'package:bdesktop/widgets/colors.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:google_fonts/google_fonts.dart';

class Fund extends StatefulWidget {
  const Fund({super.key});

  @override
  State<Fund> createState() => _FundState();
}

class _FundState extends State<Fund> {
  final TextEditingController _accountNumberController =
      TextEditingController();
  String? selectedBankName;
  String? selectedBankCode;
  String? selectedBankLogo;
  String? accountName;
  bool isLoading = false;
  bool showAccountName = false;

  Future<void> showBankSelectionSheet(BuildContext context) async {
    final banks = await fetchBanks(); // Fetch banks data

showModalBottomSheet(
  context: context,
  isScrollControlled: true, // This makes the bottom sheet expand more
  builder: (context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.85, // Make it 85% of the screen height
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Select a Bank', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          SizedBox(height: 10),
          Text('Popular Banks', style: TextStyle(fontSize: 16)),
          SizedBox(
            height: 100,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: banks.take(5).map((bank) {
                return GestureDetector(
                  onTap: () {
                    _selectBank(bank);
                    Navigator.pop(context);
                  },
                  child: Container(
                    width: 100,
                    margin: EdgeInsets.only(right: 8),
                    child: Column(
                      children: [
                        Image.network(bank['logo'], height: 50),
                        SizedBox(height: 5),
                        Text(bank['name'], overflow: TextOverflow.ellipsis),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          SizedBox(height: 10),
          Text('All Banks', style: TextStyle(fontSize: 16)),
          Expanded(
            child: ListView.builder(
              itemCount: banks.length,
              itemBuilder: (context, index) {
                final bank = banks[index];
                return ListTile(
                  leading: Image.network(bank['logo'], height: 30),
                  title: Text(bank['name']),
                  // subtitle: Text(bank['code']),
                  onTap: () {
                    _selectBank(bank);
                    Navigator.pop(context);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  },
);

  }

  Future<List<dynamic>> fetchBanks() async {
    final response = await http.get(Uri.parse('https://nigerianbanks.xyz/'));
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load banks');
    }
  }

  void _selectBank(Map<String, dynamic> bank) {
    setState(() {
      selectedBankName = bank['name'];
      selectedBankCode = bank['code'];
      selectedBankLogo = bank['logo'];
    });
  }

  Future<void> verifyAccountDetails(
      String accountNumber, String bankCode) async {
    setState(() {
      isLoading = true; // Show progress indicator
      showAccountName = false; // Hide the account name temporarily
    });

    final response = await http.get(
      Uri.parse(
          'https://server-eight-beige.vercel.app/api/wallet/generateBankDetails/$accountNumber/$bankCode'),
    );
    print("Acc $accountNumber");
    print("Code $bankCode");
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      print(response.body);
      setState(() {
        accountName = data['data']
            ['account_name']; // Assuming the API returns 'accountName'
        showAccountName = true; // Show the account name
      });
    } else {
      print(response.body);
      setState(() {
        accountName = 'Verification failed';
        showAccountName = true;
      });
    }

    setState(() {
      isLoading = false; // Hide progress indicator
    });
  }

  @override
  void initState() {
    super.initState();
    _accountNumberController.addListener(() {
      if (_accountNumberController.text.length == 10 &&
          selectedBankCode != null) {
        verifyAccountDetails(_accountNumberController.text, selectedBankCode!);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'New NGN Recipi...',
          style: GoogleFonts.montserrat(fontWeight: FontWeight.w700,
          fontSize: 15),
        ),
        centerTitle: true,
        bottom: isLoading
            ? const PreferredSize(
                preferredSize: Size(double.infinity, 4.0),
                child: LinearProgressIndicator(),
              )
            : null,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Bank',
                      style: GoogleFonts.montserrat(fontWeight: FontWeight.w700)),
                  GestureDetector(
                    onTap: () {
                      showBankSelectionSheet(context);
                    },
                    child: Container(
                      decoration: BoxDecoration(
                          color: myForm, borderRadius: BorderRadius.circular(7)),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10,vertical: 4),
                        child: TextFormField(
                          readOnly: true,
                          decoration: InputDecoration(
                            hintText: 'Select a bank',
                            border: InputBorder.none,
                            prefix: selectedBankLogo != null
                                ? Image.network(selectedBankLogo!, width: 40)
                                : null,
                            suffixIcon: IconButton(
                              icon: Icon(Icons.arrow_drop_down),
                              onPressed: () {
                                showBankSelectionSheet(context);
                              },
                            ),
                          ),
                          controller: TextEditingController(text: selectedBankName),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Account Number',
                      style: GoogleFonts.montserrat(fontWeight: FontWeight.w700)),
                  Container(
                    decoration: BoxDecoration(
                        color: myForm, borderRadius: BorderRadius.circular(7)),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10,vertical: 4),
                      child: TextFormField(
                        controller: _accountNumberController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                            hintText: 'Enter account number',
                            border: InputBorder.none),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 10),
              if (showAccountName)
                Row(
                  children: [
                    Icon(
                      Icons.check_circle,
                      color: Colors.green,
                    ),
                    SizedBox(
                      width: 5,
                    ),
                    Text('$accountName', style: GoogleFonts.montserrat()),
                  ],
                ),
              SizedBox(
                height: 310,
              ),
              GestureDetector(
                onTap: () {
                  if(showAccountName)
                  Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => Description(
        accountName: accountName,
        bankImg: selectedBankLogo,
        ),
          ),
        );
        else{
            Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => Apphome(username: "")
          ),
        );
        }
        
        
                },
                child: Container(
                  height: 50,
                  width: MediaQuery.of(context).size.width - 20,
                  decoration: BoxDecoration(
                    color: myColor,
                  ),
                  child: Center(
                      child: Text(
                    "Next",
                    style: GoogleFonts.montserrat(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w500),
                  )),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
