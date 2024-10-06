import 'package:flutter/material.dart';
import 'queue/crud.dart';

Future<void> showLoadingDialog(BuildContext context, String txt) {
  return showDialog(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return Dialog(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              const CircularProgressIndicator(),
              Padding(
                padding: const EdgeInsets.only(left: 10),
                child: Text(txt),
              )
            ],
          ),
        ),
      );
    },
  );
}

String apiBaseURL = '';

// รายการสาขาทั้งหมด
String getApiBaseUrlBranchList() {
  return '$apiBaseURL/api/v1/queue-mobile/branch-list';
}

// รายการจุดออกบัตรคิว หลังเลือก สาขา
String getApiBaseUrlTicketKioskList() {
  return '$apiBaseURL/api/v1/queue-mobile/ticket-kiosk-list';
}

String getApiBaseUrlQueueFirstTicketKioskList() {
  return '$apiBaseURL/api/v1/queue-mobile/queue-first-ticket-kiosk-detail';
}

String getApiBaseUrlQueueCountFirstTicketKioskList() {
  return '$apiBaseURL/api/v1/queue-mobile/queue-count-first-ticket-kiosk-detail';
}

// รายการจบคิว
String getApiBaseUrlEndQueueList() {
  return '$apiBaseURL/api/v1/queue-mobile/reason-all';
}

// รายละเอียดข้อมูลจุดออกบัตรคิว
String getApiBaseUrlTicketKioskDetail() {
  return '$apiBaseURL/api/v1/queue-mobile/ticket-kiosk-detail';
}

// สรา้งคิว
String getApiBaseUrlCreateQueue() {
  return '$apiBaseURL/api/v1/queue-mobile/create-queue';
}

// ดูรายการคิว
String getApiBaseUrlSearchQueue() {
  return '$apiBaseURL/api/v1/queue-mobile/search-queue';
}

// Call Queue
String getApiBaseUrlCallQueue() {
  return '$apiBaseURL/api/v1/queue-mobile/call-queue';
}

// Check Queue
String getApiBaseUrlCallerQueue() {
  return '$apiBaseURL/api/v1/queue-mobile/caller-queue';
}

// Check รายการ คอลทั้งหมดที่มี
String getApiBaseUrlCallerQueueAll() {
  return '$apiBaseURL/api/v1/queue-mobile/caller-queue-all';
}

// Update Queue
String getApiBaseUrlUpdateQueue() {
  return '$apiBaseURL/api/v1/queue-mobile/update-queue';
}

// recall
String getApiBaseUrlRecallQueue() {
  return '$apiBaseURL/api/v1/queue-mobile/recall-queue';
}

String getApiBaseUrlRenderDisplay() {
  return '$apiBaseURL/api/v1/queue-mobile/render-display';
}

final String branchListUrl = getApiBaseUrlBranchList();
final String ticketKioskListUrl = getApiBaseUrlTicketKioskList();
final String queuefirstticketKioskDetailUrl =
    getApiBaseUrlQueueFirstTicketKioskList();
final String queueCountfirstticketKioskDetailUrl =
    getApiBaseUrlQueueCountFirstTicketKioskList();
final String endQueueReasonlistUrl = getApiBaseUrlEndQueueList();
final String ticketKioskDetailUrl = getApiBaseUrlTicketKioskDetail();
final String createQueueUrl = getApiBaseUrlCreateQueue();
final String searchQueueUrl = getApiBaseUrlSearchQueue();
final String callQueueUrl = getApiBaseUrlCallQueue();
final String callerQueueUrl = getApiBaseUrlCallerQueue();
final String callerQueueAllUrl = getApiBaseUrlCallerQueueAll();
final String updateQueueUrl = getApiBaseUrlUpdateQueue();
final String recallQueueUrl = getApiBaseUrlRecallQueue();

final String renderDisplay = getApiBaseUrlRenderDisplay();

const String logoUrl =
    'https://firebasestorage.googleapis.com/v0/b/sys1-319107.appspot.com/o/uploads%2Fsys-logo.png?alt=media&token=7839089c-ef38-40d5-b93f-40f89dd19aee';
