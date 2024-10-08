import 'package:hive/hive.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:blue_thermal_printer/blue_thermal_printer.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../print/testprint.dart';
import '../provider/provider.dart';

class SettingScreen extends StatefulWidget {
  const SettingScreen({super.key});

  @override
  State<SettingScreen> createState() => _SettingScreenState();

  static void sample(BuildContext context, Map<String, dynamic> qrData) {}
}

class _SettingScreenState extends State<SettingScreen> {
  BlueThermalPrinter bluetooth = BlueThermalPrinter.instance;

  List<BluetoothDevice> _devices = [];
  BluetoothDevice? _device;
  bool _connected = false;
  TestPrint testPrint = TestPrint();

  bool isChecked = false;

  late TextEditingController _colorController = TextEditingController();
  Color _selectedColor = Colors.white;

  void _updateColor() {
    String colorString = _colorController.text;
    if (RegExp(r'^#([0-9A-Fa-f]{3}){1,2}$').hasMatch(colorString)) {
      setState(() {
        _selectedColor =
            Color(int.parse(colorString.replaceFirst('#', '0xff')));
        Provider.of<DataProvider>(context, listen: false)
            .setColorValue(_selectedColor);
        setState(() {});
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('โปรดป้อนรหัสสีที่ถูกต้อง')),
      );
    }
  }

  @override
  void initState() {
    super.initState();
  }

