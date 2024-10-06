import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:blue_thermal_printer/blue_thermal_printer.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:http/http.dart' as http;
import 'package:socket_io_client/socket_io_client.dart' as IO;
import '../url.dart';
import '../../print/printing.dart';
import '../../print/printing_new.dart';
import '../../setting/setting.dart';

class ClassCQueue {
  IO.Socket? socket;
  PrintNew testPrint = PrintNew();
  BlueThermalPrinter bluetooth = BlueThermalPrinter.instance;
  late Box PrinterBox;

  // Method to initialize WebSocket connection
  Future<void> initializeWebSocket() async {
    if (socket == null || !socket!.connected) {
      _connect();
    }
  }

  void _connect() {
    socket = IO.io(
      SOCKET_IO_HOST,
      IO.OptionBuilder()
          .setTransports(['websocket'])
          .setPath(SOCKET_IO_PATH)
          .setExtraHeaders({'Connection': 'upgrade', 'Upgrade': 'websocket'})
          .enableForceNew()
          .build(),
    );

    socket?.onConnect((_) {});

    socket?.onConnectError((err) {
      print('Connect Error: $err');
      // Handle connection error
    });

    socket?.onError((err) {
      print('Error: $err');
      // Handle socket error
    });

    socket?.connect();
  }

  void close() {
    if (socket != null) {
      socket?.disconnect();
      socket = null;
    }
  }

  Future<void> createQueue({
    required BuildContext context,
    required String Pax,
    required Map<String, dynamic> TicketKioskDetail,
    required Map<String, dynamic> Branch,
    required Map<String, dynamic> Kiosk,
  }) async {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    try {
      var body = jsonEncode({
        'Pax': Pax,
        'TicketKioskDetail': jsonEncode(TicketKioskDetail),
        'Branch': jsonEncode(Branch),
        'Kiosk': jsonEncode(Kiosk),
      });

      final response = await http.post(
        Uri.parse(
            'https://somboonqms.andamandev.com/api/v1/queue-mobile/create-queue'),
        headers: <String, String>{
          HttpHeaders.contentTypeHeader: 'application/json; charset=UTF-8',
        },
        body: body,
      );

      if (response.statusCode == 200) {
        Map<String, dynamic> _qrData = jsonDecode(response.body);

        // // เปิดกล่อง Hive
        // PrinterBox = await Hive.openBox('PrinterDevice');
        // String? address = PrinterBox.get('PrinterDevice');

        // print(address);

        // // ตรวจสอบว่า address ไม่เป็น null หรือว่างเปล่า
        // print("aaaaaaaaaaaaaaaa");
        // if (address == null || address.isEmpty) {
        //   return;
        // } else {
        //   print("aaaaaaaaaaaaaaaa////////");

        //   // สแกนอุปกรณ์ Bluetooth ที่เชื่อมต่อ
        //   bluetooth
        //       .getBondedDevices()
        //       .then((List<BluetoothDevice> devices) async {
        //     BluetoothDevice? device;

        //     // ค้นหาอุปกรณ์ที่มี address ตรงกับที่เก็บไว้ใน Hive
        //     for (BluetoothDevice d in devices) {
        //       if (d.address == address) {
        //         device = d;
        //         break;
        //       }
        //     }
        //     print("cccccccccccccccccccccccc");

        //     print(device);

        //     // ตรวจสอบว่า device ไม่เป็น null ก่อนเชื่อมต่อ
        //     if (device != null) {
        //       await bluetooth.connect(device);

        // สำหรับ NB80
        // showQRCodeDialog(context, _qrData);

        // สำหรับเลือกบลูทูะปกติ
        testPrint.sample(context, _qrData);
        if (socket == null || !socket!.connected) {
          await initializeWebSocket();
          socket?.emit(REGISTER, <String, dynamic>{
            'queue': 'register',
            'data': 'สร้างคิว',
            // 'branch': branchid
          });
        } else {
          socket?.emit(REGISTER, <String, dynamic>{
            'queue': 'register',
            'data': 'สร้างคิว',
            // 'branch': branchid
          });
        }
        // } else {
        //   Future.delayed(const Duration(seconds: 2), () {
        //     Navigator.of(context).pushReplacement(
        //       MaterialPageRoute(
        //           builder: (context) => const SettingScreen()),
        //     );
        //   });
        // }
        // }).catchError((error) {
        //   String ToMsg = "เกิดปัญหาทางเทคนิค";
        //   String queueNumber = error.toString();
        //   SnackBarHelper.showErrorDialog(context, ToMsg, queueNumber);
        // });
        // }
      } else {
        String ToMsg = "เกิดปัญหาทางเทคนิค";
        String queueNumber = "กรุณาโปรดแจ้งพนักงาน";
        SnackBarHelper.showErrorDialog(context, ToMsg, queueNumber);
      }
    } catch (e) {
      String ToMsg = "ERRORS";
      String queueNumber = '$e';
      SnackBarHelper.showErrorDialog(context, ToMsg, queueNumber);
    }
  }

