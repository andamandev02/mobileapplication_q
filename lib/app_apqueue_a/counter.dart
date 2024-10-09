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
    final size = MediaQuery.of(context).size;
    final buttonHeight = size.height * 0.06;
    final iconSize = size.height * 0.05;
    final fontSize = size.height * 0.02;

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 0, 67, 122),
      appBar: AppBar(
        title: Text(
          'เลือกเค้าเตอร์ | Select Counter',
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
            final double buttonWidth = constraints.maxWidth;
            final double buttonHeight = size.height * 0.08;
            final double iconSize = size.height * 0.03;
            final double fontSize = size.height * 0.02;

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
                        foregroundColor: const Color.fromARGB(255, 0, 67, 122),
                        backgroundColor:
                            const Color.fromARGB(255, 255, 255, 255),
                        padding: const EdgeInsets.symmetric(
                          vertical: 12.0,
                        ),
                        minimumSize: Size(buttonWidth, buttonHeight),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(50),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const SizedBox(
                            width: 10,
                          ),
                          Expanded(
                            child: Text(
                              branchName,
                              style: TextStyle(
                                fontSize: fontSize,
                              ),
                            ),
                          ),
                          Icon(
                            Icons.arrow_forward,
                            size: iconSize,
                            color: const Color.fromARGB(255, 0, 67, 122),
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
