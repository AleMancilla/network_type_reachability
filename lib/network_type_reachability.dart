import 'dart:async';

import 'package:flutter/services.dart';

enum NetworkStatus {
  unreachable,
  wifi,
  mobile2G,
  moblie3G,
  moblie4G,
  moblie5G,
  otherMoblie
}

class NetworkTypeReachability {
  static NetworkTypeReachability _instance;
  factory NetworkTypeReachability() {
    _instance ??= NetworkTypeReachability._();
    return _instance;
  }
  NetworkTypeReachability._();

  static const MethodChannel _channel =
  MethodChannel('flutter_plugin_reachability');

  static const EventChannel _eventChannel =
  EventChannel("flutter_plugin_reachability_status");

  Stream<NetworkStatus> _onNetworkStateChanged;

  Stream<NetworkStatus> get onNetworkStateChanged {
    _onNetworkStateChanged ??= _eventChannel
        .receiveBroadcastStream()
        .map((event) => event.toString())
        .map(_convertFromState);
    return _onNetworkStateChanged;
  }

  Future<NetworkStatus> currentNetworkStatus() async {
    final String state = await _channel.invokeMethod("networkStatus");
    return _convertFromState(state);
  }

  NetworkStatus _convertFromState(String state) {
    switch (state) {
      case "0":
        return NetworkStatus.unreachable;
      case "1":
        return NetworkStatus.mobile2G;
      case "2":
        return NetworkStatus.moblie3G;
      case "3":
        return NetworkStatus.wifi;
      case "4":
        return NetworkStatus.moblie4G;
      case "5":
        return NetworkStatus.moblie5G;
      case "6":
        return NetworkStatus.otherMoblie;
      default:
        return NetworkStatus.unreachable;
    }
  }

}