  Future<void> clearQueue({
    required BuildContext context,
    required String branchid,
  }) async {
    try {
      final queryParameters = {
        'branchid': branchid,
      };
      final uri = Uri.parse(
              'https://somboonqms.andamandev.com/api/v1/queue-mobile/mid-night')
          .replace(queryParameters: queryParameters);
      final response = await http.post(
        uri,
        headers: <String, String>{
          HttpHeaders.contentTypeHeader: 'application/json; charset=UTF-8',
        },
      );

      // final body = jsonEncode({
      //   'branchid': branchid,
      // });

      // final response = await http.post(
      //   Uri.parse(
      //       'https://somboonqms.andamandev.com/api/v1/queue-mobile/mid-night'),
      //   headers: <String, String>{
      //     HttpHeaders.contentTypeHeader: 'application/json; charset=UTF-8',
      //   },
      //   body: body,
      // );

      if (response.statusCode == 200) {
        var ToSocket = CALL;
        String ToMsg1 = "กำลังเคลียคิว";
        if (socket == null || !socket!.connected) {
          await initializeWebSocket();
          socket?.emit(CALL, <String, dynamic>{
            'queue': 'call',
            'data': 'เคลียคิว',
            'branch': branchid
          });
        } else {
          socket?.emit(CALL, <String, dynamic>{
            'queue': 'call',
            'data': 'เคลียคิว',
            'branch': branchid
          });
        }

        String ToMsg = "ทำการเคลียคิว";
        String queueNumber = "เรียบร้อยแล้ว";
        SnackBarHelper.showErrorDialog(context, ToMsg, queueNumber);
        Navigator.of(context).pop();
      } else {
        String ToMsg = "เกิดปัญหาทางเทคนิค";
        String queueNumber = "กรุณาโปรดแจ้งพนักงาน";
        SnackBarHelper.showErrorDialog(context, ToMsg, queueNumber);
      }
    } catch (e) {
      String ToMsg = "ERRORS";
      String queueNumber = '$e';
      SnackBarHelper.showErrorDialog(context, ToMsg, queueNumber);
    }
  }

