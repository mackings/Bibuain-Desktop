import 'package:bdesktop/Configuration/Api/configClass.dart';
import 'package:bdesktop/Configuration/Model/model.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';



class Configdashboard extends StatefulWidget {
  const Configdashboard({super.key});

  @override
  State<Configdashboard> createState() => _ConfigdashboardState();
}

class _ConfigdashboardState extends State<Configdashboard> {
  late Future<List<AccountOffers>> futureOffers;

  @override
  void initState() {
    super.initState();
    futureOffers = OfferService().fetchOffers();  // Fetch offers on init
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
      ),
      body: FutureBuilder<List<AccountOffers>>(
        future: futureOffers,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No offers found'));
          } else {
            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                var account = snapshot.data![index];
                return Padding(
                  padding: EdgeInsets.only(left: 40,right: 40),
                  child: Container(
                    width: 60,
                    decoration: BoxDecoration(
                      border: Border.all(width: 0.5,color: Colors.grey)
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
                                'Offer Margin: ${offer.margin}',
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
            );
          }
        },
      ),
    );
  }
}

