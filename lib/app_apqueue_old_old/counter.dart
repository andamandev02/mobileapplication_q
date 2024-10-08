import 'package:flutter/material.dart';
import 'Tabs/tabs.dart';
import 'api/brach/brachlist.dart';

class CounterListS extends StatefulWidget {
  final Map<String, dynamic> branches;
  const CounterListS({super.key, required this.branches});

  @override
  State<CounterListS> createState() => _CounterListSState();
}

class _CounterListSState extends State<CounterListS> {
  late List<Map<String, dynamic>> _counters = [];

  @override
  void initState() {
    super.initState();
    fetchService(widget.branches['branch_id']);
  }

  Future<void> fetchService(String branchid) async {
    await ClassBranch.counter(
      context: context,
      branchid: branchid,
      onTicketKioskLoaded: (loadedKiosk) {
        setState(() {
          _counters = loadedKiosk;
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // ใช้ MediaQuery เพื่อคำนวณขนาดตามหน้าจอ
    final size = MediaQuery.of(context).size;
    final buttonHeight = size.height * 0.06; // ปรับขนาดปุ่มตามความสูงของหน้าจอ
    final iconSize = size.height * 0.05; // ปรับขนาดไอคอนตามความสูงของหน้าจอ
    final fontSize = size.height * 0.03; // ปรับขนาดฟอนต์ตามความสูงของหน้าจอ

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 0, 67, 122),
      appBar: AppBar(
        title: Text(
          'Select Counter',
          style: TextStyle(
            fontSize: fontSize,
            color: Colors.white,
          ),
        ),
        iconTheme: const IconThemeData(
          color: Colors.white,
        ),
        backgroundColor: const Color.fromARGB(255, 0, 67, 122),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final double buttonWidth =
                constraints.maxWidth; // ใช้ความกว้างหน้าจอ

            return ListView.builder(
              itemCount: _counters.length,
              itemBuilder: (context, index) {
                final branchName = _counters[index]['t_kiosk_name'];

                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: SizedBox(
                    width: buttonWidth,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => TabS(
                                branches: widget.branches,
                                counters: _counters[index]),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        foregroundColor: const Color.fromRGBO(9, 159, 175, 1.0),
                        backgroundColor:
                            const Color.fromARGB(255, 255, 255, 255),
                        padding: EdgeInsets.symmetric(
                          vertical: buttonHeight / 2,
                        ), // ปรับ padding ตามขนาดหน้าจอ
                        minimumSize: Size(
                            buttonWidth, buttonHeight), // ขนาดปุ่มตามหน้าจอ
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(50),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const SizedBox(
                            width: 40, // เพิ่มช่องว่างทางซ้าย
                          ),
                          Expanded(
                            child: Text(
                              branchName,
                              style: TextStyle(
                                fontSize: fontSize, // ปรับขนาดฟอนต์ตามหน้าจอ
                              ),
                            ),
                          ),
                          Icon(
                            Icons.arrow_forward,
                            size: iconSize, // ปรับขนาดไอคอนตามหน้าจอ
                            color: const Color.fromRGBO(9, 159, 175, 1.0),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
