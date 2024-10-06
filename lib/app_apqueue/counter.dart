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
    return Scaffold(
      backgroundColor: const Color.fromRGBO(9, 159, 175, 1.0),
      appBar: AppBar(
        title: const Text(
          'เลือกจุดบริการ',
          style: TextStyle(
            fontSize: 25.0,
            color: Colors.white,
          ),
        ),
        iconTheme: const IconThemeData(
          color: Colors.white,
        ),
        backgroundColor: const Color.fromRGBO(9, 159, 175, 1.0),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final double buttonWidth = constraints.maxWidth;
            const double buttonHeight = 50;

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
                        padding: const EdgeInsets.symmetric(
                            vertical: buttonHeight / 2),
                        minimumSize: Size(buttonWidth, buttonHeight),
                        // side: const BorderSide(
                        //   color: Colors.black,
                        //   width: 2,
                        // ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(50),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment
                            .spaceBetween, // จัดตำแหน่งให้ข้อความชิดซ้ายและไอคอนชิดขวา
                        children: [
                          const SizedBox(
                            width: 40,
                          ),
                          Expanded(
                            child: Text(
                              branchName,
                              style: const TextStyle(
                                fontSize: 30.0,
                              ),
                            ),
                          ),
                          const Icon(
                            Icons.arrow_forward,
                            size: 50.0, // ขนาดของไอคอน
                            color:
                                Color.fromRGBO(9, 159, 175, 1.0), // สีของไอคอน
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
