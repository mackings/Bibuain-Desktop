import 'package:bdesktop/Configuration/Model/model.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:skeletonizer/skeletonizer.dart'; 

class AccountOffersWidget extends StatefulWidget {
  final Future<List<AccountOffers>> futureOffers;

  const AccountOffersWidget({
    Key? key,
    required this.futureOffers, 
  }) : super(key: key);

  @override
  _AccountOffersWidgetState createState() => _AccountOffersWidgetState();
}

class _AccountOffersWidgetState extends State<AccountOffersWidget> {
  bool _isDropdownExpanded = false;
  List<AccountOffers>? _lastOffers; // Variable to store last fetched offers

  @override
  void initState() {
    super.initState();
    // Use FutureBuilder to set the last offers once fetched
    widget.futureOffers.then((offers) {
      setState(() {
        _lastOffers = offers;
      });
    }).catchError((error) {
      // Handle error if needed
      print('Error fetching offers: $error');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: FutureBuilder<List<AccountOffers>>(
        future: widget.futureOffers,
        builder: (context, offersSnapshot) {
          // Show skeleton while data is loading
          bool isLoading = offersSnapshot.connectionState == ConnectionState.waiting;

          return Skeletonizer(
            enabled: isLoading, // Show skeleton if loading
            child: isLoading && _lastOffers != null
                ? _buildOffersList(_lastOffers!) // Show last fetched offers while loading
                : offersSnapshot.hasError
                    ? Center(child: Text('Error: ${offersSnapshot.error}'))
                    : offersSnapshot.hasData && offersSnapshot.data!.isNotEmpty
                        ? _buildOffersList(offersSnapshot.data!)
                        : const Center(child: Text('No offers found')),
          );
        },
      ),
    );
  }

  Widget _buildOffersList(List<AccountOffers> offers) {
    return Column(
      children: [
        // Dropdown button to toggle visibility
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(width: 0.5),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Select Account',
                    style: GoogleFonts.montserrat(
                      fontWeight: FontWeight.w500,
                      fontSize: 16,
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      _isDropdownExpanded
                          ? Icons.keyboard_arrow_up
                          : Icons.keyboard_arrow_down,
                    ),
                    onPressed: () {
                      setState(() {
                        _isDropdownExpanded = !_isDropdownExpanded;
                      });
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
        // Conditionally show the list of accounts when expanded
        _isDropdownExpanded
            ? Expanded(
                child: ListView.builder(
                  itemCount: offers.length,
                  itemBuilder: (context, index) {
                    var account = offers[index];
                    double commonMargin = account.offers.first.margin;
                    double commonFiatPricePerBtc = account.offers.first.fiatPricePerBtc;

                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(width: 0.3, color: Colors.grey),
                          color: Colors.white,
                        ),
                        child: Column(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.vertical(top: Radius.circular(6)),
                                color: Colors.grey[200],
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    account.username.toUpperCase(),
                                    style: GoogleFonts.montserrat(
                                      fontWeight: FontWeight.w500,
                                      fontSize: 12,
                                    ),
                                  ),
                                  IconButton(
                                    icon: Icon(Icons.info_outline, size: 18),
                                    onPressed: () {
                                      print('More info for account: ${account.username}');
                                    },
                                  ),
                                ],
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Margin: ${NumberFormat('#,##0.00').format(commonMargin)}',
                                    style: GoogleFonts.montserrat(
                                      fontWeight: FontWeight.w400,
                                      fontSize: 10,
                                    ),
                                  ),
                                  Text(
                                    'Price: ${NumberFormat('#,##0').format(commonFiatPricePerBtc)} NGN/BTC',
                                    style: GoogleFonts.montserrat(
                                      fontWeight: FontWeight.w400,
                                      fontSize: 10,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              )
            : Container(),
      ],
    );
  }
}