  Future<void> UpdateQueue(
      {required BuildContext context,
      required List<Map<String, dynamic>> SearchQueue,
      required String StatusQueue,
      required String StatusQueueNote}) async {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    try {
      await initializeWebSocket();

      var body = jsonEncode({
        'SearchQueue': jsonEncode(SearchQueue),
        'StatusQueue': jsonEncode(StatusQueue),
        'StatusQueueNote': jsonEncode(StatusQueueNote),
      });

      final response = await http.post(
        Uri.parse(
            'https://somboonqms.andamandev.com/api/v1/queue-mobile/update-queue'),
        headers: <String, String>{
          HttpHeaders.contentTypeHeader: 'application/json; charset=UTF-8',
        },
        body: body,
      );

      var ToSocket = '';
      String ToMsg = '';

      if (response.statusCode == 200) {
        Map<String, dynamic> jsonData = jsonDecode(response.body);
        Map<String, dynamic> data = jsonData['data'];
        Map<String, dynamic> innerData = data['data'];
        Map<String, dynamic> queueData = innerData['queue'];

        if (StatusQueue == 'Calling') {
          ToSocket = CALL;
          ToMsg = "กำลังเรียกคิว";
        } else if (StatusQueue == 'Holding') {
          ToSocket = HOLD;
          ToMsg = "กำลังพักคิว";
        } else if (StatusQueue == 'Ending') {
          ToSocket = FINISH;
          ToMsg = "กำลังยกเลิกคิว";
        } else if (StatusQueue == 'Finishing') {
          ToSocket = FINISH;
          ToMsg = "กำลังจบคิว";
        } else if (StatusQueue == 'Recalling') {
          ToSocket = CALL;
          ToMsg = "กำลังเรียกคิวซ้ำ";
        }

        String queueNumber = "${jsonData['data']['data']['queue']['queue_no']}";
        // SnackBarHelper.showErrorDialog(context, ToMsg, queueNumber);
        SnackBarHelper.showErrorDialog(context, ToMsg, queueNumber);

        if (innerData.containsKey('caller') && innerData['caller'] is Map) {
          Map<String, dynamic> callerData = innerData['caller'];
          String callerid = callerData['caller_id']?.toString() ?? '';

          if (socket == null || !socket!.connected) {
            await initializeWebSocket();
            socket?.emit(ToSocket,
                <String, dynamic>{'queue': ToSocket, 'data': callerid});
          } else {
            socket?.emit(ToSocket,
                <String, dynamic>{'queue': ToSocket, 'data': callerid});
          }
        }

        // Future.delayed(const Duration(seconds: 2), () {
        // if (ToMsg != 'กำลังยกเลิกคิว' &&
        //     ToMsg != 'กำลังจบคิว' &&
        //     ToMsg != 'กำลังพักคิว') {
        //   // Navigator.of(context).pop();
        // } else {
        //   // Navigator.of(context).pop();
        // }
        // });
      } else if (response.statusCode == 422) {
        ToMsg = "มีคิวกำลังเรียกอยู่ ปัจจุบัน";
        String queueNumber = "กรุณาโปรดเคลียคิวก่อน";
        SnackBarHelper.showErrorDialog(context, ToMsg, queueNumber);
      } else {
        ToMsg = "เกิดปัญหาทางเทคนิค";
        String queueNumber = "กรุณาโปรดแจ้งพนักงาน";
        SnackBarHelper.showErrorDialog(context, ToMsg, queueNumber);
      }
    } catch (e) {
      String ToMsg = "";
      // String queueNumber = '$e';
      String queueNumber = 'คิวนี้เปลี่ยนสถานะไปแล้ว';
      SnackBarHelper.showErrorDialog(context, ToMsg, queueNumber);
    }
  }

