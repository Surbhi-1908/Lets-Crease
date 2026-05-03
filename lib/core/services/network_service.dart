import 'package:connectivity_plus/connectivity_plus.dart';
import 'dart:developer' as developer;

class NetworkService {
  static final NetworkService _instance = NetworkService._internal();
  factory NetworkService() => _instance;
  NetworkService._internal();

  final Connectivity _connectivity = Connectivity();

  /// Check if device has internet connection
  Future<bool> hasConnection() async {
    try {
      final connectivityResult = await _connectivity.checkConnectivity();
      return connectivityResult.any((result) => 
        result == ConnectivityResult.mobile ||
        result == ConnectivityResult.wifi ||
        result == ConnectivityResult.ethernet ||
        result == ConnectivityResult.vpn
      );
    } catch (e) {
      developer.log('Network check failed: $e', name: 'NetworkService');
      return false;
    }
  }

  /// Stream of connectivity changes
  Stream<List<ConnectivityResult>> get connectivityStream =>
      _connectivity.onConnectivityChanged;

  /// Get current connectivity status
  Future<List<ConnectivityResult>> getCurrentConnectivity() async {
    try {
      return await _connectivity.checkConnectivity();
    } catch (e) {
      developer.log('Failed to get connectivity: $e', name: 'NetworkService');
      return [ConnectivityResult.none];
    }
  }

  /// Check if connected to WiFi
  Future<bool> isConnectedToWiFi() async {
    try {
      final result = await getCurrentConnectivity();
      return result.contains(ConnectivityResult.wifi);
    } catch (e) {
      developer.log('WiFi check failed: $e', name: 'NetworkService');
      return false;
    }
  }

  /// Check if connected to mobile data
  Future<bool> isConnectedToMobile() async {
    try {
      final result = await getCurrentConnectivity();
      return result.contains(ConnectivityResult.mobile);
    } catch (e) {
      developer.log('Mobile check failed: $e', name: 'NetworkService');
      return false;
    }
  }

  /// Check if connected to ethernet
  Future<bool> isConnectedToEthernet() async {
    try {
      final result = await getCurrentConnectivity();
      return result.contains(ConnectivityResult.ethernet);
    } catch (e) {
      developer.log('Ethernet check failed: $e', name: 'NetworkService');
      return false;
    }
  }

  /// Check if device has no connection
  Future<bool> hasNoConnection() async {
    try {
      final result = await getCurrentConnectivity();
      return result.isEmpty || result.every((r) => r == ConnectivityResult.none);
    } catch (e) {
      developer.log('Connection check failed: $e', name: 'NetworkService');
      return true; // Assume no connection on error
    }
  }
}
