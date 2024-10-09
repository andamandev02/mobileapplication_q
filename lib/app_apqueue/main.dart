import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'loading/loadingstart.dart';
import 'provider/provider.dart';
import 'dart:async';
import 'dart:developer' as developer;
import 'package:permission_handler/permission_handler.dart';

import 'provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await _requestPermissions();
  final appDocumentDir = await getApplicationDocumentsDirectory();
  await Hive.initFlutter(appDocumentDir.path);
  await Hive.openBox('Domain');
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => DataProvider()..loadData()),
      ],
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
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: LoadingStart(),
    );
  }
}
