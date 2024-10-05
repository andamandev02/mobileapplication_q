import 'dart:async';
import 'dart:developer' as developer;

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'ืnetwork/NetworkStatus.dart';
import 'splash/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await _requestPermissions();
  await Hive.initFlutter();
  await Hive.openBox('DomainUrl');

  runApp(
    ChangeNotifierProvider(
      create: (context) => NetworkStatus(),
      child: const MyApp(),
    ),
  );
}

Future<void> _requestPermissions() async {
  final statuses = await [
    Permission.bluetooth,
    Permission.bluetoothConnect,
    Permission.bluetoothScan,
  ].request();

  if (statuses[Permission.bluetooth]!.isGranted &&
      statuses[Permission.bluetoothConnect]!.isGranted &&
      statuses[Permission.bluetoothScan]!.isGranted) {
    print('All Bluetooth permissions granted');
  } else {
    print('Some Bluetooth permissions are not granted');
  }
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: const Color.fromRGBO(9, 159, 175, 1.0),
      ),
      home: Consumer<NetworkStatus>(
        builder: (context, networkStatus, child) {
          if (networkStatus.connectionStatus != ConnectivityResult.none) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => SplashScreen()),
              );
            });
            return const SizedBox
                .shrink(); // Return an empty widget while navigating
          }

          WidgetsBinding.instance.addPostFrameCallback((_) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Row(
                  children: [
                    Icon(Icons.error, color: Colors.white),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'กำลังเชื่อมต่อ Internet',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                ),
                backgroundColor: Colors.red,
              ),
            );
          });

          return Scaffold(
            resizeToAvoidBottomInset: true,
            backgroundColor: const Color.fromRGBO(9, 159, 175, 1.0),
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircularProgressIndicator(
                    color: Colors.white,
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'กรุณาเชื่อมต่อ internet',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: Colors.white,
                        ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
