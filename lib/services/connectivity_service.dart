
import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ConnectivityService {
  final Connectivity _connectivity = Connectivity();

  Future<List<ConnectivityResult>> _getConnectivity() async {
    return await _connectivity.checkConnectivity();
  }

  Future<bool> hasInternetConnection() async {
    try {
      final result = await _getConnectivity();
      return !result.contains(ConnectivityResult.none);
    } catch (e) {
      return true;
    }
  }

  Stream<List<ConnectivityResult>> get connectivityStream =>
      _connectivity.onConnectivityChanged;

  Future<List<ConnectivityResult>> getCurrentConnectivity() async {
    return await _getConnectivity();
  }

  Future<bool> isWifiConnection() async {
    final result = await _getConnectivity();

    return result.contains(ConnectivityResult.wifi);
  }

  Future<bool> isMobileConnection() async {
    final result = await _getConnectivity();
    return result.contains(ConnectivityResult.mobile);
  }

}

final connectivityServiceProvider = Provider<ConnectivityService>((ref) {
  return ConnectivityService();
});

final connectivityStatusProvider = StreamProvider<List<ConnectivityResult>>((ref) {
  final connectivityService = ref.watch(connectivityServiceProvider);
  return connectivityService.connectivityStream;
});

final hasInternetProvider = FutureProvider<bool>((ref) async {
  final connectivityService = ref.watch(connectivityServiceProvider);
  return await connectivityService.hasInternetConnection();
});

