import 'package:crypto_app/views/market_stats_screen.dart';
import 'package:crypto_app/views/watchlist_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../utils/colors.dart';
import '../viewmodel/coin_view_model.dart';
import 'coin_detail_screen.dart';

class CoinListScreen extends StatefulWidget {
  static const String routeName = '/';
  const CoinListScreen({super.key});

  @override
  State<CoinListScreen> createState() => _CoinListScreenState();
}

class _CoinListScreenState extends State<CoinListScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CoinViewModel>().fetchCoins();
    });
  }

  void _showSortBottomSheet(BuildContext context) {
    final viewModel = context.read<CoinViewModel>();
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.cardBackground,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        side: BorderSide(color: AppColors.borderColor),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "Sort By",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: AppColors.textWhite),
              ),
              const Divider(color: AppColors.borderColor, height: 24),
              _buildSortOption(context, "Market Cap (High to Low)", SortOption.marketCapDesc, viewModel),
              _buildSortOption(context, "Market Cap (Low to High)", SortOption.marketCapAsc, viewModel),
              _buildSortOption(context, "Price (High to Low)", SortOption.priceDesc, viewModel),
              _buildSortOption(context, "Price (Low to High)", SortOption.priceAsc, viewModel),
              _buildSortOption(context, "24h Change (High to Low)", SortOption.change24hDesc, viewModel),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSortOption(BuildContext context, String title, SortOption option, CoinViewModel vm) {
    final isSelected = vm.selectedSort == option;
    return ListTile(
      title: Text(
        title,
        style: TextStyle(
          color: isSelected ? AppColors.primaryColor : AppColors.textWhite,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      trailing: isSelected ? const Icon(Icons.check, color: AppColors.primaryColor) : null,
      onTap: () {
        vm.setSortOption(option);
        Navigator.pop(context);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<CoinViewModel>();

    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      appBar: AppBar(
        backgroundColor: AppColors.darkBackground,
        elevation: 0,
        title: const Text(
          'Crypto Market',
          style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.textWhite),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.sort, color: AppColors.textGrey),
            onPressed: () => _showSortBottomSheet(context),
          ),
          IconButton(
            icon: const Icon(Icons.show_chart, color: AppColors.textGrey),
            onPressed: () => context.push(MarketStatsScreen.routeName),
          ),
          IconButton(
            icon: const Icon(Icons.star, color: AppColors.primaryColor),
            onPressed: () => context.push(WatchlistScreen.routeName),
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Input Bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
            child: TextField(
              style: const TextStyle(color: AppColors.textWhite, fontSize: 14),
              onChanged: (value) => viewModel.setSearchQuery(value),
              decoration: InputDecoration(
                hintText: 'Search coin or symbol...',
                hintStyle: const TextStyle(color: AppColors.textGrey, fontSize: 14),
                prefixIcon: const Icon(Icons.search, color: AppColors.textGrey),
                filled: true,
                fillColor: AppColors.inputBackground,
                contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: AppColors.borderColor),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: AppColors.primaryColor),
                ),
              ),
            ),
          ),

          // List Header Bar
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Asset', style: TextStyle(color: AppColors.textGrey, fontSize: 12, fontWeight: FontWeight.bold)),
                Text('Price / 24h Change', style: TextStyle(color: AppColors.textGrey, fontSize: 12, fontWeight: FontWeight.bold)),
              ],
            ),
          ),

          // List View Body
          Expanded(
            child: Consumer<CoinViewModel>(
              builder: (context, vm, child) {
                if (vm.state == ViewState.loading) {
                  return const Center(child: CircularProgressIndicator(color: AppColors.primaryColor));
                }

                if (vm.state == ViewState.error) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(vm.errorMessage, style: const TextStyle(color: AppColors.red)),
                        const SizedBox(height: 12),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryColor),
                          onPressed: () => vm.fetchCoins(),
                          child: const Text('Retry', style: TextStyle(color: Colors.black)),
                        ),
                      ],
                    ),
                  );
                }

                final coins = vm.filteredCoins;

                if (coins.isEmpty) {
                  return const Center(
                    child: Text('No matching coins found.', style: TextStyle(color: AppColors.textGrey)),
                  );
                }

                return RefreshIndicator(
                  backgroundColor: AppColors.cardBackground,
                  color: AppColors.primaryColor,
                  onRefresh: () => vm.fetchCoins(),
                  child: ListView.builder(
                    itemCount: coins.length,
                    itemBuilder: (context, index) {
                      final coin = coins[index];
                      final isPositive = coin.priceChangePercentage24h >= 0;
                      final isWatchlisted = vm.isWatchlisted(coin.id);

                      return Container(
                        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.cardBackground,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: AppColors.borderColor),
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                          leading: Image.network(
                            coin.image,
                            height: 32,
                            width: 32,
                            errorBuilder: (_, __, ___) => const Icon(Icons.currency_bitcoin, color: AppColors.primaryColor),
                          ),
                          title: Row(
                            children: [
                              Text(
                                coin.symbol,
                                style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.textWhite, fontSize: 15),
                              ),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  coin.name,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(color: AppColors.textGrey, fontSize: 12),
                                ),
                              ),
                            ],
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    '\$${coin.currentPrice >= 1 ? coin.currentPrice.toStringAsFixed(2) : coin.currentPrice.toStringAsFixed(4)}',
                                    style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.textWhite, fontSize: 14),
                                  ),
                                  const SizedBox(height: 2),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: isPositive
                                          ? AppColors.green.withOpacity(0.15)
                                          : AppColors.red.withOpacity(0.15),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      '${isPositive ? "+" : ""}${coin.priceChangePercentage24h.toStringAsFixed(2)}%',
                                      style: TextStyle(
                                        color: isPositive ? AppColors.green : AppColors.red,
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              IconButton(
                                icon: Icon(
                                  isWatchlisted ? Icons.star : Icons.star_border,
                                  color: isWatchlisted ? AppColors.primaryColor : AppColors.textGrey,
                                  size: 20,
                                ),
                                onPressed: () => vm.toggleWatchlist(coin.id),
                              ),
                            ],
                          ),
                          onTap: () => context.push(
                            CoinDetailScreen.routeName,
                            extra: coin.id,
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}