import 'package:bdesktop/HR/models/staffmodel.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';


class StaffInfoContainer extends StatelessWidget {
  final String title;
  final List<Staff> staffDetails; // Change to List<Staff>

  const StaffInfoContainer({
    Key? key,
    required this.title,
    required this.staffDetails,
  }) : super(key: key);

  String shortenName(String name, {int maxLength = 15}) {
  if (name.length > maxLength) {
    return '${name.substring(0, maxLength)}...';
  }
  return name;
}

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.3, // Set a specific width for the container
      decoration: BoxDecoration(
        border: Border.all(width: 0.5, color: Colors.grey),
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              title,
              style: GoogleFonts.montserrat(),
            ),
          ),
          Container(
            height: 300, // Set a fixed height here
            child: SingleChildScrollView(
              child: Column(
                children: staffDetails.map((staff) {
                  return Column(
                    children: [
                      ListTile(
                        leading: CircleAvatar(
                          child: Icon(Icons.person_2_outlined),
                        ),
                        title: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Flexible(
                                  child: Text('Name', style: GoogleFonts.montserrat(fontSize: 15)),
                                ),
Flexible(
  child: Text(
    shortenName(staff.username), // Use the helper function here
    style: GoogleFonts.montserrat(fontSize: 15),
  ),
),

                              ],
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Flexible(
                                  child: Text('Role', style: GoogleFonts.montserrat(fontSize: 15)),
                                ),
                                Flexible(
                                  child: Text(staff.role, style: GoogleFonts.montserrat(fontSize: 15)), // Access the role property
                                ),
                              ],
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [

                                Flexible(
                                  child: Text('Status', style: GoogleFonts.montserrat(fontSize: 15)),
                                ),
                                Flexible(
                                  child: Text('${staff.clockedIn ==true?"Active":"Inactive"}', style: GoogleFonts.montserrat(fontSize: 15)), // Access the status property
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Divider(),
                      ),
                    ],
                  );
                }).toList(),
              ),
            ),
          ),
          SizedBox(height: 30,)
        ],
      ),
    );
  }
}
