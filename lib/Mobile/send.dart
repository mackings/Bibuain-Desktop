import 'package:bdesktop/Mobile/fund.dart';
import 'package:bdesktop/widgets/colors.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SendMoney extends StatefulWidget {
  const SendMoney({super.key});

  @override
  State<SendMoney> createState() => _SendMoneyState();
}

class _SendMoneyState extends State<SendMoney> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Send Money',
          style: GoogleFonts.montserrat(fontWeight: FontWeight.w700,fontSize: 17),
        ),
        centerTitle: true,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        physics: BouncingScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.only(left: 20, right: 20),
          child: Column(
            children: [
              Container(
                decoration: BoxDecoration(
                  color: myForm,
                  borderRadius: BorderRadius.circular(7),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Row(
                  children: [
                    Icon(Icons.search, color: Colors.grey),
                    SizedBox(width: 10),
                    Expanded(
                      child: TextFormField(
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          hintText: 'Search for anything',
                          hintStyle: GoogleFonts.montserrat(
                              fontWeight: FontWeight.w400, color: Colors.grey),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: 15,
              ),
              Row(
                children: [
                  Text(
                    "Beneficiaries",
                    style: GoogleFonts.montserrat(
                        fontWeight: FontWeight.w700,
                        color: Colors.black,
                        fontSize: 15),
                  ),
                ],
              ),
              SizedBox(
                height: 15,
              ),
              Container(
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.grey),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Column for the texts
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Send to \nBeneficiaries',
                            style: GoogleFonts.montserrat(
                                fontWeight: FontWeight.w700,
                                color: Colors.black,
                                fontSize: 15),
                          ),
                          SizedBox(height: 4), // Space between the texts
                          Text(
                            'Add a beneficiary to get\nstarted',
                            style: GoogleFonts.montserrat(
                                fontWeight: FontWeight.w300,
                                color: Colors.grey,
                                fontSize: 13),
                          ),
                        ],
                      ),
                    ),
                    // Small container with the 'Add' text

                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 35, vertical: 8),
                      decoration: BoxDecoration(
                        color: const Color.fromARGB(255, 80, 141, 190),
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: Text('Add',
                          style: GoogleFonts.montserrat(
                              color: Colors.black,
                              fontWeight: FontWeight.w600)),
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: 15,
              ),
              Row(
                children: [
                  Text(
                    "Free Monthly transfers to other banks",
                    style: GoogleFonts.montserrat(
                        fontWeight: FontWeight.w500,
                        color: Colors.grey,
                        fontSize: 12),
                  ),
                  SizedBox(
                    width: 10,
                  ),
                  Text(
                    "25",
                    style: GoogleFonts.montserrat(
                        fontWeight: FontWeight.w700,
                        color: Colors.black,
                        fontSize: 13),
                  ),
                ],
              ),
              GestureDetector(
                onTap: () {
                                    Navigator.push(
                      context, MaterialPageRoute(builder: (context) => Fund()));
                },
                child: ListTile(
                    title: Text(
                      "Send to @username",
                      style: GoogleFonts.montserrat(
                          fontWeight: FontWeight.w700,
                          color: Colors.black,
                          fontSize: 15),
                    ),
                    subtitle: Text(
                      "Send to any Kuda account for free.",
                      style: GoogleFonts.montserrat(
                          fontWeight: FontWeight.w500,
                          color: Colors.grey,
                          fontSize: 11),
                    ),
                    trailing: Icon(
                      Icons.arrow_forward_ios,
                      color: Colors.grey,
                    ),
                    leading: Image.asset(
                      "assets/kudas.png",
                      width: 30,
                      height: 30,
                    )),
              ),
              GestureDetector(
                onTap: () {
                  Navigator.push(
                      context, MaterialPageRoute(builder: (context) => Fund()));
                },
                child: ListTile(
                    title: Text(
                      "Send to Bank Account",
                      style: GoogleFonts.montserrat(
                          fontWeight: FontWeight.w700,
                          color: Colors.black,
                          fontSize: 15),
                    ),
                    subtitle: Text(
                      "Send to a local bank account.",
                      style: GoogleFonts.montserrat(
                          fontWeight: FontWeight.w500,
                          color: Colors.grey,
                          fontSize: 11),
                    ),
                    trailing: Icon(
                      Icons.arrow_forward_ios,
                      color: Colors.grey,
                    ),
                    leading: Icon(Icons.telegram)),
              ),
              Row(
                children: [
                  Text(
                    "Recents",
                    style: GoogleFonts.montserrat(
                        fontWeight: FontWeight.w700,
                        color: Colors.black,
                        fontSize: 15),
                  ),
                ],
              ),
              SizedBox(
                height: 35,
              ),
              Column(
                children: [
                  CircleAvatar(
                    radius: 40,
                    child: Icon(
                      Icons.no_accounts,
                      size: 40,
                    ),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Text(
                    "Nothing to see yet.",
                    style: GoogleFonts.montserrat(
                        fontWeight: FontWeight.w700,
                        color: Colors.black,
                        fontSize: 13),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Text(
                    "Send some money and we 'll show\n you your recent transactions here",
                    style: GoogleFonts.montserrat(
                        fontWeight: FontWeight.w500,
                        color: Colors.grey,
                        fontSize: 12),
                  ),
                  SizedBox(
                    height: 25,
                  ),
                  Row(
                    children: [
                      Text(
                        "Friends on Kuda",
                        style: GoogleFonts.montserrat(
                            fontWeight: FontWeight.w700,
                            color: Colors.black,
                            fontSize: 15),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 15,
                  ),
                  Container(
                    padding: const EdgeInsets.all(16.0),
                    decoration: BoxDecoration(
                      color: Colors.transparent,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.grey),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Column for the texts
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Sync your\nContacts',
                                style: GoogleFonts.montserrat(
                                    fontWeight: FontWeight.w700,
                                    color: Colors.black,
                                    fontSize: 13),
                              ),
                              SizedBox(height: 4), // Space between the texts
                              Text(
                                'make free transfers easily',
                                style: GoogleFonts.montserrat(
                                    fontWeight: FontWeight.w300,
                                    color: Colors.grey,
                                    fontSize: 12),
                              ),
                            ],
                          ),
                        ),
                        // Small container with the 'Add' text

                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 35, vertical: 8),
                          decoration: BoxDecoration(
                            color: const Color.fromARGB(255, 80, 141, 190),
                            borderRadius: BorderRadius.circular(5),
                          ),
                          child: Text('Connect',
                              style: GoogleFonts.montserrat(
                                  color: Colors.black,
                                  fontWeight: FontWeight.w600)),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 15,
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
