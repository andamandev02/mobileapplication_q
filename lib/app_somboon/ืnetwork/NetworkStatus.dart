import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';

class NetworkStatus extends ChangeNotifier {
  ConnectivityResult _connectionStatus = ConnectivityResult.none;

  NetworkStatus() {
    Connectivity()
        .onConnectivityChanged
        .listen((List<ConnectivityResult> results) {
      if (results.isNotEmpty) {
        _connectionStatus = results.first;
        notifyListeners();
      }
    });
  }

  ConnectivityResult get connectionStatus => _connectionStatus;

  bool get isConnected => _connectionStatus != ConnectivityResult.none;
}
