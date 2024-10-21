import 'dart:async';

import 'package:bdesktop/Configuration/Api/configClass.dart';
import 'package:bdesktop/Configuration/Model/model.dart';
import 'package:bdesktop/Configuration/Widgets/Accountoffers.dart';
import 'package:bdesktop/Configuration/Widgets/Confdialog.dart';
import 'package:bdesktop/Configuration/Widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:skeletonizer/skeletonizer.dart';




class Configdashboard extends StatefulWidget {
  const Configdashboard({super.key});

  @override
  State<Configdashboard> createState() => _ConfigdashboardState();
}

class _ConfigdashboardState extends State<Configdashboard> {
  Timer? _timer;
  late Future<List<AccountOffers>> futureOffers;
  late Future<Map<String, dynamic>> futureRates;
  dynamic marginDisplay = '';
  dynamic CP;
  dynamic SP;
  dynamic CM;

  @override
  void initState() {
    super.initState();
    fetchData();

    _timer = Timer.periodic(Duration(seconds: 60), (timer) {
      fetchData();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

void fetchData() {
  futureOffers = OfferService().fetchOffers();
  futureRates = OfferService()
      .fetchRates(nusername: 'Eden_Ageh', pusername: 'MeekWhistler588');

  // Handle the rates data fetching
  futureRates.then((ratesData) async {
    print("Rates Data: $ratesData");

    // Await the calculatePrices result, since it's a Future
    Map<String, double> prices = await OfferService().calculatePrices(ratesData);

    setState(() {
      CP = prices['CP'];
      SP = prices['SP'];
      CM = prices['Margin'];
    });
    print("Prices $prices");
  }).catchError((error) {
    print("Error fetching rates: $error");
  });

  futureOffers.then((offersData) {}).catchError((error) {
    print("Error fetching offers: $error");
  });
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
  appBar: AppBar(
    backgroundColor: const Color(0xFF030832),
    iconTheme: const IconThemeData(color: Colors.white),
    title: Text(
      "Rates Configurations",
      style: GoogleFonts.montserrat(
        fontWeight: FontWeight.w600,
        color: Colors.white,
      ),
    ),
    actions: [
      IconButton(
        icon: const Icon(Icons.refresh),
        onPressed: () {
          fetchData(); // Refresh the data
        },
      ),
    ],
  ),

  
  body: FutureBuilder<Map<String, dynamic>>(
    future: futureRates,
    builder: (context, ratesSnapshot) {
      if (ratesSnapshot.connectionState == ConnectionState.waiting) {
        return Center(
          child: Skeletonizer(child: Icon(Icons.report_problem_outlined,size: 200,))
        );
      } else if (ratesSnapshot.hasError) {
        return Center(child: Text('Error: ${ratesSnapshot.error}'));
      } else if (!ratesSnapshot.hasData) {
        return const Center(child: Text('No rates data available'));
      } else {
        final ratesData = ratesSnapshot.data!;
        return Padding(
          padding: const EdgeInsets.only(top: 40, right: 20, left: 20),
          child: Column(
            children: [
              Row(
                children: [

                  Expanded(
                    child: FutureBuilder<List<AccountOffers>>(
                      future: futureOffers,
                      builder: (context, offersSnapshot) {
                        return Skeletonizer(
                          enabled: offersSnapshot.connectionState ==
                              ConnectionState.waiting,
                          child: offersSnapshot.connectionState ==
                                  ConnectionState.waiting
                              ? const Center(
                                  child: CircularProgressIndicator())
                              : offersSnapshot.hasError
                                  ? Center(
                                      child: Text(
                                          'Error: ${offersSnapshot.error}'))
                                  : !offersSnapshot.hasData ||
                                          offersSnapshot.data!.isEmpty
                                      ? const Center(
                                          child: Text('No offers found'))
                                      : _buildOffersDisplay(
                                          offersSnapshot.data!),
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 30),

                  // Rate containers wrapped with Skeletonizer
                  Skeletonizer(
                    enabled: ratesSnapshot.connectionState ==
                        ConnectionState.waiting,
                    child: Row(
                      children: [
                        _buildRateContainer(
                          'Noones',
                          ratesData['noonesRate']['data'] ?? 'N/A',
                          Colors.lightGreen,
                        ),
                        _buildRateContainer(
                          'Paxful',
                          ratesData['paxfulRate']['data'] ?? 'N/A',
                          Colors.blue,
                        ),
                        _buildRateContainer(
                          'Binance',
                          ratesData['binanceRate']['price'] ?? 'N/A',
                          Colors.yellow,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 30),

                  // Price Container to show CP and SP
                  Skeletonizer(
                    enabled: CP == null || SP == null, // Check if data is null
                    child: PriceContainer(
                      cpLabel: 'CP',
                      spLabel: 'SP',
                      cpPrice: NumberFormat("#,##0").format(CP ?? 0),
                      spPrice: NumberFormat("#,##0").format(SP ?? 0),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              Expanded(
                child: Row(
                  children: [
                    AccountOffersWidget(futureOffers: futureOffers),
                    const SizedBox(width: 10),
                    AccountOffersWidget(futureOffers: futureOffers),
                  ],
                ),
              ),
            ],
          ),
        );
      }
    },
  ),
  floatingActionButton: FloatingActionButton(
    child: Icon(Icons.settings),
    onPressed: () {
      showDialog(
        context: context,
        builder: (context) => ConfigurationsDialog(),
      );
    },
  ),
);

  }

  Widget _buildOffersDisplay(List<AccountOffers> offers) {
    List<double> margins = offers.expand((account) {
      return account.offers.map((offer) => offer.margin);
    }).toList();

    bool allSameMargins = margins.every((margin) => margin == margins[0]);
    String marginDisplay = allSameMargins ? '${margins[0]}%' : 'Varied';

    return Container(
      width: 10,
      height: 130,
      decoration: BoxDecoration(
        color: Colors.purpleAccent,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 10),
              child: Align(
                alignment: Alignment.topLeft,
                child: Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFF030832),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(width: 0.5),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      'Live Margin',
                      style: GoogleFonts.montserrat(
                        fontSize: 10,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ),

Text(
  (CM ?? 0).toStringAsFixed(2),  
  style: GoogleFonts.montserrat(
    fontSize: 36,
    fontWeight: FontWeight.bold,
    color: Colors.white,
  ),
),



          ],
        ),
      ),
    );
  }


  Widget _buildRateContainer(String platform, num rate, Color color) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        width: 170,
        height: 105,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              platform,
              style: GoogleFonts.montserrat(
                fontWeight: FontWeight.w500,
                fontSize: 16,
                color: Colors.grey[850],
              ),
            ),
            const SizedBox(height: 10),
            Text(
              rate.toString(),
              style: GoogleFonts.montserrat(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF2C2B2B),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
