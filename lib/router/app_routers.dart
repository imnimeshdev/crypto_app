import 'package:go_router/go_router.dart';
import '../views/coin_list_screen.dart';
import '../views/coin_detail_screen.dart';
import '../views/market_stats_screen.dart';
import '../views/watchlist_screen.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: CoinListScreen.routeName,
  routes: [
    GoRoute(
      path: CoinListScreen.routeName,
      builder: (context, state) => const CoinListScreen(),
    ),
    GoRoute(
      path: CoinDetailScreen.routeName,
      builder: (context, state) {
        final coinId = state.extra as String;
        return CoinDetailScreen(coinId: coinId);
      },
    ),
    GoRoute(
      path: MarketStatsScreen.routeName,
      builder: (context, state) => const MarketStatsScreen(),
    ),
    GoRoute(
      path: WatchlistScreen.routeName,
      builder: (context, state) => const WatchlistScreen(),
    ),
  ],
);