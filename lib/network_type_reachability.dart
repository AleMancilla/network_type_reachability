import 'dart:async';
import 'dart:developer';

import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';

import 'package:dart_ping/dart_ping.dart';
import 'package:dart_ping_ios/dart_ping_ios.dart';

enum NetworkStatus {
  unreachable,
  wifi,
  mobile2G,
  moblie3G,
  moblie4G,
  moblie5G,
  otherMoblie
}

enum InternetStatusConnection {
  withoutInternet,
  withInternet,
  unstableInternet,
}

class NetworkTypeReachability {
  // make this nullable by adding '?'
  static NetworkTypeReachability? _instance;

  factory NetworkTypeReachability() {
    DartPingIOS.register();
    _instance ??= NetworkTypeReachability._();
    return _instance!;
  }
  NetworkTypeReachability._();

  static const MethodChannel _channel =
      MethodChannel('flutter_plugin_reachability');

  static const EventChannel _eventChannel =
      EventChannel("flutter_plugin_reachability_status");

  Stream<NetworkStatus>? _onNetworkStateChanged;

  /// currentNetworkStatus obtain the status network in live
  Stream<NetworkStatus> get onNetworkStateChanged {
    _onNetworkStateChanged ??= _eventChannel
        .receiveBroadcastStream()
        .map((event) => event.toString())
        .map(_convertFromState);
    return _onNetworkStateChanged!;
  }

  /// currentNetworkStatus obtain the status network
  Future<NetworkStatus> currentNetworkStatus() async {
    final String state = await _channel.invokeMethod("networkStatus");
    return _convertFromState(state);
  }

  /// NetworkStatus identify tipe of connection
  NetworkStatus _convertFromState(String state) {
    switch (state) {
      case "unreach":
        return NetworkStatus.unreachable;
      case "mobile2G":
        return NetworkStatus.mobile2G;
      case "moblie3G":
        return NetworkStatus.moblie3G;
      case "wifi":
        return NetworkStatus.wifi;
      case "moblie4G":
        return NetworkStatus.moblie4G;
      case "moblie5G":
        return NetworkStatus.moblie5G;
      case "moblieOther":
        return NetworkStatus.otherMoblie;
      default:
        return NetworkStatus.unreachable;
    }
  }

  /// required to distinguish mobile internet from 2g,3g,4g,5g
  Future<PermissionStatus> get getPermisionsAndroid async =>
      await Permission.phone.request();

  /// performs a sending and receiving of packets to an internet page,
  /// if the number of packets sent is equal to the number of packets received
  /// then if there is a good internet connection
  Future<InternetStatusConnection> getInternetStatusConnection({
    urlTest = 'google.com',
    countPing = 3,
    timeOutIntents = 5,
    showLogs = false,
  }) async {
    Ping ping = Ping(urlTest, count: countPing);
    PingData pingData = await ping.stream.last
        .timeout(
      Duration(seconds: timeOutIntents),
    )
        .catchError((e) {
      return null;
    }).onError((error, stackTrace) {
      return throw error!;
    });
    if (showLogs) {
      log('Running PING ===== > $pingData');
    }
    try {
      if (pingData.summary?.transmitted == pingData.summary?.received) {
        return InternetStatusConnection.withInternet;
      } else if (pingData.summary!.transmitted > 0 &&
          pingData.summary!.received > 0) {
        return InternetStatusConnection.unstableInternet;
      } else {
        return InternetStatusConnection.withoutInternet;
      }
    } catch (e) {
      return InternetStatusConnection.withoutInternet;
    }
  }

  /// from here on the code focuses on maintaining a listening state wondering if there is an internet connection or not
  bool listenInternet = true;
  bool get listenInternetConnection => listenInternet;
  set listenInternetConnection(data) {
    listenInternet = data;
  }

  Stream<InternetStatusConnection> getStreamInternetConnection(
      {showLogs = false}) async* {
    InternetStatusConnection? globalStatusConnection;
    while (listenInternetConnection) {
      try {
        InternetStatusConnection statusConnection =
            await getInternetStatusConnection(showLogs: showLogs);
        if (globalStatusConnection != statusConnection) {
          globalStatusConnection = statusConnection;
          yield globalStatusConnection;
        }
      } catch (error) {}
      await Future.delayed(const Duration(seconds: 5));
    }
  }
}
