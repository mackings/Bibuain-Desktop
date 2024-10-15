import 'package:bdesktop/Configuration/Api/configClass.dart';
import 'package:bdesktop/Configuration/Model/model.dart';
import 'package:bdesktop/Configuration/Widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';



class Configdashboard extends StatefulWidget {
  const Configdashboard({super.key});

  @override
  State<Configdashboard> createState() => _ConfigdashboardState();
}

class _ConfigdashboardState extends State<Configdashboard> {
  late Future<List<AccountOffers>> futureOffers;
  late Future<Map<String, dynamic>> futureRates;
  dynamic marginDisplay = '';
  dynamic CP;
  dynamic SP;

  @override
  void initState() {
    super.initState();
    fetchData();
  }

void fetchData() {
  futureOffers = OfferService().fetchOffers();
  futureRates = OfferService().fetchRates(nusername: 'Eden_Ageh', pusername: 'MeekWhistler588');

  futureRates.then((ratesData) {
    // Calculate CP and SP using the calculatePrices method
    Map<String, double> prices = OfferService().calculatePrices(ratesData);

    // Update the UI with the calculated CP and SP values
    setState(() {
      CP = prices['CP']!; // Using the calculated CP
      SP = prices['SP']!; // Using the calculated SP
    });
  }).catchError((error) {
    print("Error fetching rates: $error");
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
              setState(() {
                fetchData(); // Refresh the data
              });
            },
          ),
        ],
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: futureRates,
        builder: (context, ratesSnapshot) {
          if (ratesSnapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
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
                  // First Row - dynamic margin, rate containers, and selling price
                  Row(
                    children: [
                      // Expanded FutureBuilder for dynamic margin
                      Expanded(
                        child: FutureBuilder<List<AccountOffers>>(
                          future: futureOffers,
                          builder: (context, offersSnapshot) {
                            if (offersSnapshot.connectionState == ConnectionState.waiting) {
                              return const Center(
                                  child: CircularProgressIndicator());
                            } else if (offersSnapshot.hasError) {
                              return Center(
                                  child: Text('Error: ${offersSnapshot.error}'));
                            } else if (!offersSnapshot.hasData || offersSnapshot.data!.isEmpty) {
                              return const Center(child: Text('No offers found'));
                            } else {
                              // Extract margins and check if they are the same
                              var allOffers = offersSnapshot.data!;
                              List<double> margins = allOffers.expand((account) {
                                return account.offers.map((offer) => offer.margin);
                              }).toList();

                              bool allSameMargins = margins
                                  .every((margin) => margin == margins[0]);
                              dynamic marginDisplay = allSameMargins
                                  ? '${margins[0]}%' // All margins are the same, show the first one
                                  : 'Varied'; // If margins vary, show "Varied"

                              return Container(
                                width: 150,
                                height: 130,
                                decoration: BoxDecoration(
                                    color: Colors.purpleAccent,
                                    borderRadius: BorderRadius.circular(10)),
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
                                                color: Color(0xFF030832),
                                                borderRadius: BorderRadius.circular(10),
                                                border: Border.all(width: 0.5)),
                                            child: Padding(
                                              padding: const EdgeInsets.all(8.0),
                                              child: Text(
                                                ' Update Margin',
                                                style: GoogleFonts.montserrat(
                                                  fontSize: 10,
                                                  color: Colors.white,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                      // Display the dynamic margin here
                                      Text(
                                        marginDisplay,
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
                          },
                        ),
                      ),
                      const SizedBox(width: 30),

                      // Rate containers
                      Row(
                        children: [
                          _buildRateContainer(
                              'Noones', ratesData['noonesRate']['data']),
                          _buildRateContainer(
                              'Paxful', ratesData['paxfulRate']['data']),
                          _buildRateContainer(
                              'Binance', ratesData['binanceRate']['price']),
                        ],
                      ),

                      const SizedBox(width: 30),

                      // Price Container to show CP and SP
                      PriceContainer(
                        cpLabel: 'CP',
                        spLabel: 'SP',
                        cpPrice: NumberFormat("#,##0").format(CP ?? 0), // Show CP value
                        spPrice: NumberFormat("#,##0").format(SP ?? 0), // Show SP value
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

Expanded(
  child: FutureBuilder<List<AccountOffers>>(
    future: futureOffers,
    builder: (context, offersSnapshot) {
      if (offersSnapshot.connectionState == ConnectionState.waiting) {
        return const Center(child: CircularProgressIndicator());
      } else if (offersSnapshot.hasError) {
        return Center(child: Text('Error: ${offersSnapshot.error}'));
      } else if (!offersSnapshot.hasData || offersSnapshot.data!.isEmpty) {
        return const Center(child: Text('No offers found'));
      } else {
        var allOffers = offersSnapshot.data!;

        return Column(
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: allOffers.length,
                itemBuilder: (context, index) {
                  var account = allOffers[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 40),
                    child: Container(
                      width: 60,
                      decoration: BoxDecoration(
                        border: Border.all(width: 0.5, color: Colors.grey),
                      ),
                      child: ExpansionTile(
                        title: Text(
                          account.username.toUpperCase(),
                          style: GoogleFonts.montserrat(
                            fontWeight: FontWeight.w500,
                            fontSize: 16,
                          ),
                        ),
                        children: account.offers.map((offer) {
                          return ListTile(
                            title: Text(
                              '${offer.paymentMethodName} - ${offer.fiatPricePerBtc} NGN/BTC',
                              style: GoogleFonts.montserrat(
                                fontWeight: FontWeight.w400,
                                fontSize: 14,
                              ),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Offer Link: ${offer.offerLink}',
                                  style: GoogleFonts.montserrat(
                                    fontSize: 12,
                                  ),
                                ),

Text(
  'Offer Margin: ${NumberFormat('#,##0.00').format(offer.margin is double ? offer.margin : offer.margin.toDouble())}',
  style: GoogleFonts.montserrat(
    fontSize: 12,
  ),
),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        );
      }
    },
  ),
),

                ],
              ),
            );
          }
        },
      ),
    );
  }

  Widget _buildRateContainer(String platform, num rate) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        width: 170,
        height: 105,
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(width: 0.5)),
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