  late DataProvider _dataProvider;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _dataProvider = Provider.of<DataProvider>(context);
    initPlatformState();
  }

  Future<void> addToHive(String GiveName) async {
    Provider.of<DataProvider>(context, listen: false)
        .setGiveNameValue(GiveName);
    setState(() {});
  }

  void _onCheckboxChanged(bool? value) {
    setState(() {
      isChecked = value ?? false;
      addToHive(isChecked ? 'Checked' : 'Unchecked');
    });
  }

  String colorToHex(Color color) {
    return '#${color.value.toRadixString(16).substring(2).toUpperCase()}'; // แปลงเป็น HEX String
  }

  Future<void> initPlatformState() async {
    final hiveData = Provider.of<DataProvider>(context);
    String? storedValue = hiveData.givenameValue ?? "Loading...";
    if (storedValue == 'Checked') {
      setState(() {
        isChecked = true;
      });
    }
    Color colorString = hiveData.colorValue ?? const Color(0xFF099FAF);
    setState(() {
      _selectedColor = colorString;
      _colorController.text = colorToHex(colorString);
    });

    bool? isConnected = await bluetooth.isConnected;
    List<BluetoothDevice> devices = [];
    try {
      devices = await bluetooth.getBondedDevices();
    } on PlatformException {}

    String? savedAddress = hiveData.printerValue ?? "Loading...";

    if (savedAddress != null) {
      BluetoothDevice? savedDevice = devices.firstWhere(
        (device) => device.address == savedAddress,
      );

      if (savedDevice != null) {
        if (mounted) {
          setState(() {
            _connected = true;
            _device = savedDevice;
          });
        }

        // Attempt to connect to the saved device
        bluetooth.connect(savedDevice).then((_) {
          if (mounted) {
            setState(() {
              _connected = true;
            });
          }
        }).catchError((error) {
          if (mounted) {
            setState(() {
              _connected = false;
            });
          }
        });
      }
    }

    bluetooth.onStateChanged().listen((state) {
      if (mounted) {
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
      }
    });

    if (mounted) {
      setState(() {
        _devices = devices;
      });
    }

    if (isConnected == true) {
      if (mounted) {
        setState(() {
          _connected = true;
        });
      }
    }
  }

  @override
  void dispose() {
    super.dispose();
    bluetooth.disconnect(); // Ensure disconnection on dispose
  }

  @override
  Widget build(BuildContext context) {
    final hiveData = Provider.of<DataProvider>(context);

    return Scaffold(
      backgroundColor: hiveData.colorValue,
      appBar: AppBar(
        title: const Text(
          'การตั้งค่าระบบ | Setting Systems',
          style: TextStyle(
            fontSize: 25.0,
            color: Colors.white,
          ),
        ),
        iconTheme: const IconThemeData(
          color: Colors.white,
        ),
        backgroundColor: hiveData.colorValue,
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ListView(
          children: <Widget>[
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                const SizedBox(width: 10),
                const Text(
                  'เลือกเครื่องพิมพ์ | Device :',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 30),
                Expanded(
                  child: DropdownButton(
                    items: _getDeviceItems(),
                    onChanged: (BluetoothDevice? value) =>
                        setState(() => _device = value),
                    value: _device,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                ElevatedButton(
                  style:
                      ElevatedButton.styleFrom(backgroundColor: Colors.brown),
                  onPressed: () {
                    initPlatformState();
                  },
                  child: const Text(
                    'รีเฟรช | Refresh',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
                const SizedBox(width: 20),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      backgroundColor: _connected ? Colors.red : Colors.green),
                  onPressed: _connected ? _disconnect : _connect,
                  child: Text(
                    _connected
                        ? 'กำลังเชื่อมต่ออยู่ | Connected'
                        : 'เชื่อมต่อ | Connect',
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.only(left: 10.0, right: 10.0, top: 20),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.brown),
                onPressed: () {
                  testPrint.sample();
                },
                child: const Text('ทดสอบพิมพ์ | PRINT TEST',
                    style: TextStyle(color: Colors.white)),
              ),
            ),
            const SizedBox(height: 20),
            Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: _selectedColor,
                      border:
                          Border.all(color: Colors.white, width: 1), // ขอบสีขาว
                      borderRadius: BorderRadius.circular(8), // มุมมน
                    ),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start, // จัดให้ข้อความอยู่ทางซ้าย
                      children: [
                        TextField(
                          controller: _colorController,
                          decoration: InputDecoration(
                            labelText:
                                'กรุณากรอกรหัสสี | Enter color code (e.g., #FF5733)',
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(50.0)),
                            filled: true,
                            fillColor: Colors.white, // พื้นหลังของ TextField
                          ),
                          style: TextStyle(color: Colors.black), // สีของข้อความ
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Transform.scale(
                  scale: 1.5,
                  child: Checkbox(
                    value: isChecked,
                    onChanged: _onCheckboxChanged,
                  ),
                ),
                const SizedBox(width: 20),
                const Text(
                    'ทำการ เพิ่มชื่อ และ เบอร์โทรศัพท์ของลูกค้าได้\nGive Name & Phone In Numpad',
                    style: TextStyle(color: Colors.white, fontSize: 14)),
              ],
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.brown),
              onPressed: _updateColor,
              child: const Text('บันทึกสี | Set Color',
                  style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  List<DropdownMenuItem<BluetoothDevice>> _getDeviceItems() {
    List<DropdownMenuItem<BluetoothDevice>> items = [];
    if (_devices.isEmpty) {
      items.add(const DropdownMenuItem(
        child: Text(
          'NONE',
          style: TextStyle(color: Colors.white),
        ),
      ));
    } else {
      _devices.forEach((device) {
        items.add(DropdownMenuItem(
          child: Text(device.name ?? ""),
          value: device,
        ));
      });
    }
    return items;
  }

  void _connect() async {
    if (_device != null) {
      bool? isConnected = await bluetooth.isConnected;
      if (!isConnected!) {
        bluetooth.connect(_device!).then((_) async {
          Provider.of<DataProvider>(context, listen: false)
              .setPrinterValue(_device!.address!);

          if (mounted) {
            setState(() => _connected = true);
          }
        }).catchError((error) {
          if (mounted) {
            setState(() => _connected = false);
          }
        });
      }
    } else {
      show('No device selected.');
    }
  }

  void _disconnect() {
    bluetooth.disconnect();
    if (mounted) {
      setState(() => _connected = false);
    }
  }

  Future show(
    String message, {
    Duration duration = const Duration(seconds: 3),
  }) async {
    await Future.delayed(const Duration(milliseconds: 100));
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            message,
            style: const TextStyle(color: Colors.white),
          ),
          duration: duration,
        ),
      );
    }
  }
}
