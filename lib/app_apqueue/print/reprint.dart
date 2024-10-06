import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'dart:ui' as ui;
import 'dart:typed_data';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:image/image.dart' as img;
import 'package:hive/hive.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:blue_thermal_printer/blue_thermal_printer.dart';
import 'package:flutter/services.dart';
import 'package:nyx_printer/nyx_printer.dart';

Future<void> showQRCodeDialog(
    BuildContext context, Map<String, dynamic> _qrData) async {
  BluetoothDevice? _selectedDevice;
  var printerBox = await Hive.openBox('PrinterDevice');
  String? printerAddressString = printerBox.get('PrinterDevice');
  print(printerAddressString);
  await _PrintTicket(printerAddressString!, _qrData);
  await printerBox.close();
}

Future<Uint8List> resizeImage(
    Uint8List imageBytes, int width, int height) async {
  final img.Image image = img.decodeImage(imageBytes)!;
  final img.Image resized = img.copyResize(image, width: width, height: height);
  return Uint8List.fromList(img.encodeJpg(resized));
}

Future<void> _PrintTicket(
    String printerAddressString, Map<String, dynamic> _qrData) async {
  try {
    final NyxPrinter _nyxPrinter = NyxPrinter();
    if (printerAddressString == null) return;

    String queueTimeString = _qrData['queue_time'];
    DateTime now = DateTime.now();
    List<String> timeParts = queueTimeString.split(':');
    int hour = int.parse(timeParts[0]);
    int minute = int.parse(timeParts[1]);
    int second = int.parse(timeParts[2]);

    DateTime queueTime =
        DateTime(now.year, now.month, now.day, hour, minute, second);
    String formattedQueueTime =
        "${queueTime.day}/${queueTime.month}/${queueTime.year} ${queueTime.hour}:${queueTime.minute}";
    // final image = await rootBundle.load("assets/logo/images-v.jpg");
    // await _nyxPrinter.printImage(image.buffer.asUint8List());
    final ByteData data = await rootBundle.load("assets/logo/images-v.jpg");
    final Uint8List bytes = data.buffer.asUint8List();
    final Uint8List resizedBytes = await resizeImage(bytes, 450, 150);
    await _nyxPrinter.printImage(resizedBytes);
    await _nyxPrinter.printText(
        "${_qrData['branch_name']} ${formattedQueueTime}",
        textFormat: NyxTextFormat(
          textSize: 28,
          topPadding: -5,
          align: NyxAlign.center,
          font: NyxFont.defaultBold,
          style: NyxFontStyle.bold,
        ));
    await _nyxPrinter.printText(
      "${_qrData['queue_no']}",
      textFormat: NyxTextFormat(
        topPadding: -5,
        textSize: 50,
        font: NyxFont.defaultBold,
        align: NyxAlign.center,
        style: NyxFontStyle.bold,
      ),
    );
    await _nyxPrinter.printText(
      "${_qrData['number_pax']} PAX",
      textFormat: NyxTextFormat(
        textSize: 28,
        style: NyxFontStyle.bold,
        topPadding: -5,
        font: NyxFont.defaultBold,
        align: NyxAlign.center,
      ),
    );
    // await _nyxPrinter.printText(
    //   formattedQueueTime,
    //   textFormat: NyxTextFormat(
    //     font: NyxFont.defaultBold,
    //     align: NyxAlign.center,
    //   ),
    // );
    await _nyxPrinter.printText(
      "If your number has passed,Please get a new ticket.",
      textFormat: NyxTextFormat(
        font: NyxFont.defaultFont,
        align: NyxAlign.center,
        topPadding: -5,
      ),
    );
    await _nyxPrinter.printText(
      "如果过号,请从新取牌",
      textFormat: NyxTextFormat(
        font: NyxFont.monospace,
        align: NyxAlign.center,
        topPadding: -5,
      ),
    );
    String _qrDataUrl =
        "https://somboonqms.andamandev.com/en/app/kiosk/scan-queue?id=${_qrData['queue_id']}";
    await _nyxPrinter.printQrCode(_qrDataUrl, width: 185, height: 185);
    await _nyxPrinter.printText(
      "Everyone must be here to be seated.",
      textFormat: NyxTextFormat(
        font: NyxFont.defaultBold,
        align: NyxAlign.center,
        topPadding: -5,
        style: NyxFontStyle.bold,
      ),
    );
    await _nyxPrinter.printText(
      "所有人都需要到场才能入座",
      textFormat: NyxTextFormat(
        font: NyxFont.monospace,
        topPadding: -5,
        align: NyxAlign.center,
      ),
    );
    // await _nyxPrinter.printText(
    //   "Scan to see the current number.",
    //   textFormat: NyxTextFormat(
    //     font: NyxFont.defaultBold,
    //     align: NyxAlign.center,
    //     style: NyxFontStyle.bold,
    //   ),
    // );
    // await _nyxPrinter.printText(
    //   "Wait ${_qrData['data']['result']} Queue",
    //   textFormat: NyxTextFormat(
    //     font: NyxFont.monospace,
    //     align: NyxAlign.center,
    //     textSize: 32,
    //     style: NyxFontStyle.bold,
    //   ),
    // );
    await _nyxPrinter.printText("");
    await _nyxPrinter.printText("");
    await _nyxPrinter.printText("");
  } catch (e) {
    print('Error: $e');
  }
}

Future<void> _printImage(String printerAddressString) async {
  final NyxPrinter _nyxPrinter = NyxPrinter();
  if (printerAddressString == null) return;
  try {
    final image = await rootBundle.load("assets/logo/images.jpg");
    await _nyxPrinter.printImage(image.buffer.asUint8List());
  } catch (e) {
    print(e);
  }
}