const String demoToken =
    'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VyIjp7ImlkIjoyLCJ1c2VybmFtZSI6InNtYXJ0Y2FyZSIsIm5hbWUiOiJTbWFydCBDYXJlIn0sIm5hbWUiOiJTbWFydCBDYXJlIiwianRpIjoyLCJpYXQiOjE2MzQ4MDg3OTgsIm5iZiI6MTYzNDgwODc5OCwiZXhwIjoxNjM0ODk1MTk4LCJpc3MiOiJodHRwczovL3d3dy5zeXNzY3JhcHF1ZXVlcy5jb20ifQ.lXkiffwKVvEdReex1LcYh2in625gGGy40zTbD9JLJYY';

const String GITHUB_CLIENT_ID = '8085ede7fb7b993b51df';
const String GITHUB_CLIENT_SECRET = 'c92d7fd359955d8be7f5c21ccc80f63eeb7c5b5d';
const String GITHUB_CALLBACK_URL =
    'https://sys1-319107.firebaseapp.com/__/auth/handler';

const String SOCKET_IO_HOST = 'https://somboonqms.andamandev.com';
// const String SOCKET_IO_HOST = 'https://540a-27-55-95-11.ngrok.io';
const String SOCKET_IO_PATH = '/nodesomboonqms/socket.io';

const String LONGDO_MAP_KEY = 'ed50eae671bfb054d5d4ef5126ebfbfa';

String connectionStatus = "Disconnected";
String PCSC_INITIAL = "PCSC_INITIAL";
String PCSC_CLOSE = "PCSC_CLOSE";

String DEVICE_WAITING = "DEVICE_WAITING";
String DEVICE_CONNECTED = "DEVICE_CONNECTED";
String DEVICE_ERROR = "DEVICE_ERROR";
String DEVICE_DISCONNECTED = "DEVICE_DISCONNECTED";

String CARD_INSERTED = "CARD_INSERTED";
String CARD_REMOVED = "CARD_REMOVED";

String READING_INIT = "READING_INIT";
String READING_START = "READING_START";
String READING_PROGRESS = "READING_PROGRESS";
String READING_COMPLETE = "READING_COMPLETE";
String READING_FAIL = "READING_FAIL";
String REGISTER = "queue:register";
String CALL = "queue:call";
String HOLD = "queue:hold";
String FINISH = "queue:finish";
String START = "queue:start";
String TRANSFER = "queue:transfer";

String SETTING_DISPLAY = "setting:display";
String SETTING_COUNTER = "setting:counter";
String SETTING_BRANCH_SERVICE = "setting:branch-service";
String SETTING_SERVICE = "setting:service";
String SETTING_KIOSK = "setting:kiosk";
String CHECK_FOR_UPDATE = "check-for-update";

String DISPLAY_PLAYING = "display:playing";
String DISPLAY_ENDED = "display:ended";
String DISPLAY_UPDATE_STATUS = "display:update-status";

// class SnackBarHelper {
//   static void showErrorSnackBar(
//       BuildContext context, String message, String queueNumber) {
//     final screenWidth = MediaQuery.of(context).size.width;
//     final screenHeight = MediaQuery.of(context).size.height;

