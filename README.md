# flutter_reachability


This plugin allows Flutter applications to detect network changes. You can know the detailed mobile network types such as 2G, 3G, 4G, 5G. This plug-in is suitable for iOS and Android.
##Usage
1. get current networkstatus
**
Note: Android must dynamically obtain the READ_PHONE_STATE permission to judge 2G/3G/4G/5G**
```dart
    if(Platform.isAndroid) {
      await Permission.phone.request();
    }
    NetworkStatus status = await NetworkTypeReachability().currentNetworkStatus();
    switch(status) {
      case NetworkStatus.unreachable:
        //unreachable
      case NetworkStatus.wifi:
        //wifi
      case NetworkStatus.mobile2G:
        //2g
      case NetworkStatus.moblie3G:
        //3g
      case NetworkStatus.moblie4G:
        //4g
      case NetworkStatus.moblie5G:
        //5h
      case NetworkStatus.otherMoblie:
        //other
    }
```
2. You can also listen for network state changes by subscribing to the stream exposed by flutter_reachability plugin
```dart
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:flutter_reachability/flutter_reachability.dart';
import 'package:permission_handler/permission_handler.dart';
void main() {
  runApp(MyApp());
}
class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}
class _MyAppState extends State<MyApp> {
  String _networkStatus = 'Unknown';
  StreamSubscription<NetworkStatus> subscription;
  @override
  void initState() {
    super.initState();
    _listenNetworkStatus();
  }
  _listenNetworkStatus()async {
    if(Platform.isAndroid) {
      await Permission.phone.request();
    }
    subscription = NetworkTypeReachability().onNetworkStateChanged.listen((event) {
      setState(() {
        _networkStatus = "${event}";
      });
    });
  }
  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    subscription.cancel();
  }
```

## Getting Started

This project is a starting point for a Flutter
[plug-in package](https://flutter.dev/developing-packages/),
a specialized package that includes platform-specific implementation code for
Android and/or iOS.

For help getting started with Flutter, view our
[online documentation](https://flutter.dev/docs), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
