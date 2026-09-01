import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../model/coin_model.dart';
import '../utils/colors.dart';
import '../viewmodel/coin_view_model.dart';

class MarketStatsScreen extends StatelessWidget {
  static const String routeName = '/market-stats';
  const MarketStatsScreen({super.key});

  String _formatNumber(double number) {
    if (number >= 1e12) return '\$${(number / 1e12).toStringAsFixed(2)}T';
    if (number >= 1e9) return '\$${(number / 1e9).toStringAsFixed(2)}B';
    if (number >= 1e6) return '\$${(number / 1e6).toStringAsFixed(2)}M';
    if (number >= 1e3) return '\$${(number / 1e3).toStringAsFixed(2)}K';
    return '\$${number.toStringAsFixed(2)}';
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<CoinViewModel>();
    final coins = viewModel.coins;

    if (coins.isEmpty) {
      return Scaffold(
        backgroundColor: AppColors.darkBackground,
        appBar: AppBar(
          backgroundColor: AppColors.darkBackground,
          elevation: 0,
          title: const Text('Market Statistics', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.textWhite)),
        ),
        body: const Center(
          child: Text('No market data available', style: TextStyle(color: AppColors.textGrey)),
        ),
      );
    }

    // Calculated Financial Metrics
    final double totalMarketCap = coins.fold(0, (sum, coin) => sum + coin.marketCap);
    final double totalVolume = coins.fold(0, (sum, coin) => sum + coin.totalVolume);
    final double totalOpenInterest = coins.fold(0, (sum, coin) => sum + coin.openInterest);
    final double totalLiquidations = coins.fold(0, (sum, coin) => sum + coin.liquidation24h);

    // Bitcoin Dominance (BTC.D)
    final btcCoin = coins.firstWhere(
          (c) => c.symbol.toLowerCase() == 'btc',
      orElse: () => coins.first,
    );
    final double btcDominance = totalMarketCap > 0 ? (btcCoin.marketCap / totalMarketCap) * 100 : 0.0;

    // Market Sentiment (Gainers vs Losers count)
    final int gainersCount = coins.where((c) => c.priceChangePercentage24h >= 0).length;
    final int losersCount = coins.length - gainersCount;
    final double bullishPercentage = coins.isNotEmpty ? (gainersCount / coins.length) * 100 : 0.0;

    // Top Gainer & Top Loser
    final sortedByChange = List<Coin>.from(coins)
      ..sort((a, b) => b.priceChangePercentage24h.compareTo(a.priceChangePercentage24h));
    final topGainer = sortedByChange.first;
    final topLoser = sortedByChange.last;

    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      appBar: AppBar(
        backgroundColor: AppColors.darkBackground,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.textWhite),
        title: const Text('Market Statistics', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.textWhite)),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          // 1. Market Sentiment Progress Bar Card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.cardBackground,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.borderColor),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Market Sentiment (24h)', style: TextStyle(color: AppColors.textGrey, fontSize: 13, fontWeight: FontWeight.bold)),
                    Text(
                      '${bullishPercentage.toStringAsFixed(0)}% Bullish',
                      style: TextStyle(
                        color: bullishPercentage >= 50 ? AppColors.green : AppColors.red,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: bullishPercentage / 100,
                    minHeight: 8,
                    backgroundColor: AppColors.red,
                    color: AppColors.green,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('$gainersCount Advanced', style: const TextStyle(color: AppColors.green, fontSize: 12, fontWeight: FontWeight.bold)),
                    Text('$losersCount Declined', style: const TextStyle(color: AppColors.red, fontSize: 12, fontWeight: FontWeight.bold)),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // 2. Global Capitalization Grid
          Row(
            children: [
              Expanded(
                child: _buildMetricTile(
                  title: 'Total Market Cap',
                  value: _formatNumber(totalMarketCap),
                  icon: Icons.pie_chart_outline,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildMetricTile(
                  title: '24h Total Volume',
                  value: _formatNumber(totalVolume),
                  icon: Icons.bar_chart_outlined,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // 3. Bitcoin Dominance & Tracked Assets
          Row(
            children: [
              Expanded(
                child: _buildMetricTile(
                  title: 'BTC Dominance',
                  value: '${btcDominance.toStringAsFixed(2)}%',
                  icon: Icons.currency_bitcoin,
                  valueColor: AppColors.primaryColor,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildMetricTile(
                  title: 'Tracked Coins',
                  value: '${coins.length}',
                  icon: Icons.list_alt,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // 4. CoinGlass Derivatives Aggregates
          Row(
            children: [
              Expanded(
                child: _buildMetricTile(
                  title: 'Total Open Interest',
                  value: _formatNumber(totalOpenInterest),
                  icon: Icons.show_chart,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildMetricTile(
                  title: '24h Liquidations',
                  value: _formatNumber(totalLiquidations),
                  icon: Icons.local_fire_department_outlined,
                  valueColor: AppColors.red,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // 5. Top Performer Cards (Gainer / Loser)
          _buildPerformerCard('Top 24h Gainer', topGainer, isGainer: true),
          const SizedBox(height: 12),
          _buildPerformerCard('Top 24h Loser', topLoser, isGainer: false),
        ],
      ),
    );
  }

  Widget _buildMetricTile({
    required String title,
    required String value,
    required IconData icon,
    Color valueColor = AppColors.textWhite,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: AppColors.primaryColor),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(color: AppColors.textGrey, fontSize: 11, fontWeight: FontWeight.w500),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: valueColor),
          ),
        ],
      ),
    );
  }

  Widget _buildPerformerCard(String label, Coin coin, {required bool isGainer}) {
    final color = isGainer ? AppColors.green : AppColors.red;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.borderColor),
      ),
      child: Row(
        children: [
          Image.network(
            coin.image,
            height: 32,
            width: 32,
            errorBuilder: (_, __, ___) => Icon(Icons.monetization_on, color: color),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(color: AppColors.textGrey, fontSize: 11)),
                const SizedBox(height: 2),
                Text(
                  '${coin.name} (${coin.symbol})',
                  style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.textWhite, fontSize: 14),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '\$${coin.currentPrice.toStringAsFixed(2)}',
                style: const TextStyle(color: AppColors.textWhite, fontWeight: FontWeight.bold, fontSize: 13),
              ),
              const SizedBox(height: 2),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  '${isGainer ? "+" : ""}${coin.priceChangePercentage24h.toStringAsFixed(2)}%',
                  style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 11),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}