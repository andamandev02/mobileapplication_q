import 'package:flutter/material.dart';
import 'TabData.dart';
import 'tabs1.dart';
import 'tabs2.dart';
import 'tabs3.dart';
import 'tabs4.dart';
import '../api/brach/brachlist.dart';
import '../api/queue/crud.dart';
import '../api/queue/queuelist.dart';
import '../api/url.dart';

class TabS extends StatefulWidget {
  final Map<String, dynamic> branches;
  final Map<String, dynamic> counters;

  const TabS({
    super.key,
    required this.branches,
    required this.counters,
  });

  @override
  State<TabS> createState() => _TabSState();
}

class _TabSState extends State<TabS> with SingleTickerProviderStateMixin {
  ValueNotifier<List<Map<String, dynamic>>> filteredQueuesANotifier =
      ValueNotifier<List<Map<String, dynamic>>>([]);
  ValueNotifier<List<Map<String, dynamic>>> filteredQueues3Notifier =
      ValueNotifier<List<Map<String, dynamic>>>([]);
  ValueNotifier<List<Map<String, dynamic>>> filteredQueues1Notifier =
      ValueNotifier<List<Map<String, dynamic>>>([]);

  List<Map<String, dynamic>> CountersDetail = [];
  List<Map<String, dynamic>> queues = [];
  List<Map<String, dynamic>> filteredQueues1 = [];
  List<Map<String, dynamic>> filteredQueues3 = [];
  List<Map<String, dynamic>> filteredQueuesA = [];
  late TabController _tabController;

