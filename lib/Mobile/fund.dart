import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:google_fonts/google_fonts.dart';

class Fund extends StatefulWidget {
  const Fund({super.key});

  @override
  State<Fund> createState() => _FundState();
}

class _FundState extends State<Fund> {

  final TextEditingController _accountNumberController = TextEditingController();
  String? selectedBankName;
  String? selectedBankCode;
  String? selectedBankLogo;

  Future<void> showBankSelectionSheet(BuildContext context) async {
    final banks = await fetchBanks(); // Fetch banks data

    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Select a Bank',),
              SizedBox(height: 10),
              Text('Popular Banks',),
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
                            Text(bank['name'], overflow: TextOverflow.ellipsis),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
              SizedBox(height: 10),
              Text('All Banks',),
              Expanded(
                child: ListView.builder(
                  itemCount: banks.length,
                  itemBuilder: (context, index) {
                    final bank = banks[index];
                    return ListTile(
                      leading: Image.network(bank['logo']),
                      title: Text(bank['name']),
                      subtitle: Text(bank['code']),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'New NGN Recipient',
          style: GoogleFonts.montserrat(fontWeight: FontWeight.w700),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Bank',style: GoogleFonts.montserrat(fontWeight: FontWeight.w700),),
                Container(
                  child: TextFormField(
                    readOnly: true,
                    decoration: InputDecoration(
                      hintText: 'Select a bank',
                      border: OutlineInputBorder(),
                      prefixIcon: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: selectedBankLogo != null
                            ? Image.network(selectedBankLogo!, width: 40)
                            : null,
                      ),
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
              ],
            ),
            SizedBox(height: 20),
            
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Account Number',style: GoogleFonts.montserrat(fontWeight: FontWeight.w700),),

                Container(
                  child: TextFormField(
                    controller: _accountNumberController,
                    decoration: InputDecoration(
                      hintText: 'Enter account number',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
