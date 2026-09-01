import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../utils/colors.dart';
import '../viewmodel/coin_view_model.dart';
import 'coin_detail_screen.dart';

class WatchlistScreen extends StatelessWidget {
  static const String routeName = '/watchlist';
  const WatchlistScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<CoinViewModel>();
    final watchlistCoins = viewModel.watchlistCoins;

    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      appBar: AppBar(
        backgroundColor: AppColors.darkBackground,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.textWhite),
        title: const Text('Watchlist', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.textWhite)),
      ),
      body: watchlistCoins.isEmpty
          ? const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.star_border, size: 64, color: AppColors.textGrey),
            SizedBox(height: 12),
            Text('Your watchlist is empty.', style: TextStyle(color: AppColors.textGrey, fontSize: 16)),
          ],
        ),
      )
          : ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemCount: watchlistCoins.length,
        itemBuilder: (context, index) {
          final coin = watchlistCoins[index];
          final isPositive = coin.priceChangePercentage24h >= 0;

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
                    icon: const Icon(Icons.star, color: AppColors.primaryColor, size: 20),
                    onPressed: () => viewModel.toggleWatchlist(coin.id),
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
  }
}