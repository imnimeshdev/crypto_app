import 'package:flutter/material.dart';
import '../model/coin_model.dart';
import '../services/crypto_repository.dart';

enum ViewState { initial, loading, loaded, error }
enum SortOption { marketCapDesc, marketCapAsc, priceDesc, priceAsc, change24hDesc, change24hAsc }

class CoinViewModel extends ChangeNotifier {
  final CryptoRepository _repository = CryptoRepository();

  List<Coin> _coins = [];
  ViewState _state = ViewState.initial;
  String _errorMessage = '';

  // Search & Filter & Sort state
  String _searchQuery = '';
  SortOption _selectedSort = SortOption.marketCapDesc;

  // Watchlist state (Store IDs)
  final Set<String> _watchlistIds = {};

  // Interactive Chart state
  List<double> _chartPrices = [];
  int _selectedDays = 1; // Default: 1 day
  bool _isChartLoading = false;

  List<Coin> get coins => _coins;
  ViewState get state => _state;
  String get errorMessage => _errorMessage;
  String get searchQuery => _searchQuery;
  SortOption get selectedSort => _selectedSort;

  // Chart Getters
  List<double> get chartPrices => _chartPrices;
  int get selectedDays => _selectedDays;
  bool get isChartLoading => _isChartLoading;

  // Watchlist Getters
  List<Coin> get watchlistCoins =>
      _coins.where((coin) => _watchlistIds.contains(coin.id)).toList();

  bool isWatchlisted(String coinId) => _watchlistIds.contains(coinId);

  // Toggle Watchlist
  void toggleWatchlist(String coinId) {
    if (_watchlistIds.contains(coinId)) {
      _watchlistIds.remove(coinId);
    } else {
      _watchlistIds.add(coinId);
    }
    notifyListeners();
  }

  // Set Search Query
  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  // Set Sort Option
  void setSortOption(SortOption sort) {
    _selectedSort = sort;
    notifyListeners();
  }

  // Filtered and Sorted Coins List
  List<Coin> get filteredCoins {
    List<Coin> list = _coins.where((coin) {
      final query = _searchQuery.toLowerCase();
      return coin.name.toLowerCase().contains(query) ||
          coin.symbol.toLowerCase().contains(query);
    }).toList();

    switch (_selectedSort) {
      case SortOption.marketCapDesc:
        list.sort((a, b) => b.marketCap.compareTo(a.marketCap));
        break;
      case SortOption.marketCapAsc:
        list.sort((a, b) => a.marketCap.compareTo(b.marketCap));
        break;
      case SortOption.priceDesc:
        list.sort((a, b) => b.currentPrice.compareTo(a.currentPrice));
        break;
      case SortOption.priceAsc:
        list.sort((a, b) => a.currentPrice.compareTo(b.currentPrice));
        break;
      case SortOption.change24hDesc:
        list.sort((a, b) => b.priceChangePercentage24h.compareTo(a.priceChangePercentage24h));
        break;
      case SortOption.change24hAsc:
        list.sort((a, b) => a.priceChangePercentage24h.compareTo(b.priceChangePercentage24h));
        break;
    }

    return list;
  }

  Future<void> fetchCoins() async {
    _state = ViewState.loading;
    notifyListeners();

    try {
      final result = await _repository.fetchCoins();
      if (result.isNotEmpty) {
        _coins = result;
        _state = ViewState.loaded;
      } else {
        _errorMessage = "Failed to fetch crypto data";
        _state = ViewState.error;
      }
    } catch (e) {
      _errorMessage = e.toString();
      _state = ViewState.error;
    }
    notifyListeners();
  }

  /// Fetch historical price array dynamically when switching timeframe options (1 day, 1 week, etc.)
  Future<void> fetchChartData(String coinId, int days) async {
    _selectedDays = days;
    _isChartLoading = true;
    notifyListeners();

    _chartPrices = await _repository.fetchCoinMarketChart(coinId, days);
    _isChartLoading = false;
    notifyListeners();
  }
}