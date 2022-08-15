import 'dart:io';

import 'package:flutter/material.dart';
import 'dart:async';

import 'package:network_type_reachability/network_type_reachability.dart';
// import 'package:permission_handler/permission_handler.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String _networkTypeStatic = 'Unknown';

  String _networkTypeSuscription = 'Unknown';
  StreamSubscription<NetworkStatus> subscriptionNetworkType;

  bool connectivityExist = false;

  StreamSubscription<bool> subscriptionNetworkConnection;
  bool connectivityExistSuscription = false;

  @override
  void initState() {
    super.initState();
    _listenNetworkStatus();
    // _listenNetworkConnection();
  }

  _listenNetworkStatus() async {
    if (Platform.isAndroid) {
      // await Permission.phone.request();
      // await NetworkTypeReachability().getPermisionsAndroid;
    }
    subscriptionNetworkType =
        NetworkTypeReachability().onNetworkStateChanged.listen((event) {
      print('------xxxxxxxxxx');
      setState(() {
        _networkTypeSuscription = "$event";
      });
    });
  }

  _listenNetworkConnection() async {
    subscriptionNetworkConnection = getStreamConnection().listen((event) {
      print('------yyyyyyyyyy');
      setState(() {
        connectivityExistSuscription = event;
      });
    });
  }

  _getCurrentNetworkStatus() async {
    if (Platform.isAndroid) {
      // await Permission.phone.request();
      // await NetworkTypeReachability().getPermisionsAndroid;
    }
    NetworkStatus status =
        await NetworkTypeReachability().currentNetworkStatus();
    switch (status) {
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
      _networkTypeStatic = status.toString();
    });
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    subscriptionNetworkType.cancel();
    subscriptionNetworkConnection.cancel();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Network Type Reachability s'),
          backgroundColor: Colors.blueAccent[900],
        ),
        body: Column(
          children: [
            _expandedContainerRow(
              flex: 1,
              color: Colors.blue,
              children: [
                Expanded(child: _box(child: const Text('Static Data'))),
                Expanded(child: _box(child: const Text('Listen to changes'))),
              ],
            ),
            _expandedContainerRow(
              children: [
                Expanded(
                  child: _box(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        const Text('NETWORK_TYPE : '),
                        Text(
                          _networkTypeStatic,
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        TextButton(
                          onPressed: () {
                            _getCurrentNetworkStatus();
                          },
                          child: Text('Get-Data'),
                          style: ButtonStyle(
                            backgroundColor: MaterialStateProperty.all(
                                Color.fromARGB(255, 162, 229, 188)),
                          ),
                        )
                      ],
                    ),
                  ),
                ),
                Expanded(
                  child: _box(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text('NETWORK_TYPE Suscription: '),
                        Text(
                          _networkTypeSuscription,
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            _expandedContainerRow(
              children: [
                Expanded(
                  child: _box(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        const Text('Status Internet Conection : '),
                        Text(
                          '$connectivityExist = ${connectivityExist == true ? 'You have' : 'you don\'t have'} internet',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        TextButton(
                          onPressed: () async {
                            connectivityExist = await NetworkTypeReachability()
                                .getIfConnectivityExist();
                            setState(() {});
                          },
                          child: Text('Get-Data'),
                          style: ButtonStyle(
                            backgroundColor: MaterialStateProperty.all(
                                Color.fromARGB(255, 162, 229, 188)),
                          ),
                        )
                      ],
                    ),
                  ),
                ),
                Expanded(
                  child: _box(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text('Status Internet Conection : '),
                        Text(
                          '$connectivityExistSuscription = ${connectivityExistSuscription == true ? 'You have' : 'you don\'t have'} internet',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            _expandedContainerRow(
              color: Colors.blue,
              children: [
                Expanded(
                  child: _box(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        const Text('NETWORK_TYPE : '),
                        Text(
                          _networkTypeStatic,
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        TextButton(
                          onPressed: () {
                            _getCurrentNetworkStatus();
                          },
                          child: Text('Get-Data'),
                          style: ButtonStyle(
                            backgroundColor: MaterialStateProperty.all(
                                Color.fromARGB(255, 162, 229, 188)),
                          ),
                        )
                      ],
                    ),
                  ),
                ),
                Expanded(child: _box(child: Text('data'))),
              ],
            ),
          ],
        ),
        // Center(
        //   child: Text('Running on: $_networkStatus\n'),
        // ),
      ),
    );
  }

  Expanded _expandedContainerRow({
    @required List<Widget> children,
    Color color = Colors.transparent,
    int flex = 4,
  }) {
    return Expanded(
      flex: flex,
      child: Container(
        color: color,
        child: Row(
          children: children,
        ),
      ),
    );
  }

  Container _box({
    Widget child,
    Color color = Colors.transparent,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black),
        color: color,
      ),
      height: double.infinity,
      child: child,
    );
  }

  Stream<bool> getStreamConnection() async* {
    bool enabled;
    print('x===>> iniciando ');
    while (true) {
      print('x===>>vuelta');
      try {
        bool isEnabled =
            await await NetworkTypeReachability().getIfConnectivityExist();
        print('x===>> $isEnabled');
        if (enabled != isEnabled) {
          enabled = isEnabled;
          yield enabled;
        }
      } catch (error) {
        print('x===>> $error');
      }
      await Future.delayed(Duration(seconds: 5));
    }
  }
}
