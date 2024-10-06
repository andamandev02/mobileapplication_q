import 'dart:typed_data';
import 'package:flutter/services.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:path_provider/path_provider.dart';
import 'package:blue_thermal_printer/blue_thermal_printer.dart';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:image/image.dart' as img;
import 'package:qr_flutter/qr_flutter.dart';
import 'printerenum.dart';

class RePrintNew {
  BlueThermalPrinter bluetooth = BlueThermalPrinter.instance;

  Future<Uint8List> createQrImage(String data, double size) async {
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
    final Uint8List qrCodeBytes =
        await createQrImage('$qrDataUrl${_qrData['queue_id']}', 150.0);

    /// Image from Network
    var response = await http.get(Uri.parse(
        "https://raw.githubusercontent.com/kakzaki/blue_thermal_printer/master/example/assets/images/yourlogo.png"));
    Uint8List imageBytesFromNetwork = response.bodyBytes;

    String queueTimeString = _qrData['queue_time'];
    DateTime now = DateTime.now();
    List<String> timeParts = queueTimeString.split(':');
    int hour = int.parse(timeParts[0]);
    int minute = int.parse(timeParts[1]);
    int second = int.parse(timeParts[2]);

    DateTime queueTime =
        DateTime(now.year, now.month, now.day, hour, minute, second);
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

    bluetooth.isConnected.then((isConnected) {
      if (isConnected == true) {
        // logo horizo
        int width = 100;
        int height = 100;
        bluetooth.printImageBytes(resizedImageBytes, 70, 70);

        bluetooth.printCustom("${_qrData['branch_name']} ${formattedQueueTime}",
            Size.bold.val, Align.center.val);
        bluetooth.printNewLine();

        bluetooth.printCustom(
            "${_qrData['queue_no']}", Size.extraLarge.val, Align.center.val);
        bluetooth.printNewLine();

        bluetooth.printCustom("${_qrData['number_pax']} PAX",
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
        bluetooth.printCustom("Everyone must be here to be seated.",
            Size.bold.val, Align.center.val);
        // bluetooth.printNewLine();

        // bluetooth.printCustom(
        //   "所有人都需要到場才能入座",
        //   Size.bold.val,
        //   Align.center.val,
        // );
        bluetooth.printImageBytes(resizedImageBytesFF, 1, 1);
        // bluetooth.printNewLine();
        // bluetooth.printNewLine();

        // bluetooth.printCustom("Waiting ${_qrData['data']['count']} Queues",
        //     Size.boldMedium.val, Align.center.val);

        bluetooth.printNewLine();
        bluetooth.printNewLine();

        bluetooth
            .paperCut(); // Some printers not supported (sometime making image not centered)
        // bluetooth.drawerPin2(); // Or you can use bluetooth.drawerPin5();

        // Debug print after printing image
        print("Finished printing image from asset");
      } else {
        print("Bluetooth is not connected");
      }
    }).catchError((error) {
      print("Error checking Bluetooth connection: $error");
    });

    print("Sample function completed");
  }
}
