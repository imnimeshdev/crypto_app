//network_utils.dart
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class NetworkUtils {
  static Future<bool> checkInternetAndShowToast() async {
    final results = await Connectivity().checkConnectivity();
    final isConnected = results.any((result) => result != ConnectivityResult.none);

    if (!isConnected) {
      Fluttertoast.showToast(
        msg: "No internet connection pls check your connection",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0,
      );
    }

    return isConnected;
  }
}
