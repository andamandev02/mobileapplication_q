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
  // await _PrintTicket(printerAddressString!, _qrData);
  if (printerAddressString != null) {
    await _PrintTicket(printerAddressString, _qrData);
  } else {
    print('Printer address is null');
  }
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
    DateTime queueTime = DateTime.parse(_qrData['data']['queue']['queue_time']);
    String formattedQueueTime =
        "${queueTime.day}/${queueTime.month}/${queueTime.year} ${queueTime.hour}:${queueTime.minute}";
    final ByteData data = await rootBundle.load("assets/logo/images-v.jpg");
    final Uint8List bytes = data.buffer.asUint8List();

    final Uint8List resizedBytes = await resizeImage(bytes, 450, 150);
    // final image = await rootBundle.load("assets/logo/images-v.jpg");
    // await _nyxPrinter.printImage(image.buffer.asUint8List());
    // await _nyxPrinter.printText("Tomato\n 9\$",
    //   textFormat: NyxTextFormat(topPadding : -5),
    // );
    // await _nyxPrinter.printText("Tomato\n 9\$",
    //   textFormat: NyxTextFormat(topPadding : -10),
    // );
    await _nyxPrinter.printImage(resizedBytes);
    await _nyxPrinter.printText(
        "${_qrData['data']['branch']['branch_name']}  ${formattedQueueTime}  ",
        textFormat: NyxTextFormat(
          textSize: 28,
          align: NyxAlign.center,
          topPadding: -5,
          font: NyxFont.defaultBold,
          style: NyxFontStyle.bold,
        ));
    await _nyxPrinter.printText(
      "${_qrData['data']['queue']['queue_no']}",
      textFormat: NyxTextFormat(
        textSize: 50,
        topPadding: -5,
        font: NyxFont.defaultFont,
        align: NyxAlign.center,
        style: NyxFontStyle.bold,
      ),
    );
    await _nyxPrinter.printText(
      "${_qrData['data']['queue']['number_pax']} PAX",
      textFormat: NyxTextFormat(
        textSize: 28,
        style: NyxFontStyle.bold,
        font: NyxFont.defaultFont,
        topPadding: -8,
        align: NyxAlign.center,
      ),
    );
    await _nyxPrinter.printText(
      "If your number has passed,Please get a new ticket",
      textFormat: NyxTextFormat(
        font: NyxFont.defaultFont,
        topPadding: -5,
        align: NyxAlign.center,
        // style: NyxFontStyle.bold,
      ),
    );
    await _nyxPrinter.printText(
      "如果过号,请从新取牌",
      textFormat: NyxTextFormat(
        font: NyxFont.monospace,
        topPadding: -5,
        align: NyxAlign.center,
      ),
    );
    String _qrDataUrl =
        "https://somboonqms.andamandev.com/en/app/kiosk/scan-queue?id=${_qrData['data']['queue']['queue_id']}";
    await _nyxPrinter.printQrCode(_qrDataUrl, width: 185, height: 185);
    await _nyxPrinter.printText(
      "Everyone must be here to be seated.",
      textFormat: NyxTextFormat(
        font: NyxFont.defaultBold,
        topPadding: -5,
        align: NyxAlign.center,
        style: NyxFontStyle.bold,
      ),
    );
    await _nyxPrinter.printText(
      "所有人都需要到场才能入座",
      textFormat: NyxTextFormat(
        topPadding: -5,
        font: NyxFont.monospace,
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
    await _nyxPrinter.printText(
      "Waiting ${_qrData['data']['count']} Queues",
      textFormat: NyxTextFormat(
        topPadding: -5,
        font: NyxFont.monospace,
        align: NyxAlign.center,
        // textSize: 30,
        style: NyxFontStyle.bold,
      ),
    );
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
