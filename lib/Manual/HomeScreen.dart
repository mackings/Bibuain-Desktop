import 'package:bdesktop/Manual/Dashboard/Views/Overviews/Alloverviews.dart';
import 'package:bdesktop/Manual/Dashboard/Views/Resumptions/Clocks.dart';
import 'package:bdesktop/Manual/Dashboard/Views/Overviews/overview.dart';
import 'package:bdesktop/Manual/Dashboard/Views/Query/staffquery.dart';
import 'package:bdesktop/Manual/Trade%20Pool/PayingGround.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';



class PayersHomeScreen extends StatefulWidget {
  final String username;

  const PayersHomeScreen({Key? key, required this.username}) : super(key: key);

  @override
  State<PayersHomeScreen> createState() => _PayersHomeScreenState();
}

class _PayersHomeScreenState extends State<PayersHomeScreen> {
  int _selectedIndex = 0;

  // Define all the pages you want to navigate to
  late List<Widget> _pages;

  @override
  void initState() {
    super.initState();

    // Initialize the list of pages
    _pages = <Widget>[
      StaffOverview(),
      Payment(username: widget.username),  
      StaffQuery(),
      ALLStaffOverview(),
      Clocks(),
      Clocks(),
      
    ];
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Sizer(
      builder: (context, orientation, deviceType) {
        return Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: const Color(0xFF030832),
          iconTheme: const IconThemeData(color: Colors.white),
          title: Text(
            "Welcome, ${widget.username}",
            style: GoogleFonts.montserrat(
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: () {
                setState(() {
                  //fetchData(); // Refresh the data
                });
              },
            ),
          ],
        ),
        body: Row(
          children: <Widget>[
            NavigationRail(
              backgroundColor: Color(0xFFF5F7FB),
              selectedIndex: _selectedIndex,
              onDestinationSelected: _onItemTapped,
              labelType: NavigationRailLabelType.none,
              extended: true,
              selectedLabelTextStyle: TextStyle(
                color: Colors.purple, // The highlight color for text when selected
              ),
              // Add space above the first navigation item
              leading: SizedBox(height: 10), // This adds 50px of space at the top
              destinations: [
                NavigationRailDestination(
                  icon: Icon(Icons.dashboard_customize_outlined),
                  selectedIcon: Icon(Icons.dashboard_customize, color: Colors.purple), // Highlighted icon when selected
                  label: Text(
                    'Dashboard',
                    style: GoogleFonts.poppins(
                      fontSize: 7.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.account_balance_outlined),
                  selectedIcon: Icon(Icons.account_balance, color: Colors.blue),
                  label: Text(
                    'Pay center',
                    style: GoogleFonts.poppins(
                      fontSize: 7.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.chalet),
                  selectedIcon: Icon(Icons.chalet_outlined, color: Colors.blue),
                  label: Text(
                    'Query',
                    style: GoogleFonts.poppins(
                      fontSize: 7.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),

               NavigationRailDestination(
                  icon: Icon(Icons.history_edu_outlined),
                  selectedIcon: Icon(Icons.history_edu_outlined, color: Colors.blue),
                  label: Text(
                    'Transactions',
                    style: GoogleFonts.poppins(
                      fontSize: 7.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),


                NavigationRailDestination(
                  icon: Icon(Icons.fingerprint),
                  selectedIcon: Icon(Icons.fingerprint_outlined, color: Colors.blue),
                  label: Text(
                    'Resumptions',
                    style: GoogleFonts.poppins(
                      fontSize: 7.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            VerticalDivider(thickness: 1, width: 1),

            // Display the selected page
            Expanded(
              child: _pages[_selectedIndex],
            ),
          ],
        ),
      );
      },
    );
  }
}
