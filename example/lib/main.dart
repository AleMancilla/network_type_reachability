import 'package:flutter/material.dart';
import 'dart:async';

import 'package:network_type_reachability/network_type_reachability.dart';

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

  String connectivityInternetStatic = 'Unknown';

  String connectivityInternetSuscription = 'Unknown';
  StreamSubscription<InternetStatusConnection> subscriptionInternetConnection;

  @override
  void initState() {
    super.initState();
    _listenNetworkStatus();
    _listenInternetConnection();
  }

  _listenNetworkStatus() async {
    if (Platform.isAndroid) {
      await NetworkTypeReachability().getPermisionsAndroid;
    }
    subscriptionNetworkType =
        NetworkTypeReachability().onNetworkStateChanged.listen((event) {
      setState(() {
        _networkTypeSuscription = "$event";
      });
    });
  }

  _listenInternetConnection() async {
    subscriptionInternetConnection = NetworkTypeReachability()
        .getStreamInternetConnection(showLogs: false)
        .listen((event) {
      setState(() {
        connectivityInternetSuscription = event.toString();
      });
    });
  }

  _getCurrentNetworkStatus() async {
    NetworkStatus status =
        await NetworkTypeReachability().currentNetworkStatus();
    switch (status) {
      case NetworkStatus.unreachable:
      //unreachable
      case NetworkStatus.wifi:
      //wifi
      case NetworkStatus.mobile2G:
      //2g
      case NetworkStatus.mobile3G:
      //3g
      case NetworkStatus.mobile4G:
      //4g
      case NetworkStatus.mobile5G:
      //5h
      case NetworkStatus.otherMobile:
      //other
    }
    setState(() {
      _networkTypeStatic = status.toString();
    });
  }

  @override
  void dispose() {
    super.dispose();
    subscriptionNetworkType.cancel();
    subscriptionInternetConnection.cancel();
    NetworkTypeReachability().listenInternetConnection = false;
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Network Type Reachability'),
          backgroundColor: Colors.blueAccent[900],
        ),
        body: Column(
          children: [
            _expandedContainerRow(
              flex: 1,
              color: Colors.blueGrey[900],
              children: [
                Expanded(
                  child: _box(
                    child: const Center(
                      child: Text(
                        'Static Data',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: _box(
                    child: const Center(
                      child: Text(
                        'Listen to changes',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            _expandedContainerRow(
              children: [
                Expanded(
                  child: _box(
                    color: _colorStatusNetworkType(_networkTypeStatic),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        const Text('NETWORK_TYPE : '),
                        Text(
                          _networkTypeStatic,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        TextButton(
                          onPressed: () {
                            _getCurrentNetworkStatus();
                          },
                          child: const Text('Get-Data'),
                          style: ButtonStyle(
                            backgroundColor: MaterialStateProperty.all(
                                const Color.fromARGB(255, 162, 229, 188)),
                          ),
                        )
                      ],
                    ),
                  ),
                ),
                Expanded(
                  child: _box(
                    color: _colorStatusNetworkType(_networkTypeSuscription),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text('NETWORK_TYPE Suscription: '),
                        Text(
                          _networkTypeSuscription,
                          style: const TextStyle(fontWeight: FontWeight.bold),
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
                    color: _colorStatusInternetType(connectivityInternetStatic),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        const Text('Status Internet Conection : '),
                        Text(
                          connectivityInternetStatic,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        TextButton(
                          onPressed: () async {
                            print('#=======> cargando');
                            connectivityInternetStatic = 'loading...';
                            setState(() {});
                            InternetStatusConnection data =
                                await NetworkTypeReachability()
                                    .getInternetStatusConnection();
                            print(data);
                            print('#=======> finalizando');

                            connectivityInternetStatic = data.toString();
                            setState(() {});
                          },
                          child: const Text('Get-Data'),
                          style: ButtonStyle(
                            backgroundColor: MaterialStateProperty.all(
                                const Color.fromARGB(255, 162, 229, 188)),
                          ),
                        )
                      ],
                    ),
                  ),
                ),
                Expanded(
                  child: _box(
                    color: _colorStatusInternetType(
                        connectivityInternetSuscription),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text('Status Internet Conection : '),
                        Text(
                          connectivityInternetSuscription,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
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
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black26),
        color: color,
      ),
      height: double.infinity,
      child: child,
    );
  }

  Color _colorStatusNetworkType(String data) {
    // case NetworkStatus.unreachable:
    // case NetworkStatus.wifi:
    // case NetworkStatus.mobile2G:
    // case NetworkStatus.mobile3G:
    // case NetworkStatus.mobile4G:
    // case NetworkStatus.mobile5G:
    // case NetworkStatus.othermobile:
    switch (data) {
      case 'Unknown':
        return Colors.yellow.shade100;
        break;
      case 'NetworkStatus.unreachable':
        return Colors.red.shade100;
        break;
      default:
        return Colors.green.shade100;
        break;
    }
  }

  Color _colorStatusInternetType(String data) {
    // withoutInternet,
    // withInternet,
    // unstableInternet,
    switch (data) {
      case 'Unknown':
        return Colors.yellow.shade100;
        break;
      case 'InternetStatusConnection.withoutInternet':
        return Colors.red.shade100;
        break;
      case 'InternetStatusConnection.withInternet':
        return Colors.green.shade100;
        break;
      case 'InternetStatusConnection.unstableInternet':
        return Colors.brown.shade100;
        break;
      default:
        return Colors.yellow.shade100;
        break;
    }
  }
}
