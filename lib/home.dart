import 'package:bdesktop/complains.dart';
import 'package:bdesktop/Trainer/payers.dart';
import 'package:bdesktop/trades.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';


class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  static List<Widget> _pages = <Widget>[
  Trades(),
    AllComplains(),

    //AllTrades(),
    Payers(username: '',)
  ];

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
            backgroundColor: Color(0xFFF5F7FB),
            title: Text("DOT"),
            actions: [

              CircleAvatar(
                backgroundColor: Colors.white,
                child: Icon(Icons.notifications,),),

              SizedBox(width: 20,),

              CircleAvatar(
                backgroundColor: Colors.white,
                child: Icon(Icons.person,),
                ),

              SizedBox(width: 20,),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                Icon(Icons.analytics),
                SizedBox(width: 10,),
                Text('Analytics',style: GoogleFonts.poppins(

                ),)
              ],
              ),

              SizedBox(width: 20,),
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
                destinations: [
                  NavigationRailDestination(
                    icon: Icon(Icons.home),
                    selectedIcon: Icon(Icons.home_filled),
                    label: Text(
                      'Home',
                      style: GoogleFonts.poppins(
                        fontSize: 9.sp,
                        fontWeight: FontWeight.w600
                        ),
                    ),
                  ),
                  NavigationRailDestination(
                    icon: Icon(Icons.help_center),
                    // selectedIcon: Icon(Icons.person),
                    label: Text('CC',style: GoogleFonts.poppins(
                        fontSize: 9.sp,
                        fontWeight: FontWeight.w600
                        ),),
                  ),
                  NavigationRailDestination(
                    icon: Icon(Icons.bar_chart),
                    selectedIcon: Icon(Icons.bar_chart),
                    label: Text('Trades',style: GoogleFonts.poppins(
                        fontSize: 9.sp,
                        fontWeight: FontWeight.w600
                        ),),
                  ),
                  NavigationRailDestination(
                    icon: Icon(Icons.settings),
                    selectedIcon: Icon(Icons.person),
                    label: Text('Payers',style: GoogleFonts.poppins(
                        fontSize: 9.sp,
                        fontWeight: FontWeight.w600
                        ),),
                  ),
                ],
              ),
              VerticalDivider(thickness: 1, width: 1),
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
