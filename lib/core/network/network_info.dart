/// Abstraction for checking network connectivity.
abstract class NetworkInfo {
  Future<bool> get isConnected;
}

/// Simple implementation for network info.
class NetworkInfoImpl implements NetworkInfo {
  @override
  Future<bool> get isConnected async {
    // In production, can use internet_connection_checker or connectivity_plus
    return true;
  }
}
