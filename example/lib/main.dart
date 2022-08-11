import 'dart:io';

import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:network_type_reachability/network_type_reachability.dart';
import 'package:permission_handler/permission_handler.dart';

void main() {
  runApp(const MyApp());
} 

class MyApp extends StatefulWidget {
  const MyApp({Key key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
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

  _currentNetworkStatus() async {
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
    setState(() {
      _networkStatus = status.toString() ;
    });
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    subscription.cancel();
  }


  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: Center(
          child: Text('Running on: $_networkStatus\n'),
        ),
      ),
    );
  }
}
