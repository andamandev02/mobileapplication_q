import 'dart:async';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '../loadingsreen.dart';
import 'TabData.dart';
import '../api/queue/crud.dart';
import '../api/queue/queuelist.dart';
import '../api/time.dart';
import '../api/url.dart';
import '../print/reprint.dart';
import '../print/reprinting_new.dart';
import '../setting/setting.dart';
import '../api/brach/brachlist.dart';

enum QueueStatus { waiting, called, paused, finished, ended, clear }

class Tab4 extends StatefulWidget {
  const Tab4({
    super.key,
    required this.tabController,
    required this.filteredQueues1Notifier,
    required this.filteredQueues3Notifier,
    required this.filteredQueuesANotifier,
  });

  @override
  final TabController tabController;
  _Tab4State createState() => _Tab4State();
  final ValueNotifier<List<Map<String, dynamic>>> filteredQueues1Notifier;
  final ValueNotifier<List<Map<String, dynamic>>> filteredQueues3Notifier;
  final ValueNotifier<List<Map<String, dynamic>>> filteredQueuesANotifier;
}

class _Tab4State extends State<Tab4> {
  late List<Map<String, dynamic>> queues = [];
  List<Map<String, dynamic>> filteredQueues1 = [];
  List<Map<String, dynamic>> filteredQueues3 = [];
  List<Map<String, dynamic>> filteredQueuesA = [];

  final TextEditingController _controller = TextEditingController();

  String queueNo = '';

  QueueStatus selectedStatus = QueueStatus.waiting;
  String selectedFilter = '';

  final _queuesStreamController =
      StreamController<List<Map<String, dynamic>>>();

  final ScrollController _scrollController = ScrollController();
  int currentPage = 1; // หน้าเริ่มต้น
  bool isLoading = false; // สถานะการโหลด
  final int itemsPerPage = 10; // จำนวนรายการที่จะโหลดในแต่ละหน้า

  void _onScroll() {
    // ตรวจสอบการเลื่อนลง
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      fetchMoreQueues(); // เรียกใช้ฟังก์ชันเพื่อโหลดข้อมูลเพิ่มเติมเมื่อเลื่อนลง
    }
  }