  Future<void> CallerQueue({
    required BuildContext context,
    required Map<String, dynamic> TicketKioskDetail,
    required Map<String, dynamic> Branch,
    required Map<String, dynamic> Kiosk,
    required Function(List<Map<String, dynamic>>) onCallerLoaded,
  }) async {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    try {
      await initializeWebSocket();

      var body = jsonEncode({
        'TicketKioskDetail': TicketKioskDetail,
        'Branch': Branch,
        'Kiosk': Kiosk,
      });

      final response = await http.post(
        Uri.parse(
            'https://somboonqms.andamandev.com/api/v1/queue-mobile/call-queue'),
        headers: <String, String>{
          HttpHeaders.contentTypeHeader: 'application/json; charset=UTF-8',
        },
        body: body,
      );

      if (response.statusCode == 200) {
        Map<String, dynamic> jsonData = jsonDecode(response.body);
        Map<String, dynamic> data = jsonData['data'];
        Map<String, dynamic> innerData = data['data'];
        Map<String, dynamic> queueData = innerData['queue'];
        Map<String, dynamic> callerData = innerData['caller'];
        String queueNo = queueData['queue_no'].toString();
        String callerid = callerData['caller_id'].toString();

        String ToMsg = "กำลังเรียกคิว";
        String queueNumber = queueNo;
        SnackBarHelper.showErrorDialog(context, ToMsg, queueNumber);

        if (socket == null || !socket!.connected) {
          await initializeWebSocket();
          socket?.emit(
              CALL, <String, dynamic>{'queue': 'call', 'data': callerid});
        } else {
          socket?.emit(
              CALL, <String, dynamic>{'queue': 'call', 'data': callerid});
        }

        // Future.delayed(const Duration(seconds: 2), () {
        // if (Navigator.canPop(context)) {
        // Navigator.of(context).pop();
        // }
        // });

        var bodyrender = jsonEncode({
          'RenderDisplay': response.body,
        });

        final responserender = await http.post(
          Uri.parse(renderDisplay),
          headers: <String, String>{
            HttpHeaders.contentTypeHeader: 'application/json; charset=UTF-8',
          },
          body: bodyrender,
        );

        if (innerData.containsKey('data') &&
            innerData['data'] is Map<String, dynamic>) {
          Map<String, dynamic> data = innerData['data'];
          List<Map<String, dynamic>> callerList = [
            data['caller'],
            data['callertrans'],
            data['queue']
          ];
          onCallerLoaded(callerList);
        } else {
          onCallerLoaded([]);
        }
      } else if (response.statusCode == 422) {
        String ToMsg = "มีคิวกำลังใช้งานอยู่";
        String queueNumber = "กรุณาเคลียคิว";
        SnackBarHelper.showErrorDialog(context, ToMsg, queueNumber);
      } else if (response.statusCode == 421) {
        String ToMsg = "ไม่มีรายการคิว";
        String queueNumber = "กรุณาโปรดเตรียมคิวใหม่";
        SnackBarHelper.showErrorDialog(context, ToMsg, queueNumber);
      } else {}
    } catch (e) {
      String ToMsg = "ERRORS";
      String queueNumber = "$e";
      SnackBarHelper.showErrorDialog(context, ToMsg, queueNumber);
    }
  }

  Future<void> CallQueue({
    required BuildContext context,
    required List<Map<String, dynamic>> SearchQueue,
  }) async {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    try {
      await initializeWebSocket();

      var body = jsonEncode({
        'SearchQueue': jsonEncode(SearchQueue),
      });

      final response = await http.post(
        Uri.parse(
            'https://somboonqms.andamandev.com/api/v1/queue-mobile/call-queue'),
        headers: <String, String>{
          HttpHeaders.contentTypeHeader: 'application/json; charset=UTF-8',
        },
        body: body,
      );

      if (response.statusCode == 200) {
        Map<String, dynamic> jsonData = jsonDecode(response.body);
        Map<String, dynamic> data = jsonData['data'];
        Map<String, dynamic> innerData = data['data'];
        Map<String, dynamic> queueData = innerData['queue'];
        Map<String, dynamic> callerData = innerData['caller'];
        String queueNo = queueData['queue_no'].toString();
        String callerid = callerData['caller_id'].toString();

        String ToMsg = "กำลังเรียกคิว";
        String queueNumber = queueNo;
        SnackBarHelper.showErrorDialog(context, ToMsg, queueNumber);

        if (socket == null || !socket!.connected) {
          await initializeWebSocket();
          socket?.emit(
              CALL, <String, dynamic>{'queue': 'call', 'data': callerid});
        } else {
          socket?.emit(
              CALL, <String, dynamic>{'queue': 'call', 'data': callerid});
        }

        // Future.delayed(const Duration(seconds: 1), () {
        // if (Navigator.canPop(context)) {
        // Navigator.of(context).pop();
        // }
        // });
      } else if (response.statusCode == 422) {
        String ToMsg = "มีคิวกำลังใช้งานอยู่";
        String queueNumber = "กรุณาเคลียคิวให้เสร็จสิ้น";
        SnackBarHelper.showErrorDialog(context, ToMsg, queueNumber);
        // Future.delayed(const Duration(seconds: 1), () {
        //   if (Navigator.canPop(context)) {
        //     Navigator.of(context).pop();
        //   }
        // });
      }
    } catch (e) {
      String ToMsg = "ERRORS";
      String queueNumber = "$e";
      SnackBarHelper.showErrorDialog(context, ToMsg, queueNumber);
    }
  }
}
