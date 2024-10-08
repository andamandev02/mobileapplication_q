import 'package:hive/hive.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:blue_thermal_printer/blue_thermal_printer.dart';
import 'package:flutter/services.dart';
import 'package:nyx_printer/nyx_printer.dart';

class SettingScreen extends StatefulWidget {
  const SettingScreen({super.key});

  @override
  State<SettingScreen> createState() => _SettingScreenState();

  static void sample(BuildContext context, Map<String, dynamic> qrData) {}
}

class _SettingScreenState extends State<SettingScreen> {
  BlueThermalPrinter _blueThermalPrinter = BlueThermalPrinter.instance;
  List<BluetoothDevice> _devices = [];
  BluetoothDevice? _selectedDevice;
  final NyxPrinter _nyxPrinter = NyxPrinter();

  @override
  void initState() {
    super.initState();
    _loadConnectedDevices();
    loadDataFromHive();
  }

  Future<void> loadDataFromHive() async {
    var PrinterBox = await Hive.openBox('PrinterDevice');
    String? printerAddress = PrinterBox.get('PrinterDevice');
    BluetoothDevice? foundDevice;
    if (printerAddress != null) {
      foundDevice = _devices.firstWhere(
        (device) => device.address == printerAddress,
      );
      if (foundDevice != null) {
        setState(() {
          _selectedDevice = foundDevice;
        });
      }
    }
    await PrinterBox.close();
  }

  Future<void> _loadConnectedDevices() async {
    try {
      final devices = await _blueThermalPrinter.getBondedDevices();
      setState(() {
        _devices = devices;
        if (_devices.isNotEmpty) {
          _selectedDevice = _devices.first;
        }
      });
    } catch (e) {
      print(e);
    }
  }

  Future<void> _selectDevice(BluetoothDevice? device) async {
    setState(() async {
      _selectedDevice = device;
      var PrinterBox = await Hive.openBox('PrinterDevice');
      await PrinterBox.put('PrinterDevice', _selectedDevice!.address);
      await PrinterBox.close();
      await loadDataFromHive();
    });
  }

  Future<void> _printImage() async {
    if (_selectedDevice == null) return;
    try {
      final image = await rootBundle.load("assets/logo/images.jpg");
      await _nyxPrinter.printImage(image.buffer.asUint8List());
    } catch (e) {
      print(e);
    }
  }

  Future<void> _printText(String text, {NyxTextFormat? format}) async {
    if (_selectedDevice == null) return;
    try {
      await _nyxPrinter.printText(text, textFormat: format);
    } catch (e) {
      print(e);
    }
  }

  Future<void> _printBarcode() async {
    if (_selectedDevice == null) return;
    try {
      await _nyxPrinter.printBarcode("123456789", width: 300, height: 40);
    } catch (e) {
      print(e);
    }
  }

  Future<void> _printQr() async {
    if (_selectedDevice == null) return;
    try {
      await _nyxPrinter.printQrCode("123456789", width: 200, height: 200);
    } catch (e) {
      print(e);
    }
  }

  Future<void> _printReceipt() async {
    if (_selectedDevice == null) return;
    try {
      await _nyxPrinter.printText("Grocery Store",
          textFormat: NyxTextFormat(
            textSize: 32,
            align: NyxAlign.center,
            font: NyxFont.monospace,
            style: NyxFontStyle.boldItalic,
          ));
      await _nyxPrinter.printText("Invoice: 000001");
      await _nyxPrinter.printText("Seller: Mike");
      await _nyxPrinter.printText("Neme\t\t\t\t\t\t\t\t\t\t\t\tPrice");
      await _nyxPrinter.printText(
        "Cucumber\t\t\t\t\t\t\t\t\t\t10\$",
        textFormat: NyxTextFormat(topPadding: 5),
      );
      await _nyxPrinter.printText("Potato Fresh\t\t\t\t\t\t\t\t\t15\$");
      await _nyxPrinter.printText("Tomato\t\t\t\t\t\t\t\t\t\t\t 9\$");
      await _nyxPrinter.printText(
        "Tax\t\t\t\t\t\t\t\t\t\t\t\t\t  4\$",
        textFormat: NyxTextFormat(
          topPadding: 5,
          style: NyxFontStyle.bold,
          textSize: 26,
        ),
      );
      await _nyxPrinter.printText(
        "Total\t\t\t\t\t\t\t\t\t\t\t\t34\$",
        textFormat: NyxTextFormat(
          topPadding: 5,
          style: NyxFontStyle.bold,
          textSize: 26,
        ),
      );
      await _nyxPrinter.printQrCode("123456789", width: 200, height: 200);
      await _nyxPrinter.printText("");
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Bluetooth Printer App'),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: <Widget>[
                DropdownButton<BluetoothDevice>(
                  items: _devices
                      .map((device) => DropdownMenuItem(
                            child: Text(device.name!),
                            value: device,
                          ))
                      .toList(),
                  onChanged: _selectDevice,
                  value: _selectedDevice,
                ),
                SizedBox(
                  width: size.width,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: _printImage,
                    child: const Text('Print Image'),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Row(
                    children: [
                      Expanded(
                        flex: 1,
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: SizedBox(
                            height: 48,
                            child: ElevatedButton(
                              onPressed: () => _printText("Welcome to Nyx"),
                              child: const Text('Text Left'),
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 1,
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: SizedBox(
                            height: 48,
                            child: ElevatedButton(
                              onPressed: () => _printText(
                                "Welcome to Nyx",
                                format: NyxTextFormat(align: NyxAlign.center),
                              ),
                              child: const Text('Text Center'),
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 1,
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: SizedBox(
                            height: 48,
                            child: ElevatedButton(
                              onPressed: () => _printText(
                                "Welcome to Nyx",
                                format: NyxTextFormat(align: NyxAlign.right),
                              ),
                              child: const Text('Text Right'),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: SizedBox(
                    width: size.width,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: _printBarcode,
                      child: const Text('Print Barcode'),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: SizedBox(
                    width: size.width,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: _printQr,
                      child: const Text('Print QR'),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: SizedBox(
                    width: size.width,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: _printReceipt,
                      child: const Text('Print Receipt'),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
