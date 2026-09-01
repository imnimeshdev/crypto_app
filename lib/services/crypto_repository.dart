import '../model/coin_model.dart';
import 'api_service.dart';
import 'networking_constants.dart';

class CryptoRepository {
  final ApiService _apiService = ApiService();

  /// Fetch top cryptocurrencies market data
  Future<List<Coin>> fetchCoins() async {
    try {
      final response = await _apiService.get(NetworkConstants.getCoins);

      if (response["statusCode"] == 200) {
        final List<dynamic> coinsData = response["body"];
        return coinsData.map((json) => Coin.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  /// Fetch historical price data for timeframe graph switching
  Future<List<double>> fetchCoinMarketChart(String coinId, int days) async {
    try {
      final response = await _apiService
          .get(NetworkConstants.getMarketChart(coinId, days));

      if (response["statusCode"] == 200) {
        final List<dynamic> pricesList = response["body"]["prices"];
        return pricesList.map((item) => (item[1] as num).toDouble()).toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }
}