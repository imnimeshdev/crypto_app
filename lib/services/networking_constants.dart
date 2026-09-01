class NetworkConstants {
  static const String baseUrl = "https://api.coingecko.com/api/v3";
  static const String getCoins =
      "/coins/markets?vs_currency=usd&order=market_cap_desc&per_page=50&page=1&sparkline=true&price_change_percentage=1h,24h,7d";


  static String getMarketChart(String coinId, int days) =>
      "/coins/$coinId/market_chart?vs_currency=usd&days=$days";
}