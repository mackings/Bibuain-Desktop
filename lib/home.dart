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




  // Future<void> _markTradeAsCC(BuildContext context, String username) async {
  //   try { 
  //     final response = await http.post(
  //       Uri.parse('https://b-backend-xe8q.onrender.com/Trade/mark'),
  //       headers: {'Content-Type': 'application/json'},
  //       body: jsonEncode({
  //         'trade_hash': selectedTradeHash,
  //         'markedAt': 'complain', // Using the elapsed time
  //         'amountPaid': fiatAmount,
  //       }),
  //     );

  //     if (response.statusCode == 200) {
  //       print(">>>>> Marked ${response.body}");
  //       await FirebaseFirestore.instance
  //           .collection('manualsystem')
  //           .doc(loggedInStaffID)
  //           .update({
  //         'assignedTrades': FieldValue.arrayRemove([selectedTradeHash]),
  //       });

  //       await FirebaseFirestore.instance
  //           .collection('manualsystem')
  //           .doc(selectedTradeHash)
  //           .update({
  //         'isPaid': false,
  //       });

  //       // Reset UI elements and start listening for new trades
  //       WidgetsBinding.instance.addPostFrameCallback((_) {
  //         if (mounted) {
  //           setState(() {
  //             selectedTradeHash = null;
  //           });
  //         }
  //       });

  //       setState(() {
  //         selectedTradeHash = null; // Reset selected trade
  //       });
  //     } else {
  //       print('Failed to mark trade as paid: ${response.body}');
  //     }
  //   } catch (e) {
  //     setState(() {
  //       selectedTradeHash = null;
  //     });
  //     print('Error making API call: $e');
  //   }
  // }

// Future<void> _markAsComplain() async {
//   if (selectedTradeHash == null) {
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(content: Text('No trade selected.')),
//     );
//     return;
//   }

//   try {
//     final tradeDoc = await FirebaseFirestore.instance
//         .collection('manualsystem')
//         .doc(selectedTradeHash)
//         .get();

//     if (tradeDoc.exists) {
//       final tradeData = tradeDoc.data() as Map<String, dynamic>;

//       // Copy trade data to 'complaints' collection
//       await FirebaseFirestore.instance
//           .collection('complaints')
//           .doc(selectedTradeHash)
//           .set(tradeData);

//       // Update the status to 'unresolved'
//       await FirebaseFirestore.instance
//           .collection('complaints')
//           .doc(selectedTradeHash)
//           .update({'status': 'unresolved'});

//       // Refresh UI by clearing selected trade and triggering a UI rebuild
//       WidgetsBinding.instance.addPostFrameCallback((_) {
//         if (mounted) {
//           setState(() {
//             selectedTradeHash = null;
            
//           });
//         }
//       });

//       // Show success Snackbar
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Trade marked as complaint successfully.')),
//       );
//     } else {
//       // Show Snackbar if trade not found
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Trade not found.')),
//       );
//     }
//   } catch (e) {
//     // Show error Snackbar
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(content: Text('An error occurred: $e')),
//     );
//   }
// }
