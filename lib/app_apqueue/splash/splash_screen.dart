import 'package:blue_thermal_printer/blue_thermal_printer.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive/hive.dart';
import '../domain.dart';
import '../print/testprint.dart';
import '../setting/setting.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animationOpacity;
  late Animation<Offset> _animationSlide;
  late List<String> _messages;
  int _currentMessageIndex = 0;

  BlueThermalPrinter bluetooth = BlueThermalPrinter.instance;

  List<BluetoothDevice> _devices = [];
  BluetoothDevice? _device;
  bool _connected = false;

  @override
  void initState() {
    super.initState();
    initPlatformState();

    _controller = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    );

    _animationOpacity = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    _animationSlide =
        Tween<Offset>(begin: Offset(0, 0), end: Offset(0, -1)).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    _messages = [
      'กำลังโหลด กรุณารอสักครู่...',
    ];

    _startMessages();

    Future.delayed(const Duration(seconds: 6), () {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => MyHomePage()),
      );
    });
  }

  Future<void> initPlatformState() async {
    bool? isConnected = await bluetooth.isConnected;
    List<BluetoothDevice> devices = [];
    try {
      devices = await bluetooth.getBondedDevices();
    } on PlatformException {}

    var PrinterBox = await Hive.openBox('PrinterDevice');
    String? savedAddress = PrinterBox.get('PrinterDevice');
    await PrinterBox.close();

    if (savedAddress != null) {
      BluetoothDevice? savedDevice = devices.firstWhere(
        (device) => device.address == savedAddress,
      );

      if (savedDevice != null) {
        setState(() {
          _device = savedDevice;
          _messages.add("กำลังเชื่อมต่อเครื่องพิมพ์");
          _messages.add("กำลังไปหน้าหลัก");
        });

        bluetooth.connect(savedDevice).then((_) {
          setState(() {
            _connected = true;
          });
        }).catchError((error) {
          setState(() {
            _connected = false;
          });
        });
      } else {
        _messages.add("กรุณาไปหน้าตั้งค่าเพื่อทำการ เลือกเครื่องพิมพ์ก่อน");
      }
    }

    bluetooth.onStateChanged().listen((state) {
      switch (state) {
        case BlueThermalPrinter.CONNECTED:
          setState(() {
            _connected = true;
            print("bluetooth device state: connected");
          });
          break;
        case BlueThermalPrinter.DISCONNECTED:
          setState(() {
            _connected = false;
            print("bluetooth device state: disconnected");
          });
          break;
        // Handle other states
        default:
          print(state);
          break;
      }
    });

    if (!mounted) return;
    setState(() {
      _devices = devices;
    });

    if (isConnected == true) {
      setState(() {
        _connected = true;
      });
    }
  }

  void _startMessages() async {
    for (int i = 0; i < _messages.length; i++) {
      setState(() {
        _currentMessageIndex = i;
      });

      _controller.forward();
      await Future.delayed(const Duration(seconds: 1));
      _controller.reverse();
      await Future.delayed(const Duration(seconds: 1));
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromRGBO(9, 159, 175, 1.0),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // แสดงรูปภาพด้านบน
            Image.asset('assets/logo/logo.png', width: 200, height: 200),
            const SizedBox(height: 20),
            // ใช้ Container เพื่อกำหนดขนาดของ LinearProgressIndicator
            Container(
              width: 200, // กำหนดความกว้างของ LinearProgressIndicator
              height: 10, // กำหนดความสูงของ LinearProgressIndicator
              child: const LinearProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(
                    Colors.white), // เปลี่ยนสีเป็นสีขาว
                backgroundColor:
                    Colors.transparent, // เปลี่ยนสีพื้นหลังให้โปร่งใส
              ),
            ),
            const SizedBox(height: 20),
            // การแสดงข้อความที่ค่อยๆ เลื่อนขึ้นและเปลี่ยนข้อความ
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: SlideTransition(
                position: _animationSlide,
                child: FadeTransition(
                  opacity: _animationOpacity,
                  child: Text(
                    _messages[_currentMessageIndex],
                    key: ValueKey<String>(_messages[_currentMessageIndex]),
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white, // เปลี่ยนสีข้อความเป็นสีขาว
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
