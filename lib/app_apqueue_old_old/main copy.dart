import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'ืnetwork/NetworkStatus.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'splash/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await _requestPermissions();
  await Hive.initFlutter();
  await Hive.openBox('DomainUrl');
  runApp(
    ChangeNotifierProvider(
      create: (context) => NetworkStatus(),
      child: MyApp(),
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
    print('All permissions granted');
  } else {
    print('Some permissions are not granted');
  }
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: SplashScreen(), // ใช้ SplashScreen เป็นหน้าแรก
    );
  }
}
