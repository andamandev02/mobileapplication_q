import 'dart:typed_data';
import 'package:flutter/services.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';
import 'package:blue_thermal_printer/blue_thermal_printer.dart';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:image/image.dart' as img;
import 'package:qr_flutter/qr_flutter.dart';
import 'printerenum.dart';

class PrintNew {
  BlueThermalPrinter bluetooth = BlueThermalPrinter.instance;

  List<BluetoothDevice> _devices = [];
  BluetoothDevice? _device;
  bool _connected = false;

  // late Box PrinterBox;

  Future<void> initPlatformState() async {
    bool? isConnected = await bluetooth.isConnected;
    List<BluetoothDevice> devices = [];
    try {
      devices = await bluetooth.getBondedDevices();
    } on PlatformException catch (e) {
      print("Error getting bonded devices: $e");
    }

    var printerBox = await Hive.openBox('PrinterDevice');
    String? savedAddress = printerBox.get('PrinterDevice');
    await printerBox.close();

    if (savedAddress != null) {
      try {
        BluetoothDevice? savedDevice = devices.firstWhere(
          (device) => device.address == savedAddress,
        );

        if (savedDevice != null) {
          _device = savedDevice;

          try {
            await bluetooth.connect(savedDevice);
            _connected = true;
            print("Connected to the Bluetooth device");
          } catch (e) {
            _connected = false;
            print("Failed to connect: $e");
          }
        }
      } catch (e) {
        print("Saved device not found in bonded devices list: $e");
      }
    } else {
      print("กรุณาไปหน้าตั้งค่าเพื่อทำการ เลือกเครื่องพิมพ์ก่อน");
    }

    bluetooth.onStateChanged().listen((state) {
      switch (state) {
        case BlueThermalPrinter.CONNECTED:
          _connected = true;
          print("bluetooth device state: connected");
          break;
        case BlueThermalPrinter.DISCONNECTED:
          _connected = false;
          print("bluetooth device state: disconnected");
          break;
        default:
          print(state);
          break;
      }
    });

    _devices = devices;

    if (isConnected == true) {
      _connected = true;
    }
  }

  Future<Uint8List> createQrImage(String data, double size) async {
    await initPlatformState();

    final qrValidationResult = QrValidator.validate(
      data: data,
      version: QrVersions.auto,
      errorCorrectionLevel: QrErrorCorrectLevel.L,
    );

    if (qrValidationResult.status == QrValidationStatus.valid) {
      final qrCode = qrValidationResult.qrCode;
      final painter = QrPainter.withQr(
        qr: qrCode!,
        color: const Color(0xFF000000),
        emptyColor: const Color(0xFFFFFFFF),
        gapless: true,
      );

      final picData = await painter.toImageData(size);
      return picData!.buffer.asUint8List();
    } else {
      throw Exception('QR code generation failed');
    }
  }