  String branchName = '';
  String branchNameC = '';
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    fetchSearchQueue();
    fetchCountersDetail(widget.branches['branch_id']);
  }

  Future<void> fetchSearchQueue() async {
    await ClassQueue.queuelist(
      context: context,
      branchid: widget.branches['branch_id'],
      onSearchQueueLoaded: (loadedSearchQueue) {
        if (mounted) {
          setState(() {
            queues = loadedSearchQueue;
            filteredQueues1 = queues
                .where((queue) => queue['service_status_id'] == '1')
                .toList();
            filteredQueues3 = queues
                .where((queue) => queue['service_status_id'] == '3')
                .toList();
            filteredQueuesA = queues;
          });
        }
      },
    );
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> fetchCountersDetail(String branchid) async {
    await ClassBranch.counterdetail(
      context: context,
      branchid: branchid,
      onTicketKioskDetailLoaded: (loadedTicketKioskDetail) {
        if (mounted) {
          setState(() {
            CountersDetail = loadedTicketKioskDetail;
            if (CountersDetail.isNotEmpty) {
              var firstItem = CountersDetail[0];
              if (firstItem is Map<String, dynamic>) {
                branchName =
                    firstItem['branch_name'] ?? 'Branch name not found';
                branchNameC =
                    firstItem['t_kiosk_name'] ?? 'Branch name not found';
              }
            }
          });
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final buttonHeight = size.height * 0.06;
    final iconSize = size.height * 0.05;
    final fontSize = size.height * 0.02;

    return DefaultTabController(
      length: 4,
      child: TabData(
        branches: widget.branches,
        counters: widget.counters,
        countersd: CountersDetail,
        child: Scaffold(
          backgroundColor: const Color.fromARGB(255, 0, 67, 122),
          appBar: AppBar(
            title: Text(
              'Branch ' + branchName + '-' + branchNameC,
              style: TextStyle(
                fontSize: fontSize,
                color: Colors.white,
              ),
            ),
            iconTheme: const IconThemeData(
              color: Colors.white,
            ),
            backgroundColor: const Color.fromARGB(255, 0, 67, 122),
            actions: [
              IconButton(
                icon: const Icon(Icons.delete),
                onPressed: () {
                  _showClearQueue(context);
                },
              ),
            ],
            bottom: TabBar(
              controller: _tabController,
              // isScrollable: true,
              labelStyle: TextStyle(
                fontSize: fontSize,
                fontWeight: FontWeight.bold,
              ),
              unselectedLabelStyle: TextStyle(
                fontSize: fontSize,
                fontWeight: FontWeight.normal,
              ),
              tabs: [
                ValueListenableBuilder<List<Map<String, dynamic>>>(
                  valueListenable: filteredQueuesANotifier,
                  builder: (context, filteredQueuesA, child) {
                    return Tab(
                      child: Text(
                        'Call',
                        style: TextStyle(
                          fontSize: fontSize,
                          color: Colors.white,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    );
                  },
                ),
                ValueListenableBuilder<List<Map<String, dynamic>>>(
                  valueListenable: filteredQueues1Notifier,
                  builder: (context, filteredQueues1, child) {
                    return Tab(
                      child: Text(
                        'Wait (${filteredQueues1.length})',
                        style: TextStyle(
                          fontSize: fontSize,
                          color: Colors.white,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    );
                  },
                ),
                ValueListenableBuilder<List<Map<String, dynamic>>>(
                  valueListenable: filteredQueues3Notifier,
                  builder: (context, filteredQueues3, child) {
                    return Tab(
                      child: Text(
                        'Hold (${filteredQueues3.length})',
                        style: TextStyle(
                          fontSize: fontSize,
                          color: Colors.white,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    );
                  },
                ),
                ValueListenableBuilder<List<Map<String, dynamic>>>(
                  valueListenable: filteredQueuesANotifier,
                  builder: (context, filteredQueuesA, child) {
                    return Tab(
                      child: Text(
                        'Total (${filteredQueuesA.length})',
                        style: TextStyle(
                          fontSize: fontSize,
                          color: Colors.white,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          body: TabBarView(
            controller: _tabController,
            children: [
              Tab1(
                  filteredQueues1Notifier: filteredQueues1Notifier,
                  filteredQueues3Notifier: filteredQueues3Notifier,
                  filteredQueuesANotifier: filteredQueuesANotifier),
              Tab2(
                  tabController: _tabController,
                  filteredQueues1Notifier: filteredQueues1Notifier,
                  filteredQueues3Notifier: filteredQueues3Notifier,
                  filteredQueuesANotifier: filteredQueuesANotifier),
              Tab3(
                  tabController: _tabController,
                  filteredQueues1Notifier: filteredQueues1Notifier,
                  filteredQueues3Notifier: filteredQueues3Notifier,
                  filteredQueuesANotifier: filteredQueuesANotifier),
              Tab4(
                  tabController: _tabController,
                  filteredQueues1Notifier: filteredQueues1Notifier,
                  filteredQueues3Notifier: filteredQueues3Notifier,
                  filteredQueuesANotifier: filteredQueuesANotifier),
            ],
          ),
        ),
      ),
    );
  }

  void _showClearQueue(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final buttonHeight = size.height * 0.05; // 5% ของความสูงหน้าจอ
    final fontSize = size.height * 0.02;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            children: [
              Icon(
                Icons.warning,
                color: Colors.orange,
                size: fontSize * 1.5, // เพิ่มขนาดไอคอนให้เหมาะสมกับฟอนต์
              ),
              SizedBox(
                  width: size.width * 0.02), // ปรับขนาดให้สัมพันธ์กับหน้าจอ
              Flexible(
                // ใช้ Flexible เพื่อปรับขนาดข้อความให้เหมาะสมกับพื้นที่ที่มี
                child: Text(
                  'ยืนยันการลบ',
                  style: TextStyle(
                    fontSize: fontSize,
                  ),
                ),
              ),
            ],
          ),
          content: Text(
            'คุณแน่ใจว่าต้องการลบคิวทั้งหมดหรือไม่?\n(ถ้าลบแล้วจะไม่สามารถนำกลับมาได้อีก)',
            style: TextStyle(
              fontSize: fontSize,
            ),
            textAlign: TextAlign.center,
          ),
          contentPadding: EdgeInsets.symmetric(
            vertical: size.height * 0.02,
            horizontal: size.width * 0.0001,
          ),
          actions: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: const Color.fromARGB(255, 255, 0, 0),
                      padding:
                          EdgeInsets.symmetric(vertical: size.height * 0.02),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(
                      'ปิด|CLOSE',
                      style: TextStyle(
                        fontSize: fontSize,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: size.width * 0.01), // ปรับระยะห่างตามขนาดหน้าจอ
                Expanded(
                  // ใช้ Expanded เพื่อทำให้ปุ่มมีขนาดเท่ากัน
                  child: ElevatedButton(
                    onPressed: () async {
                      await ClassCQueue().clearQueue(
                        context: context,
                        branchid: widget.branches['branch_id'],
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: const Color.fromRGBO(9, 159, 175, 1.0),
                      padding:
                          EdgeInsets.symmetric(vertical: size.height * 0.02),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(
                      'ยืนยัน|SUBMIT',
                      style: TextStyle(
                        fontSize: fontSize,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}
