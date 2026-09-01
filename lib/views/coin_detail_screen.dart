import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodel/coin_view_model.dart';
import '../widgets/coin_bar_chart.dart';


class CoinDetailScreen extends StatefulWidget {
  static const String routeName = '/coin-detail';
  final String coinId;

  const CoinDetailScreen({super.key, required this.coinId});

  @override
  State<CoinDetailScreen> createState() => _CoinDetailScreenState();
}

class _CoinDetailScreenState extends State<CoinDetailScreen> {
  // Map labels to CoinGecko days parameter
  final Map<String, int> _timeframes = {
    '1 day': 1,
    '1 week': 7,
    '1 month': 30,
    '1 Year': 365,
    'All': 3650,
  };

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CoinViewModel>().fetchChartData(widget.coinId, 1);
    });
  }

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
    final coin = viewModel.coins.firstWhere(
          (c) => c.id == widget.coinId,
      orElse: () => viewModel.coins.first,
    );

    final isPositive = coin.priceChangePercentage24h >= 0;
    final isWatchlisted = viewModel.isWatchlisted(coin.id);

    return Scaffold(
      backgroundColor: const Color(0xFF0B0E11), // CoinGlass dark background
      appBar: AppBar(
        backgroundColor: const Color(0xFF0B0E11),
        elevation: 0,
        title: Row(
          children: [
            Image.network(
              coin.image,
              height: 24,
              width: 24,
              errorBuilder: (_, __, ___) => const Icon(Icons.currency_bitcoin, color: Colors.amber),
            ),
            const SizedBox(width: 8),
            Text(
              '${coin.name} (${coin.symbol})',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.white),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(
              isWatchlisted ? Icons.star : Icons.star_border,
              color: isWatchlisted ? const Color(0xFFF0B90B) : const Color(0xFF848E9C),
            ),
            onPressed: () => viewModel.toggleWatchlist(coin.id),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Price & Quick Metrics Bar
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF181A20),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFF2B2F36)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '\$${coin.currentPrice >= 1 ? coin.currentPrice.toStringAsFixed(2) : coin.currentPrice.toStringAsFixed(4)}',
                        style: const TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: isPositive
                                  ? const Color(0xFF0ECB81).withOpacity(0.2)
                                  : const Color(0xFFF6465D).withOpacity(0.2),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              '${isPositive ? "+" : ""}${coin.priceChangePercentage24h.toStringAsFixed(2)}%',
                              style: TextStyle(
                                color: isPositive ? const Color(0xFF0ECB81) : const Color(0xFFF6465D),
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Text('24h Change', style: TextStyle(color: Color(0xFF848E9C), fontSize: 12)),
                        ],
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      const Text('Funding Rate', style: TextStyle(color: Color(0xFF848E9C), fontSize: 11)),
                      const SizedBox(height: 2),
                      Text(
                        '${(coin.fundingRate * 100).toStringAsFixed(4)}%',
                        style: TextStyle(
                          color: coin.fundingRate >= 0 ? const Color(0xFF0ECB81) : const Color(0xFFF6465D),
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // Chart Section with CoinGlass Timeframe Bar
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF181A20),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFF2B2F36)),
              ),
              child: Column(
                children: [
                  // CoinGlass Timeframe Selector Bar
                  Align(
                    alignment: Alignment.centerRight,
                    child: Container(
                      padding: const EdgeInsets.all(3),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1E232A),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: const Color(0xFF2B2F36)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: _timeframes.entries.map((entry) {
                          final label = entry.key;
                          final days = entry.value;
                          final isSelected = viewModel.selectedDays == days;

                          return GestureDetector(
                            onTap: () => viewModel.fetchChartData(widget.coinId, days),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 150),
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: isSelected ? const Color(0xFF0B0E11) : Colors.transparent,
                                borderRadius: BorderRadius.circular(6),
                                border: isSelected
                                    ? Border.all(color: const Color(0xFF2B2F36))
                                    : null,
                              ),
                              child: Text(
                                label,
                                style: TextStyle(
                                  color: isSelected ? Colors.white : const Color(0xFF848E9C),
                                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Chart View
                  viewModel.isChartLoading
                      ? const SizedBox(
                    height: 240,
                    child: Center(child: CircularProgressIndicator(color: Color(0xFFF0B90B))),
                  )
                      : CoinPriceChart(
                    prices: viewModel.chartPrices.isNotEmpty
                        ? viewModel.chartPrices
                        : coin.sparklinePrices,
                    isPositive: isPositive,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // CoinGlass Terminal Metrics Table
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF181A20),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFF2B2F36)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Market Financial Metrics',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15),
                  ),
                  const SizedBox(height: 12),
                  const Divider(color: Color(0xFF2B2F36), height: 1),
                  const SizedBox(height: 8),

                  _buildCoinGlassStatRow(
                    'Funding Rate',
                    '${(coin.fundingRate * 100).toStringAsFixed(4)}%',
                    valueColor: coin.fundingRate >= 0 ? const Color(0xFF0ECB81) : const Color(0xFFF6465D),
                  ),
                  _buildCoinGlassStatRow(
                    'Volume (24h)',
                    _formatNumber(coin.totalVolume),
                    subValue: '${coin.volumeChange24h >= 0 ? "+" : ""}${coin.volumeChange24h.toStringAsFixed(2)}%',
                    subValueColor: coin.volumeChange24h >= 0 ? const Color(0xFF0ECB81) : const Color(0xFFF6465D),
                  ),
                  _buildCoinGlassStatRow('Market Cap', _formatNumber(coin.marketCap)),
                  _buildCoinGlassStatRow('Open Interest (OI)', _formatNumber(coin.openInterest)),
                  _buildCoinGlassStatRow(
                    'OI (1h%)',
                    '${coin.oiChange1h >= 0 ? "+" : ""}${coin.oiChange1h.toStringAsFixed(2)}%',
                    valueColor: coin.oiChange1h >= 0 ? const Color(0xFF0ECB81) : const Color(0xFFF6465D),
                  ),
                  _buildCoinGlassStatRow(
                    'OI (24h%)',
                    '${coin.oiChange24h >= 0 ? "+" : ""}${coin.oiChange24h.toStringAsFixed(2)}%',
                    valueColor: coin.oiChange24h >= 0 ? const Color(0xFF0ECB81) : const Color(0xFFF6465D),
                  ),
                  _buildCoinGlassStatRow('Liquidation (24h)', _formatNumber(coin.liquidation24h)),
                  _buildCoinGlassStatRow(
                    'Circulating Supply',
                    '${(coin.circulatingSupply / 1e6).toStringAsFixed(2)}M ${coin.symbol}',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCoinGlassStatRow(
      String label,
      String value, {
        Color valueColor = Colors.white,
        String? subValue,
        Color? subValueColor,
      }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(color: Color(0xFF848E9C), fontSize: 13, fontWeight: FontWeight.w500),
          ),
          Row(
            children: [
              Text(
                value,
                style: TextStyle(color: valueColor, fontWeight: FontWeight.bold, fontSize: 13),
              ),
              if (subValue != null) ...[
                const SizedBox(width: 6),
                Text(
                  subValue,
                  style: TextStyle(
                    color: subValueColor ?? const Color(0xFF848E9C),
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}