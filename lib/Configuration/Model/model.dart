// Model for individual offers
class Offer {
  final String offerHash;
  final String offerType;
  final double fiatPricePerBtc;
  final double fiatUsdPricePerBtc;
  final double margin;
  final bool active;
  final int fiatAmountRangeMin;
  final int fiatAmountRangeMax;
  final String paymentMethodName;
  final String offerLink;
  final String offerOwnerUsername;

  Offer({
    required this.offerHash,
    required this.offerType,
    required this.fiatPricePerBtc,
    required this.fiatUsdPricePerBtc,
    required this.margin,
    required this.active,
    required this.fiatAmountRangeMin,
    required this.fiatAmountRangeMax,
    required this.paymentMethodName,
    required this.offerLink,
    required this.offerOwnerUsername,
  });

  // Helper function to handle both int and double types
  static double _toDouble(dynamic value) {
    if (value is int) {
      return value.toDouble(); // Convert int to double if necessary
    } else if (value is double) {
      return value;
    } else {
      throw Exception('Invalid type for a double: ${value.runtimeType}');
    }
  }

  factory Offer.fromJson(Map<String, dynamic> json) {
    return Offer(
      offerHash: json['offer_hash'],
      offerType: json['offer_type'],
      fiatPricePerBtc: _toDouble(json['fiat_price_per_btc']),
      fiatUsdPricePerBtc: _toDouble(json['fiat_USD_price_per_btc']),
      margin: _toDouble(json['margin']),
      active: json['active'],
      fiatAmountRangeMin: json['fiat_amount_range_min'],
      fiatAmountRangeMax: json['fiat_amount_range_max'],
      paymentMethodName: json['payment_method_name'],
      offerLink: json['offer_link'],
      offerOwnerUsername: json['offer_owner_username'],
    );
  }
}

// Model for account offers
class AccountOffers {
  final String username;
  final List<Offer> offers;

  AccountOffers({
    required this.username,
    required this.offers,
  });

  factory AccountOffers.fromJson(Map<String, dynamic> json) {
    var offersJson = json['offers']['data']['offers'] as List;
    List<Offer> offersList = offersJson.map((i) => Offer.fromJson(i)).toList();

    return AccountOffers(
      username: json['username'],
      offers: offersList,
    );
  }
}