//     showDialog(
//       context: context,
//       barrierDismissible: false,
//       builder: (BuildContext context) {
//         return Dialog(
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(20.0),
//           ),
//           child: Container(
//             width: screenWidth * 0.8,
//             padding: const EdgeInsets.all(20.0),
//             child: Column(
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 Icon(
//                   Icons.error_outline,
//                   color: Colors.red,
//                   size: screenWidth * 0.2,
//                 ),
//                 const SizedBox(height: 8),
//                 Text(
//                   message,
//                   textAlign: TextAlign.center,
//                   style: TextStyle(
//                     fontSize: screenWidth * 0.07,
//                     color: const Color.fromRGBO(9, 159, 175, 1.0),
//                     fontWeight: FontWeight.bold,
//                     overflow: TextOverflow.ellipsis,
//                   ),
//                 ),
//                 const SizedBox(height: 8),
//                 Text(
//                   queueNumber,
//                   textAlign: TextAlign.center,
//                   style: TextStyle(
//                     fontSize: screenWidth * 0.07,
//                     color: const Color.fromRGBO(9, 159, 175, 1.0),
//                     fontWeight: FontWeight.bold,
//                     overflow: TextOverflow.ellipsis,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         );
//       },
//     );
//   }

//   static void showSaveSnackBar(
//     BuildContext context,
//     List<Map<String, dynamic>> T2OK,
//     List<Map<String, dynamic>> reasonList,
//   ) {
//     final screenWidth = MediaQuery.of(context).size.width;
//     final screenHeight = MediaQuery.of(context).size.height;

//     showDialog(
//       context: context,
//       barrierDismissible: false,
//       builder: (BuildContext context) {
//         return Dialog(
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(20.0),
//           ),
//           child: Container(
//             width: screenWidth * 1.0,
//             height: screenHeight * 0.7, // ปรับความสูงตามต้องการ
//             padding: const EdgeInsets.symmetric(vertical: 20.0),
//             child: Column(
//               mainAxisAlignment: MainAxisAlignment.center,
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 Text(
//                   "Queue No: ${T2OK.isNotEmpty ? T2OK.first['queue_no'] ?? 'N/A' : 'No Data'}",
//                   style: const TextStyle(
//                     fontSize: 50,
//                     fontWeight: FontWeight.bold,
//                     color: Color.fromRGBO(9, 159, 175, 1.0),
//                   ),
//                   textAlign: TextAlign.center,
//                 ),
//                 const SizedBox(height: 8),
//                 ...reasonList.map((reason) {
//                   final bool isGreen = reason['reason_id'] == '1';
//                   return Padding(
//                     padding: const EdgeInsets.symmetric(vertical: 4.0),
//                     child: ElevatedButton(
//                       onPressed: () async {
//                         var ReasonNote = '';
//                         if (reason['reason_id'] == '1') {
//                           ReasonNote = 'Finishing';
//                         } else {
//                           ReasonNote = 'Ending';
//                         }
//                         await ClassCQueue().UpdateQueue(
//                           context: context,
//                           SearchQueue: T2OK,
//                           StatusQueue: ReasonNote,
//                           StatusQueueNote: reason['reason_id'],
//                         );

//                         Future.delayed(const Duration(seconds: 1), () {
//                           Navigator.of(context).pop();
//                           Navigator.of(context).pop();
//                         });
//                       },
//                       style: ElevatedButton.styleFrom(
//                         foregroundColor: Colors.black,
//                         backgroundColor: isGreen
//                             ? const Color.fromRGBO(9, 159, 175, 1.0)
//                             : const Color.fromARGB(255, 219, 118, 2),
//                         minimumSize:
//                             Size(screenWidth * 0.8, screenHeight * 0.10),
//                         shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(12.0),
//                         ),
//                         padding: EdgeInsets.symmetric(horizontal: 10),
//                       ),
//                       child: Text(
//                         reason['reason_id'] == '1'
//                             ? reason['reson_name'] ?? ''
//                             : 'ยกเลิก : ${reason['reson_name'] ?? ''}',
//                         style: TextStyle(
//                           color: Colors.white,
//                           fontSize: screenWidth * 0.05,
//                         ),
//                       ),
//                     ),
//                   );
//                 }).toList(),
//                 const SizedBox(height: 8),
//                 ElevatedButton(
//                   onPressed: () {
//                     Navigator.of(context).pop();
//                   },
//                   style: ElevatedButton.styleFrom(
//                     foregroundColor: Colors.black,
//                     backgroundColor: const Color.fromARGB(255, 255, 0, 0),
//                     minimumSize: Size(screenWidth * 0.8, screenHeight * 0.10),
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(12.0),
//                     ),
//                     padding: EdgeInsets.symmetric(horizontal: 10),
//                   ),
//                   child: Text(
//                     'ปิดหน้าต่าง',
//                     style: TextStyle(
//                       color: Colors.white,
//                       fontSize: screenWidth * 0.05,
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         );
//       },
//     );
//   }
// }

class SnackBarHelper {
  static void showErrorDialog(
      BuildContext context, String message, String queueNumber) {
    showDialog(
      context: context,
      barrierDismissible: false, // ปิด dialog โดยการคลิกนอก dialog
      builder: (BuildContext context) {
        return AlertDialog(
          content: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(
                width: 1.0,
                color: const Color.fromARGB(255, 255, 255, 255),
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            width: MediaQuery.of(context).size.width * 0.8, // ขนาด dialog
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.error_outline,
                  color: Colors.red,
                  size: MediaQuery.of(context).size.width * 0.2,
                ),
                SizedBox(height: 8),
                Text(
                  message,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: MediaQuery.of(context).size.width * 0.07,
                    color: Color.fromRGBO(9, 159, 175, 1.0),
                    fontWeight: FontWeight.bold,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  queueNumber,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: MediaQuery.of(context).size.width * 0.05,
                    color: Color.fromRGBO(9, 159, 175, 1.0),
                    fontWeight: FontWeight.bold,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  static void showErrorSnackBar(
      BuildContext context, String message, String queueNumber) {
    final snackBar = SnackBar(
      content: Container(
        decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(
                width: 1.0, color: const Color.fromARGB(255, 255, 255, 255)),
            borderRadius: BorderRadius.circular(20)),
        margin: EdgeInsets.fromLTRB(0, 0, 0, 300),
        child: Align(
          alignment: Alignment.center,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.error_outline,
                color: Colors.red,
                size: MediaQuery.of(context).size.width * 0.2,
              ),
              SizedBox(height: 8),
              Text(
                message,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: MediaQuery.of(context).size.width * 0.07,
                  color: Color.fromRGBO(9, 159, 175, 1.0),
                  fontWeight: FontWeight.bold,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              SizedBox(height: 8),
              Text(
                queueNumber,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: MediaQuery.of(context).size.width * 0.05,
                  color: Color.fromRGBO(9, 159, 175, 1.0),
                  fontWeight: FontWeight.bold,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
      backgroundColor: Colors.transparent,
      elevation: 2500,
      duration: const Duration(seconds: 2),
      behavior: SnackBarBehavior.floating,
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  static void showSaveSnackBar(
    BuildContext context,
    List<Map<String, dynamic>> T2OK,
    List<Map<String, dynamic>> reasonList,
  ) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    final snackBar = SnackBar(
      content: Container(
        decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(
                width: 1.0, color: const Color.fromARGB(255, 255, 255, 255)),
            borderRadius: BorderRadius.circular(20)),
        margin: const EdgeInsets.fromLTRB(0, 0, 0, 100),
        child: Center(
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 20.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "เลขคิวที่จบบริการ : ${T2OK.isNotEmpty ? T2OK.first['queue_no'] ?? 'N/A' : 'No Data'}",
                  style: const TextStyle(
                    fontSize: 35,
                    fontWeight: FontWeight.bold,
                    color: Color.fromRGBO(9, 159, 175, 1.0),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                ...reasonList.map((reason) {
                  final bool isGreen = reason['reason_id'] == '1';
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4.0),
                    child: ElevatedButton(
                      onPressed: () async {
                        var ReasonNote = '';
                        if (reason['reason_id'] == '1') {
                          ReasonNote = 'Finishing';
                        } else {
                          ReasonNote = 'Ending';
                        }
                        await ClassCQueue().UpdateQueue(
                          context: context,
                          SearchQueue: T2OK,
                          StatusQueue: ReasonNote,
                          StatusQueueNote: reason['reason_id'],
                        );
                        ScaffoldMessenger.of(context).hideCurrentSnackBar();
                      },
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.black,
                        backgroundColor: isGreen
                            ? const Color.fromRGBO(9, 159, 175, 1.0)
                            : const Color.fromARGB(255, 219, 118, 2),
                        minimumSize:
                            Size(screenWidth * 0.8, screenHeight * 0.10),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                        padding: EdgeInsets.symmetric(horizontal: 10),
                      ),
                      child: Text(
                        reason['reason_id'] == '1'
                            ? reason['reson_name'] ?? ''
                            : 'ยกเลิก : ${reason['reson_name'] ?? ''}',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: screenWidth * 0.05,
                        ),
                      ),
                    ),
                  );
                }).toList(),
                const SizedBox(height: 8),
                ElevatedButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).hideCurrentSnackBar();
                  },
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.black,
                    backgroundColor: const Color.fromARGB(255, 255, 0, 0),
                    minimumSize: Size(screenWidth * 0.8, screenHeight * 0.10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                    padding: EdgeInsets.symmetric(horizontal: 10),
                  ),
                  child: Text(
                    'ปิดหน้าต่าง',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: screenWidth * 0.05,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      backgroundColor: Colors.transparent,
      elevation: 2500,
      behavior: SnackBarBehavior.floating,
      duration: const Duration(days: 365),
      // backgroundColor: Colors.white,
      // behavior: SnackBarBehavior.floating,
      // margin: const EdgeInsets.only(bottom: 350.0),
      // dismissDirection: DismissDirection.none,
      // shape: RoundedRectangleBorder(
      //   borderRadius: BorderRadius.circular(20.0),
      // ),
      // duration: Duration(days: 365),
      // width: MediaQuery.of(context).size.width * 0.8,
    );

    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }
}
