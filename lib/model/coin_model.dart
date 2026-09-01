class Coin {
  final String id;
  final String name;
  final String symbol;
  final String image;
  final double currentPrice;
  final double marketCap;
  final double totalVolume;
  final double circulatingSupply;
  final double priceChangePercentage24h;

  // CoinGlass Financial Metrics
  final double fundingRate;
  final double volumeChange24h;
  final double openInterest;
  final double oiChange1h;
  final double oiChange24h;
  final double liquidation24h;
  final List<double> sparklinePrices;

  Coin({
    required this.id,
    required this.name,
    required this.symbol,
    required this.image,
    required this.currentPrice,
    required this.marketCap,
    required this.totalVolume,
    required this.circulatingSupply,
    required this.priceChangePercentage24h,
    required this.fundingRate,
    required this.volumeChange24h,
    required this.openInterest,
    required this.oiChange1h,
    required this.oiChange24h,
    required this.liquidation24h,
    required this.sparklinePrices,
  });

  factory Coin.fromJson(Map<String, dynamic> json) {
    List<double> sparkline = [];
    if (json['sparkline_in_7d'] != null && json['sparkline_in_7d']['price'] != null) {
      final List<dynamic> priceList = json['sparkline_in_7d']['price'];
      sparkline = priceList.map((e) => (e as num).toDouble()).toList();
    }

    return Coin(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      symbol: (json['symbol'] ?? '').toUpperCase(),
      image: json['image'] ?? '',
      currentPrice: (json['current_price'] as num?)?.toDouble() ?? 0.0,
      marketCap: (json['market_cap'] as num?)?.toDouble() ?? 0.0,
      totalVolume: (json['total_volume'] as num?)?.toDouble() ?? 0.0,
      circulatingSupply: (json['circulating_supply'] as num?)?.toDouble() ?? 0.0,
      priceChangePercentage24h:
      (json['price_change_percentage_24h'] as num?)?.toDouble() ?? 0.0,
      fundingRate: (json['funding_rate'] as num?)?.toDouble() ?? 0.0090,
      volumeChange24h: (json['volume_change_24h'] as num?)?.toDouble() ?? 0.0,
      openInterest: (json['open_interest'] as num?)?.toDouble() ?? 0.0,
      oiChange1h: (json['oi_change_1h'] as num?)?.toDouble() ?? 0.0,
      oiChange24h: (json['oi_change_24h'] as num?)?.toDouble() ?? 0.0,
      liquidation24h: (json['liquidation_24h'] as num?)?.toDouble() ?? 0.0,
      sparklinePrices: sparkline,
    );
  }
}