// ฟังก์ชันโหลดข้อมูลเพิ่มเติม
  Future<void> fetchMoreQueues() async {
    if (isLoading) return; // ถ้ากำลังโหลดอยู่ไม่ทำอะไร
    setState(() {
      isLoading = true; // ตั้งค่าสถานะการโหลด
    });

    // เพิ่มหน้าใหม่
    currentPage++;

    final tabData = TabData.of(context);
    if (tabData != null) {
      await fetchSearchQueue(
        tabData.branches['branch_id'].toString(),
        queueNo,
        selectedStatus,
        itemsPerPage: itemsPerPage, // ส่งจำนวนรายการที่ต้องการโหลด
      );
    }

    setState(() {
      isLoading = false; // ตั้งค่าสถานะการโหลดเสร็จสิ้น
    });
  }

  Future<void> fetchSearchQueue(
      String branchId, String queueNo, QueueStatus status,
      {int itemsPerPage = 10}) async {
    await ClassQueue.queuelist(
      context: context,
      branchid: branchId,
      onSearchQueueLoaded: (loadedSearchQueue) {
        if (mounted) {
          setState(() {
            // เพิ่มโค้ดเพื่อโหลดเฉพาะรายการที่ต้องการ
            queues.addAll(loadedSearchQueue
                .take(itemsPerPage)
                .toList()); // โหลดเฉพาะ 10 รายการแรก
            // เปลี่ยน queueNo เป็นตัวพิมพ์เล็ก
            final searchQueueNo = queueNo.toLowerCase();

            // ค้นหาคิวตามหมายเลข
            if (queueNo.isNotEmpty) {
              queues = loadedSearchQueue.where((item) {
                final itemQueueNo = item['queue_no'].toLowerCase();
                return itemQueueNo.contains(searchQueueNo);
              }).toList();
            } else {
              queues = loadedSearchQueue;
            }

            // กรองตามค่า selectedFilter
            if (selectedFilter.isNotEmpty) {
              if (selectedFilter.toLowerCase() == 'clear') {
                queues = loadedSearchQueue;
              } else {
                queues = queues.where((item) {
                  final itemQueueNo = item['queue_no'].toLowerCase();
                  return itemQueueNo.contains(selectedFilter.toLowerCase());
                }).toList();
              }
            }

            filteredQueues1 = queues
                .where((queue) => queue['service_status_id'] == '1')
                .toList();
            filteredQueues3 = queues
                .where((queue) => queue['service_status_id'] == '3')
                .toList();
            filteredQueuesA = queues;

            widget.filteredQueues1Notifier.value = filteredQueues1;
            widget.filteredQueues3Notifier.value = filteredQueues3;
            widget.filteredQueuesANotifier.value = filteredQueuesA;

            // คำนวณจำนวนรายการที่แสดง
            _queuesStreamController.add(queues);
          });
        }
      },
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    FocusScope.of(context).requestFocus(FocusNode());
    _scrollController.addListener(_onScroll);
    final tabData = TabData.of(context);
    if (tabData != null) {
      fetchSearchQueue(
          tabData.branches['branch_id'].toString(), queueNo, selectedStatus);
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _queuesStreamController.close();
    super.dispose();
  }

  QueueStatus _getQueueStatus(String statusId) {
    switch (statusId) {
      case '1':
        return QueueStatus.waiting;
      case '2':
        return QueueStatus.called;
      case '3':
        return QueueStatus.paused;
      case '4':
        return QueueStatus.finished;
      case '9':
        return QueueStatus.ended;
      default:
        return QueueStatus.clear;
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final buttonHeight = size.height * 0.06;
    final iconSize = size.height * 0.05;
    final fontSize = size.height * 0.02;
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _controller,
                  decoration: InputDecoration(
                    labelText: 'พิมพ์เพื่อค้นหา Q NO | Search Q No',
                    labelStyle: TextStyle(
                      color: const Color.fromARGB(255, 0, 67, 122),
                      fontSize: fontSize,
                    ),
                    border: OutlineInputBorder(
                      borderRadius:
                          BorderRadius.circular(50.0), // กำหนดรัศมีของขอบมน
                      borderSide: const BorderSide(
                        color: Color.fromRGBO(9, 159, 175, 1.0), // สีของเส้นขอบ
                        width: 2.0, // ความหนาของเส้นขอบ
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(
                          50.0), // กำหนดรัศมีของขอบมนเมื่อโฟกัส
                      borderSide: const BorderSide(
                        color: const Color.fromARGB(255, 0, 67, 122),
                        width: 2.0, // ความหนาของเส้นขอบเมื่อโฟกัส
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(
                          50.0), // กำหนดรัศมีของขอบมนเมื่อเปิดใช้งาน
                      borderSide: const BorderSide(
                        color: const Color.fromARGB(255, 0, 67, 122),
                        width: 2.0, // ความหนาของเส้นขอบเมื่อเปิดใช้งาน
                      ),
                    ),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _controller.text.isNotEmpty
                            ? Icons.clear
                            : Icons.search, // เปลี่ยนไอคอนตามค่าของ TextField
                        color: _controller.text.isNotEmpty
                            ? const Color.fromRGBO(255, 0, 0, 1)
                            : const Color.fromARGB(255, 0, 67, 122),
                      ),
                      onPressed: () {
                        if (_controller.text.isNotEmpty) {
                          _controller.clear();
                          setState(() {
                            queueNo = '';
                            final tabData = TabData.of(context);
                            if (tabData != null) {
                              fetchSearchQueue(
                                tabData.branches['branch_id'].toString(),
                                queueNo,
                                selectedStatus,
                              );
                            }
                          });
                        } else {
                          final tabData = TabData.of(context);
                          if (tabData != null) {
                            fetchSearchQueue(
                              tabData.branches['branch_id'].toString(),
                              queueNo,
                              selectedStatus,
                            );
                          }
                        }
                      },
                    ),
                    fillColor: const Color.fromARGB(255, 255, 255, 255),
                    filled: true, // ให้มีสีพื้นหลัง
                  ),
                  style: const TextStyle(
                    fontSize: 25,
                    color: const Color.fromARGB(255, 0, 67, 122),
                  ),
                  onChanged: (value) {
                    setState(() {
                      queueNo = value;
                      final tabData = TabData.of(context);
                      if (tabData != null) {
                        fetchSearchQueue(
                          tabData.branches['branch_id'].toString(),
                          queueNo,
                          selectedStatus,
                        );
                      }
                    });
                  },
                ),
              ),
              // const SizedBox(width: 5),
              // PopupMenuButton<QueueStatus>(
              //   icon: const Icon(
              //     Icons.filter_list,
              //     color: Color.fromRGBO(255, 255, 255, 1),
              //   ),
              //   onSelected: (QueueStatus status) {
              //     setState(() {
              //       if (status == QueueStatus.clear) {
              //         // รีเซ็ตสถานะกรอง
              //         selectedStatus = QueueStatus.clear;
              //       } else {
              //         selectedStatus = status;
              //       }

              //       final tabData = TabData.of(context);
              //       if (tabData != null) {
              //         fetchSearchQueue(tabData.branches['branch_id'].toString(),
              //             queueNo, selectedStatus);
              //       }
              //     });
              //   },
              //   itemBuilder: (BuildContext context) => <QueueStatus>[
              //     QueueStatus.waiting,
              //     QueueStatus.called,
              //     QueueStatus.paused,
              //     QueueStatus.finished,
              //     QueueStatus.ended,
              //     QueueStatus.clear,
              //   ].map<PopupMenuEntry<QueueStatus>>((QueueStatus status) {
              //     return PopupMenuItem<QueueStatus>(
              //       value: status,
              //       child: Text(_getStatusText(status)),
              //     );
              //   }).toList(),
              // ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12.0),
                child: PopupMenuButton<String>(
                  onSelected: (String value) {
                    setState(() {
                      selectedFilter = value;
                      final tabData = TabData.of(context);
                      if (tabData != null) {
                        fetchSearchQueue(
                          tabData.branches['branch_id'].toString(),
                          queueNo,
                          selectedStatus,
                        );
                      }
                    });
                  },
                  itemBuilder: (BuildContext context) {
                    return [
                      PopupMenuItem<String>(
                        value: 'a',
                        child: Text(
                          '     A',
                          style: TextStyle(
                            fontSize: fontSize,
                            color: Colors.white,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      PopupMenuItem<String>(
                        value: 'b',
                        child: Text(
                          '     B',
                          style: TextStyle(
                            fontSize: fontSize,
                            color: Colors.white,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      PopupMenuItem<String>(
                        value: 'c',
                        child: Text(
                          '     C',
                          style: TextStyle(
                            fontSize: fontSize,
                            color: Colors.white,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      PopupMenuItem<String>(
                        value: 'd',
                        child: Text(
                          '     D',
                          style: TextStyle(
                            fontSize: fontSize,
                            color: Colors.white,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      PopupMenuItem<String>(
                        value: 'clear',
                        child: Text(
                          ' clear',
                          style: TextStyle(
                            fontSize: fontSize,
                            color: Colors.white,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ];
                  },
                  icon: const Icon(
                    Icons.filter_list,
                    color: Color.fromARGB(255, 255, 255, 255),
                  ),
                  color: const Color.fromARGB(255, 0, 67, 122),
                ),
              )
            ],
          ),
        ),
        // Expanded(
        //   child: StreamBuilder<List<Map<String, dynamic>>>(
        //     stream: _queuesStreamController.stream,
        //     builder: (context, snapshot) {
        //       if (snapshot.connectionState == ConnectionState.waiting) {
        //         return const Center(child: CircularProgressIndicator());
        //       } else if (snapshot.hasError) {
        //         return Center(child: Text('Error: ${snapshot.error}'));
        //       } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
        //         return Center(
        //             child: Text('ไม่มีรายการ',
        //                 style: TextStyle(
        //                   fontSize: fontSize,
        //                   // fontWeight: FontWeight.bold,
        //                   color: Colors.white,
        //                 )));
        //       }

        //       final queues = snapshot.data!;
        //       final size = MediaQuery.of(context).size;
        //       final buttonHeight = size.height * 0.06;

        //       return ListView.builder(
        //         itemCount: queues.length,
        //         itemBuilder: (context, index) {
        //           final item = queues[index];
        //           final status = _getQueueStatus(item['service_status_id']);
        //           final tabData = TabData.of(context);
        //           final branchId =
        //               tabData?.branches['branch_id'].toString() ?? '0';

        //           return QueueItemWidget(
        //             item: item,
        //             buttonHeight: buttonHeight,
        //             size: size,
        //             branchId: branchId,
        //             tabController: widget.tabController,
        //             status: status,
        //             onQueueUpdated: fetchSearchQueue,
        //           );
        //         },
        //       );
        //     },
        //   ),
        // ),
        Expanded(
          child: StreamBuilder<List<Map<String, dynamic>>>(
            stream: _queuesStreamController.stream,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return Center(
                  child: Text('ไม่มีรายการ',
                      style:
                          TextStyle(fontSize: fontSize, color: Colors.white)),
                );
              }

              final queues = snapshot.data!;
              final size = MediaQuery.of(context).size;
              final buttonHeight = size.height * 0.06;

              return ListView.builder(
                controller: _scrollController,
                itemCount: queues.length +
                    (isLoading ? 1 : 0), // Add one for the loading indicator
                itemBuilder: (context, index) {
                  if (index == queues.length) {
                    return Center(
                        child:
                            CircularProgressIndicator()); // Loading indicator
                  }

                  final item = queues[index];
                  final status = _getQueueStatus(item['service_status_id']);
                  final tabData = TabData.of(context);
                  final branchId =
                      tabData?.branches['branch_id'].toString() ?? '0';

                  return QueueItemWidget(
                    item: item,
                    buttonHeight: buttonHeight,
                    size: size,
                    branchId: branchId,
                    tabController: widget.tabController,
                    status: status,
                    onQueueUpdated: fetchSearchQueue,
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  String _getStatusText(QueueStatus status) {
    switch (status) {
      case QueueStatus.waiting:
        return 'รอเรียก';
      case QueueStatus.called:
        return 'เรียกแล้ว';
      case QueueStatus.paused:
        return 'พักคิว';
      case QueueStatus.finished:
        return 'เสร็จสิ้น';
      case QueueStatus.ended:
        return 'ยกเลิก';
      case QueueStatus.clear:
        return 'เคลียกรอง';
      default:
        return '';
    }
  }
}

class QueueItemWidget extends StatefulWidget {
  final Map<String, dynamic> item;
  final double buttonHeight;
  final Size size;
  final String branchId;
  final QueueStatus status;
  final TabController tabController;
  final Future<void> Function(String, String, QueueStatus)
      onQueueUpdated; // ปรับเป็นพารามิเตอร์สามตัว

  const QueueItemWidget({
    super.key,
    required this.item,
    required this.buttonHeight,
    required this.size,
    required this.branchId,
    required this.status,
    required this.tabController,
    required this.onQueueUpdated,
  });

  @override
  _QueueItemWidgetState createState() => _QueueItemWidgetState();
}

class _QueueItemWidgetState extends State<QueueItemWidget> {
  List<Map<String, dynamic>> Reason = [];

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final buttonHeight = size.height * 0.06;
    final buttonWidth = size.width * 0.2;
    final fontSize = size.height * 0.02;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5.0, horizontal: 8.0),
      child: Container(
        padding: const EdgeInsets.all(3.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10.0),
          border: Border.all(color: Colors.white, width: 1.0),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  flex: 1,
                  child: _buildText(
                    "${widget.item['queue_no']}",
                    fontSize * 1.5,
                    const Color.fromARGB(255, 0, 67, 122),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: _buildText(
                    _formatName(
                      "N:${widget.item['customer_name'] ?? 'NoName'}",
                    ),
                    fontSize,
                    const Color.fromARGB(255, 0, 67, 122),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: _buildText(
                    "T:${widget.item['phone_number'] ?? 'NoPhone'}",
                    fontSize,
                    const Color.fromARGB(255, 0, 67, 122),
                  ),
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (widget.status == QueueStatus.waiting) ...[
                  // Expanded(
                  //   flex: 1,
                  //   child: _buildText(
                  //     widget.item['queue_no'],
                  //     fontSize,
                  //     const Color.fromARGB(255, 0, 67, 122),
                  //   ),
                  // ),
                  Expanded(
                    flex: 1,
                    child: _buildText(
                      "Number\n${widget.item['number_pax']} PAX",
                      fontSize,
                      const Color.fromARGB(255, 144, 148, 148),
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: _buildText(
                      "Queue\n${formatQueueTime(widget.item['queue_time'])}",
                      fontSize,
                      const Color.fromARGB(255, 144, 148, 148),
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: _buildText(
                      _getStatusText(widget.status),
                      fontSize,
                      const Color.fromARGB(255, 0, 67, 122),
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: _buildElevatedButton(
                        'Call',
                        const Color.fromARGB(255, 0, 67, 122),
                        widget.buttonHeight,
                        _callQueue),
                  ),
                  const SizedBox(width: 5),
                  Expanded(
                    flex: 1,
                    child: _buildElevatedButton(
                        'Reprint',
                        const Color.fromARGB(255, 38, 152, 13),
                        widget.buttonHeight,
                        _reprintQueue),
                  ),
                ] else if (widget.status == QueueStatus.called) ...[
                  // Expanded(
                  //   flex: 1,
                  //   child: _buildText(
                  //     widget.item['queue_no'],
                  //     fontSize,
                  //     const Color.fromARGB(255, 0, 67, 122),
                  //   ),
                  // ),
                  Expanded(
                    flex: 1,
                    child: _buildText(
                      "Number\n${widget.item['number_pax']} PAX",
                      fontSize,
                      const Color.fromARGB(255, 144, 148, 148),
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: _buildText(
                      "Queue\n${formatQueueTime(widget.item['queue_time'])}",
                      fontSize,
                      const Color.fromARGB(255, 144, 148, 148),
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: _buildText(
                      _getStatusText(widget.status),
                      fontSize,
                      const Color.fromARGB(255, 0, 67, 122),
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: _buildElevatedButton(
                        'Hold',
                        const Color.fromRGBO(249, 162, 31, 1),
                        widget.buttonHeight,
                        _holdQueue),
                  ),
                  // const SizedBox(width: 8),
                  // Expanded(
                  //   flex: 1,
                  //   child: _buildElevatedButton(
                  //       'เรียกซ้ำ',
                  //       const Color.fromRGBO(9, 159, 175, 1.0),
                  //       widget.buttonHeight,
                  //       _recallQueue),
                  // ),
                  const SizedBox(width: 5),
                  Expanded(
                    flex: 1,
                    child: _buildElevatedButton(
                        'Reprint',
                        const Color.fromARGB(255, 38, 152, 13),
                        widget.buttonHeight,
                        _reprintQueue),
                  ),
                ] else if (widget.status == QueueStatus.paused) ...[
                  // Expanded(
                  //   flex: 1,
                  //   child: _buildText(
                  //     widget.item['queue_no'],
                  //     fontSize,
                  //     const Color.fromARGB(255, 0, 67, 122),
                  //   ),
                  // ),
                  Expanded(
                    flex: 1,
                    child: _buildText(
                      "Number\n${widget.item['number_pax']} PAX",
                      fontSize,
                      const Color.fromARGB(255, 144, 148, 148),
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: _buildText(
                      "Queue\n${formatQueueTime(widget.item['queue_time'])}",
                      fontSize,
                      const Color.fromARGB(255, 144, 148, 148),
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: _buildText(
                      "Hold\n${formatQueueTime(widget.item['hold_time']!)}",
                      fontSize,
                      const Color.fromARGB(255, 255, 0, 0),
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: _buildText(
                      _getStatusText(widget.status),
                      fontSize,
                      const Color.fromARGB(255, 0, 67, 122),
                    ),
                  ),
                ] else if (widget.status == QueueStatus.ended) ...[
                  // Expanded(
                  //   flex: 1,
                  //   child: _buildText(
                  //     widget.item['queue_no'],
                  //     fontSize,
                  //     const Color.fromARGB(255, 0, 67, 122),
                  //   ),
                  // ),
                  Expanded(
                    flex: 1,
                    child: _buildText(
                      "Number\n${widget.item['number_pax']} PAX",
                      fontSize,
                      const Color.fromARGB(255, 144, 148, 148),
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: _buildText(
                      "Queue\n${formatQueueTime(widget.item['queue_time'])}",
                      fontSize,
                      const Color.fromARGB(255, 144, 148, 148),
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: _buildText(
                      "Hold\n${widget.item['hold_time'] != null ? formatQueueTime(widget.item['hold_time']) : '-'}",
                      fontSize,
                      const Color.fromARGB(255, 144, 148, 148),
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: _buildText(
                      "End\n${widget.item['end_time'] != null ? formatQueueTime(widget.item['end_time']) : '-'}",
                      fontSize,
                      const Color.fromARGB(255, 255, 0, 0),
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: _buildText(
                      _getStatusText(widget.status),
                      fontSize,
                      const Color.fromARGB(255, 0, 67, 122),
                    ),
                  ),
                ] else if (widget.status == QueueStatus.finished) ...[
                  // Expanded(
                  //   flex: 1,
                  //   child: _buildText(
                  //     widget.item['queue_no'],
                  //     fontSize,
                  //     const Color.fromARGB(255, 0, 67, 122),
                  //   ),
                  // ),
                  Expanded(
                    flex: 1,
                    child: _buildText(
                      "Number\n${widget.item['number_pax']} PAX",
                      fontSize,
                      const Color.fromARGB(255, 144, 148, 148),
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: _buildText(
                      "Queue\n${formatQueueTime(widget.item['queue_time'])}",
                      fontSize,
                      const Color.fromARGB(255, 144, 148, 148),
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: _buildText(
                      "Hold\n${widget.item['hold_time'] != null ? formatQueueTime(widget.item['hold_time']) : '-'}",
                      fontSize,
                      const Color.fromARGB(255, 144, 148, 148),
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: _buildText(
                      "End\n${widget.item['end_time'] != null ? formatQueueTime(widget.item['end_time']) : '-'}",
                      fontSize,
                      const Color.fromARGB(255, 255, 0, 0),
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: _buildText(
                      _getStatusText(widget.status),
                      fontSize,
                      const Color.fromARGB(255, 0, 67, 122),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatName(String fullName) {
    final nameParts = fullName.split(' '); // แยกชื่อและนามสกุล
    if (nameParts.length < 2)
      return fullName; // ถ้ามีแค่ชื่อเดียว ให้ส่งคืนตามปกติ

    final firstName = nameParts[0]; // ชื่อ
    final lastName = nameParts.sublist(1).join(' '); // นามสกุล

    // เช็คความยาวของนามสกุล
    if (lastName.length > 3) {
      return '$firstName ${lastName.substring(0, 3)}...'; // ตัดและเพิ่ม ...
    }
    return fullName; // ส่งคืนชื่อทั้งหมดถ้านามสกุลไม่เกิน 3 ตัว
  }

  Widget _buildText(String text, double size, Color color) {
    return Expanded(
      child: Text(
        text,
        style: TextStyle(
          fontSize: size,
          // fontWeight: FontWeight.bold,
          color: color,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildElevatedButton(
    String label,
    Color color,
    double height,
    Future<void> Function(BuildContext) onPressed,
  ) {
    final size = MediaQuery.of(context).size;
    final fontSize = size.height * 0.02;
    return Expanded(
      child: SizedBox(
        height: height,
        width: 150, // กำหนดขนาดคงที่หรือใช้ค่าที่เหมาะสม
        child: ElevatedButton(
          onPressed: () => onPressed(context),
          style: ElevatedButton.styleFrom(
            foregroundColor: Colors.white,
            backgroundColor: color,
            padding: const EdgeInsets.symmetric(vertical: 1.0),
            // side: const BorderSide(color: Colors.black, width: 2),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: fontSize,
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _endQueue(BuildContext context) async {
    await ClassBranch.EndQueueReasonlist(
      context: context,
      branchid: widget.branchId,
      onReasonLoaded: (loadedReason) {
        setState(() {
          Reason = loadedReason;
        });
      },
    );

    SnackBarHelper.showSaveSnackBar(
      context,
      [widget.item],
      Reason,
    );
    await Future.delayed(const Duration(seconds: 2));
    await widget.onQueueUpdated(widget.branchId, '', widget.status);
  }

  Future<void> _callQueue(BuildContext context) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => LoadingScreen(
          onComplete: () async {
            await ClassCQueue().CallQueue(
              context: context,
              SearchQueue: [widget.item],
            );
            await Future.delayed(const Duration(seconds: 2));
            Navigator.of(context).pop();
            // await widget.onQueueUpdated(widget.branchId, '', widget.status);
            widget.tabController.animateTo(0);
          },
        ),
      ),
    );
  }

  Future<void> _callHQueue(BuildContext context) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => LoadingScreen(
          onComplete: () async {
            await ClassCQueue().UpdateQueue(
              context: context,
              SearchQueue: [widget.item],
              StatusQueue: 'Calling',
              StatusQueueNote: '',
            );
            await Future.delayed(const Duration(seconds: 1));
            await widget.onQueueUpdated(widget.branchId, '', widget.status);
            widget.tabController.animateTo(0);
          },
        ),
      ),
    );
  }

  Future<void> _recallQueue(BuildContext context) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => LoadingScreen(
          onComplete: () async {
            await ClassCQueue().UpdateQueue(
              context: context,
              SearchQueue: [widget.item],
              StatusQueue: 'Recalling',
              StatusQueueNote: '',
            );
            await Future.delayed(const Duration(seconds: 2));
            Navigator.of(context).pop();
            // await widget.onQueueUpdated(widget.branchId, '', widget.status);
          },
        ),
      ),
    );
  }

  Future<void> _reprintQueue(BuildContext context) async {
    RePrintNew testPrint = RePrintNew();
    testPrint.sample(context, widget.item);
  }

  Future<void> _holdQueue(BuildContext context) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => LoadingScreen(
          onComplete: () async {
            await ClassCQueue().UpdateQueue(
              context: context,
              SearchQueue: [widget.item],
              StatusQueue: 'Holding',
              StatusQueueNote: '',
            );
            await Future.delayed(const Duration(seconds: 2));
            Navigator.of(context).pop();
            await widget.onQueueUpdated(widget.branchId, '', widget.status);
          },
        ),
      ),
    );
  }

  String _getStatusText(QueueStatus status) {
    switch (status) {
      case QueueStatus.waiting:
        return 'Wait';
      case QueueStatus.called:
        return 'Call';
      case QueueStatus.paused:
        return 'Holding';
      case QueueStatus.finished:
        return 'Finish';
      case QueueStatus.ended:
        return 'Cancel';
      default:
        return '';
    }
  }
}
