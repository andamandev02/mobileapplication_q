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

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(
            width: 1.0, color: const Color.fromARGB(255, 255, 255, 255)),
        borderRadius: BorderRadius.circular(0),
      ),
      // margin: const EdgeInsets.fromLTRB(0, 0, 0, 100),
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "เลขคิวที่จบบริการ : ${widget.T2OK.isNotEmpty ? widget.T2OK.first['queue_no'] ?? 'N/A' : 'No Data'}",
                style: const TextStyle(
                  fontSize: 35,
                  fontWeight: FontWeight.bold,
                  color: Color.fromRGBO(9, 159, 175, 1.0),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              ...widget.reason.map((reason) {
                final bool isGreen = reason['reason_id'] == '1';
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4.0),
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
                                  },
                                ),
                              ),
                            );
                          },
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.black,
                      backgroundColor: isGreen
                          ? const Color.fromRGBO(9, 159, 175, 1.0)
                          : const Color.fromARGB(255, 219, 118, 2),
                      minimumSize: Size(screenWidth * 0.8, screenHeight * 0.10),
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
                onPressed: _isLoading // Disable button if loading
                    ? null
                    : () async {
                        setState(() {
                          _isLoading = true; // Show loading indicator
                        });

                        await Future.delayed(const Duration(seconds: 2));

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
    );
  }
}
