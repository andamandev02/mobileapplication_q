import 'package:flutter/material.dart';
import 'api/queue/crud.dart';
import 'loadingsreen.dart';

class CancelScreen extends StatefulWidget {
  final List<Map<String, dynamic>> reason;
  final List<Map<String, dynamic>> T2OK;

  const CancelScreen({
    super.key,
    required this.T2OK,
    required this.reason,
  });

  @override
  State<CancelScreen> createState() => _CancelScreenState();
}

class _CancelScreenState extends State<CancelScreen> {
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    // รับขนาดหน้าจอ
    final size = MediaQuery.of(context).size;
    final buttonHeight = size.height * 0.06;
    final buttonWidth = size.width * 0.2;
    final fontSize = size.height * 0.02;
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(
            width: 1.0, color: const Color.fromARGB(255, 255, 255, 255)),
        borderRadius: BorderRadius.circular(0),
      ),
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "Queue Number : ${widget.T2OK.isNotEmpty ? widget.T2OK.first['queue_no'] ?? 'N/A' : 'No Data'}",
                style: TextStyle(
                  fontSize: fontSize * 1.5,
                  fontWeight: FontWeight.bold,
                  color: const Color.fromARGB(255, 0, 67, 122),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              ...widget.reason.map((reason) {
                final bool isGreen = reason['reason_id'] == '1';
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 3.0),
                  child: ElevatedButton(
                    onPressed: _isLoading // Disable button if loading
                        ? null
                        : () async {
                            setState(() {
                              _isLoading = true;
                            });

                            var ReasonNote = (reason['reason_id'] == '1')
                                ? 'Finishing'
                                : 'Ending';

                            await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => LoadingScreen(
                                  onComplete: () async {
                                    await ClassCQueue().UpdateQueue(
                                      context: context,
                                      SearchQueue: widget.T2OK,
                                      StatusQueue: ReasonNote,
                                      StatusQueueNote: reason['reason_id'],
                                    );

                                    await Future.delayed(
                                        const Duration(seconds: 2));
                                    Navigator.of(context).pop();
                                    Navigator.of(context).pop();
                                  },
                                ),
                              ),
                            );
                          },
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.black,
                      backgroundColor: isGreen
                          ? const Color.fromARGB(255, 0, 67, 122)
                          : const Color.fromARGB(255, 219, 118, 2),
                      minimumSize: Size(screenWidth * 0.8, screenHeight * 0.10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                      padding: EdgeInsets.symmetric(horizontal: 10),
                    ),
                    child: Text(
                      reason['reason_id'] == '1'
                          ? (reason['reson_name'] ?? '')
                              .replaceAll('|', '\n') // แทนที่ | ด้วย \n
                          : 'ยกเลิก : ${(reason['reson_name'] ?? '').replaceAll('|', '\n')}', // แทนที่ | ด้วย \n
                      textAlign: TextAlign.center, // จัดให้อยู่ตรงกลาง
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: fontSize * 1.4,
                      ),
                    ),
                  ),
                );
              }).toList(),
              const SizedBox(height: 3),
              ElevatedButton(
                onPressed: () async {
                  setState(() {
                    _isLoading = true; // Show loading indicator
                  });

                  // await Future.delayed(const Duration(seconds: 2));

                  // Close the screen after showing the Snackbar
                  Navigator.of(context).pop();
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
                  'ปิดหน้าต่าง | Close',
                  style:
                      TextStyle(color: Colors.white, fontSize: fontSize * 1.4),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
