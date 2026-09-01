import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';

import '../viewmodel/coin_view_model.dart';

class AppProviders {
  static List<SingleChildWidget> get providers => [
    ChangeNotifierProvider(create: (_) => CoinViewModel()),

  ];
}