  sample(BuildContext context, Map<String, dynamic> _qrData) async {
    // PrinterBox = await Hive.openBox('PrinterDevice');
    // String address = PrinterBox.get('PrinterDevice') ?? '';
    // print('Printer address: $address');

    // // สแกนอุปกรณ์ Bluetooth ที่เชื่อมต่อ
    // bluetooth.getBondedDevices().then((List<BluetoothDevice> devices) async {
    //   BluetoothDevice? device;

    //   // ค้นหาอุปกรณ์ที่มี address ตรงกับที่เก็บไว้ใน Hive
    //   for (BluetoothDevice d in devices) {
    //     if (d.address == address) {
    //       device = d;
    //       break;
    //     }
    //   }

    //   // ถ้าพบอุปกรณ์ ให้เชื่อมต่อกับมัน
    //   if (device != null) {
    //     await bluetooth.connect(device);
    //     print('Bluetooth connected');

    String filename = 'images-v (1).jpg';
    ByteData bytesData = await rootBundle.load("assets/logo/images-v (1).jpg");
    String dir = (await getApplicationDocumentsDirectory()).path;
    File file = await File('$dir/$filename').writeAsBytes(bytesData.buffer
        .asUint8List(bytesData.offsetInBytes, bytesData.lengthInBytes));

    /// Image from Asset
    ByteData bytesAsset = await rootBundle.load("assets/logo/images-v (1).jpg");
    Uint8List imageBytesFromAsset = bytesAsset.buffer
        .asUint8List(bytesAsset.offsetInBytes, bytesAsset.lengthInBytes);

    // Resize the image
    img.Image? image = img.decodeImage(imageBytesFromAsset);
    img.Image resizedImage = img.copyResize(image!, width: 500, height: 170);
    Uint8List resizedImageBytes =
        Uint8List.fromList(img.encodeJpg(resizedImage));

    // qrcode
    String qrDataUrl =
        'https://somboonqms.andamandev.com/en/app/kiosk/scan-queue?id=';
    final Uint8List qrCodeBytes = await createQrImage(
        '$qrDataUrl${_qrData['data']['queue']['queue_id']}', 150.0);

    /// Image from Network
    var response = await http.get(Uri.parse(
        "https://raw.githubusercontent.com/kakzaki/blue_thermal_printer/master/example/assets/images/yourlogo.png"));
    Uint8List imageBytesFromNetwork = response.bodyBytes;

    DateTime queueTime = DateTime.parse(_qrData['data']['queue']['queue_time']);
    // String formattedQueueTime =
    //     "${queueTime.day}/${queueTime.month}/${queueTime.year} ${queueTime.hour}:${queueTime.minute}";
    String formattedQueueTime =
        "${queueTime.day.toString().padLeft(2, '0')}/${queueTime.month.toString().padLeft(2, '0')}/${queueTime.year} ${queueTime.hour.toString().padLeft(2, '0')}:${queueTime.minute.toString().padLeft(2, '0')}";
    // font1
    ByteData bytesAssetFF = await rootBundle.load("assets/logo/font2.png");
    Uint8List imageBytesFromAssetFF = bytesAssetFF.buffer
        .asUint8List(bytesAssetFF.offsetInBytes, bytesAssetFF.lengthInBytes);

    // Resize the image
    img.Image? imageFF = img.decodeImage(imageBytesFromAssetFF);
    img.Image resizedImageFF =
        img.copyResize(imageFF!, width: 400, height: 100);
    Uint8List resizedImageBytesFF =
        Uint8List.fromList(img.encodeJpg(resizedImageFF));

    // font2
    ByteData bytesAssetF = await rootBundle.load("assets/logo/font2.png");
    Uint8List imageBytesFromAssetF = bytesAssetF.buffer
        .asUint8List(bytesAssetF.offsetInBytes, bytesAssetF.lengthInBytes);

    // Resize the image
    img.Image? imageF = img.decodeImage(imageBytesFromAssetF);
    img.Image resizedImageF = img.copyResize(imageF!, width: 400, height: 100);
    Uint8List resizedImageBytesF =
        Uint8List.fromList(img.encodeJpg(resizedImageF));

    // logo horizo
    int width = 100;
    int height = 100;
    bluetooth.printImageBytes(resizedImageBytes, 70, 70);

    bluetooth.printCustom(
        "${_qrData['data']['branch']['branch_name']}  ${formattedQueueTime}",
        Size.bold.val,
        Align.center.val);
    bluetooth.printNewLine();

    bluetooth.printCustom("${_qrData['data']['queue']['queue_no']}",
        Size.extraLarge.val, Align.center.val);
    bluetooth.printNewLine();

    bluetooth.printCustom("${_qrData['data']['queue']['number_pax']} PAX",
        Size.boldMedium.val, Align.center.val);
    bluetooth.printNewLine();

    bluetooth.printCustom("If your number has passed,Please get new ticket",
        Size.bold.val, Align.center.val);
    // bluetooth.printNewLine();

    // bluetooth.printQRcode(
    //     'https://somboonqms.andamandev.com/en/app/kiosk/scan-queue?id=${_qrData['data']['queue']['queue_id']}',
    //     100,
    //     100,
    //     Align.center.val);

    // bluetooth.printCustom("如果过号,请从新取牌", Size.bold.val, Align.center.val);
    bluetooth.printImageBytes(resizedImageBytesF, 1, 1);
    // bluetooth.printNewLine();
    // bluetooth.printNewLine();

    // qrcode
    bluetooth.printImageBytes(qrCodeBytes, width, height);
    bluetooth.printNewLine();

    bluetooth.printNewLine();
    bluetooth.printCustom(
        "Everyone must be here to be seated.", Size.bold.val, Align.center.val);
    // bluetooth.printNewLine();

    // bluetooth.printCustom(
    //   "所有人都需要到場才能入座",
    //   Size.bold.val,
    //   Align.center.val,
    // );
    bluetooth.printImageBytes(resizedImageBytesFF, 1, 1);
    // bluetooth.printNewLine();
    // bluetooth.printNewLine();

    bluetooth.printCustom("Waiting ${_qrData['data']['count']} Queues",
        Size.boldMedium.val, Align.center.val);
    bluetooth.printNewLine();
    bluetooth.printNewLine();

    bluetooth
        .paperCut(); // Some printers not supported (sometime making image not centered)
    // bluetooth.drawerPin2(); // Or you can use bluetooth.drawerPin5();

    print("Sample function completed");
    //   } else {
    //     print('Device not found');
    //   }
    // }).catchError((error) {
    //   print('Error getting bonded devices: $error');
    // });
  }
}
