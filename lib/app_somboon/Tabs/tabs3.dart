import 'package:flutter/material.dart';
import '../cancel_screen.dart';
import '../loadingsreen.dart';
import 'TabData.dart';
import '../api/queue/crud.dart';
import '../api/queue/queuelist.dart';
import '../api/time.dart';
import '../api/url.dart';
import '../api/brach/brachlist.dart';

class Tab3 extends StatefulWidget {
  const Tab3({
    super.key,
    required this.tabController,
    required this.filteredQueues1Notifier,
    required this.filteredQueues3Notifier,
    required this.filteredQueuesANotifier,
  });

  @override
  _Tab3State createState() => _Tab3State();
  final TabController tabController;
  final ValueNotifier<List<Map<String, dynamic>>> filteredQueues1Notifier;
  final ValueNotifier<List<Map<String, dynamic>>> filteredQueues3Notifier;
  final ValueNotifier<List<Map<String, dynamic>>> filteredQueuesANotifier;
}

class _Tab3State extends State<Tab3> {
  late List<Map<String, dynamic>> queues = [];
  List<Map<String, dynamic>> filteredQueues1 = [];
  List<Map<String, dynamic>> filteredQueues3 = [];
  List<Map<String, dynamic>> filteredQueuesA = [];

  final TextEditingController _searchController = TextEditingController();
  String _searchQueueNo = '';
  String selectedFilter = '';

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    FocusScope.of(context).requestFocus(FocusNode());
    final tabData = TabData.of(context);
    if (tabData != null) {
      fetchSearchQueue(tabData.branches['branch_id'].toString(), _searchQueueNo,
          selectedFilter);
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> fetchSearchQueue(
      String branchId, String queueNo, String filter) async {
    await ClassQueue.queuelist(
      context: context,
      branchid: branchId,
      onSearchQueueLoaded: (loadedSearchQueue) {
        if (mounted) {
          setState(() {
            // queues = loadedSearchQueue.where((item) {
            //   // กรองคิวตาม queueNo โดยไม่สนใจตัวพิมพ์ใหญ่พิมพ์เล็ก
            //   return item['queue_no']
            //       .toLowerCase()
            //       .contains(queueNo.toLowerCase());
            // }).toList();

            queues = loadedSearchQueue.where((item) {
              //   // กรองคิวตาม queueNo โดยไม่สนใจตัวพิมพ์ใหญ่พิมพ์เล็ก
              //   return item['queue_no']
              //       .toLowerCase()
              //       .contains(queueNo.toLowerCase());
              // }).toList();

              final queueNoMatches = item['queue_no']
                  .toLowerCase()
                  .contains(queueNo.toLowerCase());

              final filterMatches = filter == 'clear' ||
                  item['queue_no'].toLowerCase().contains(filter.toLowerCase());

              return queueNoMatches && filterMatches;
            }).toList();

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
          });
        }
      },
    );
  }

  void _onSearchChanged(String value) {
    final tabData = TabData.of(context);
    if (tabData != null) {
      setState(() {
        _searchQueueNo = value;
        fetchSearchQueue(tabData.branches['branch_id'].toString(),
            _searchQueueNo, selectedFilter);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    labelText: 'พิมพ์เพื่อค้นหา QUEUE NO',
                    labelStyle: const TextStyle(
                      color: Color.fromRGBO(9, 159, 175, 1.0),
                      fontSize: 25.0,
                    ),
                    border: OutlineInputBorder(
                      borderRadius:
                          BorderRadius.circular(12.0), // กำหนดรัศมีของขอบมน
                      borderSide: const BorderSide(
                        color: Color.fromRGBO(9, 159, 175, 1.0), // สีของเส้นขอบ
                        width: 2.0, // ความหนาของเส้นขอบ
                      ),
                    ),
                    fillColor: const Color.fromARGB(255, 255, 255, 255),
                    filled: true,
                    suffixIcon: IconButton(
                      icon: Icon(
                        _searchController.text.isNotEmpty
                            ? Icons.clear
                            : Icons.search, // เปลี่ยนไอคอนตามค่าของ TextField
                        color: _searchController.text.isNotEmpty
                            ? const Color.fromRGBO(255, 0, 0, 1)
                            : const Color.fromRGBO(9, 159, 175, 1.0),
                      ),
                      onPressed: () {
                        _searchController.clear();
                        selectedFilter == '';
                        setState(() {
                          _searchQueueNo = '';
                          final tabData = TabData.of(context);
                          if (tabData != null) {
                            fetchSearchQueue(
                                tabData.branches['branch_id'].toString(),
                                _searchQueueNo,
                                selectedFilter);
                          }
                        });
                      },
                    ),
                  ),
                  style: const TextStyle(
                      fontSize: 25, color: Color.fromRGBO(9, 159, 175, 1.0)),
                  onChanged: _onSearchChanged, // เรียกใช้เมื่อพิมพ์
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40.0),
                child: PopupMenuButton<String>(
                  onSelected: (String value) {
                    setState(() {
                      selectedFilter = value;
                    });
                  },
                  itemBuilder: (BuildContext context) {
                    return [
                      const PopupMenuItem<String>(
                        value: 'a',
                        child: Text(
                          '     A',
                          style: TextStyle(
                            fontSize: 30.0,
                            color: Colors.white,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const PopupMenuItem<String>(
                        value: 'b',
                        child: Text(
                          '     B',
                          style: TextStyle(
                            fontSize: 30.0,
                            color: Colors.white,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const PopupMenuItem<String>(
                        value: 'c',
                        child: Text(
                          '     C',
                          style: TextStyle(
                            fontSize: 30.0,
                            color: Colors.white,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const PopupMenuItem<String>(
                        value: 'd',
                        child: Text(
                          '     D',
                          style: TextStyle(
                            fontSize: 30.0,
                            color: Colors.white,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const PopupMenuItem<String>(
                        value: 'clear',
                        child: Text(
                          ' เคลีย',
                          style: TextStyle(
                            fontSize: 30.0,
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
                  color: const Color.fromRGBO(9, 159, 175, 1.0),
                ),
              )
            ],
          ),
        ),
        Expanded(
          child: queues.any((item) => item['service_status_id'] == '3')
              ? ListView.builder(
                  itemCount: queues.length,
                  itemBuilder: (context, index) {
                    final item = queues[index];
                    if (item['service_status_id'] == '3') {
                      final tabData = TabData.of(context);
                      final branchId =
                          tabData?.branches['branch_id'].toString() ?? '0';
                      return QueueItemWidget(
                        item: item,
                        buttonHeight: MediaQuery.of(context).size.height * 0.06,
                        size: MediaQuery.of(context).size,
                        branchId: branchId,
                        onQueueUpdated: fetchSearchQueue,
                        tabController: widget.tabController,
                        searchQueueNo: _searchQueueNo,
                      );
                    }
                    return const SizedBox.shrink();
                  },
                )
              // : const Center(
              //     child: Text(
              //       'ไม่มีรายการคิวรอ',
              //       style: TextStyle(fontSize: 40.0, color: Colors.white),
              //     ),
              //   ),
              // : const Center(
              //     child: CircularProgressIndicator(),
              //   ),
              : const Center(
                  child: Text(
                    'ไม่มีรายการ',
                    style: TextStyle(
                      fontSize: 20,
                      // fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ), // สามารถปรับแต่ง style ได้ตามต้องการ
                  ),
                ),
        ),
      ],
    );
  }
}

class QueueItemWidget extends StatefulWidget {
  final Map<String, dynamic> item;
  final double buttonHeight;
  final Size size;
  final String branchId;
  final TabController tabController;
  // final Future<void> Function(String, String) onQueueUpdated;
  final Future<void> Function(String, String, String) onQueueUpdated;
  final String searchQueueNo;

  const QueueItemWidget({
    super.key,
    required this.item,
    required this.buttonHeight,
    required this.size,
    required this.branchId,
    required this.onQueueUpdated,
    required this.tabController,
    required this.searchQueueNo,
  });

  @override
  _QueueItemWidgetState createState() => _QueueItemWidgetState();
}

class _QueueItemWidgetState extends State<QueueItemWidget> {
  List<Map<String, dynamic>> Reason = [];

  @override
  Widget build(BuildContext context) {
    final buttonHeight = 55.0; // ใช้ค่าคงที่เพื่อความสูงของปุ่ม

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5.0, horizontal: 5.0),
      child: Container(
        padding: const EdgeInsets.all(12.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10.0),
          border: Border.all(color: Colors.white, width: 1.0),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildText(
                  widget.item['queue_no'],
                  40.0,
                  const Color.fromRGBO(9, 159, 175, 1.0),
                ),
                const SizedBox(width: 20),
                _buildText(
                  "จำนวน\n${widget.item['number_pax']} PAX",
                  20.0,
                  const Color.fromARGB(255, 144, 148, 148),
                ),
                const SizedBox(width: 20),
                _buildText(
                  "ออกคิว\n${formatQueueTime(widget.item['queue_time'])}",
                  20.0,
                  const Color.fromARGB(255, 144, 148, 148),
                ),
                const SizedBox(width: 20),
                _buildText(
                  "พักคิว\n${calculateTimeDifference(widget.item['hold_time'])}",
                  20.0,
                  const Color.fromARGB(255, 144, 148, 148),
                ),
                const SizedBox(width: 20),
                _buildElevatedButton(
                    'จบคิว',
                    const Color.fromARGB(255, 255, 0, 0),
                    buttonHeight,
                    _endQueue),
                const SizedBox(width: 20),
                _buildElevatedButton(
                    'เรียกคิว',
                    const Color.fromRGBO(9, 159, 175, 1.0),
                    buttonHeight,
                    _callQueue),
              ],
            ),
            // Row(
            //   mainAxisAlignment: MainAxisAlignment.center,
            //   children: [
            //     _buildElevatedButton(
            //         'จบคิว',
            //         const Color.fromARGB(255, 255, 0, 0),
            //         buttonHeight,
            //         _endQueue),
            //     const SizedBox(width: 8),
            //     _buildElevatedButton(
            //         'เรียกคิว',
            //         const Color.fromRGBO(9, 159, 175, 1.0),
            //         buttonHeight,
            //         _callQueue),
            //   ],
            // ),
          ],
        ),
      ),
    );
  }

  // ignore: non_constant_identifier_names
  Widget _buildText(String text, double size, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
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
            style: const TextStyle(
              fontSize: 20,
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _endQueue(BuildContext context) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => LoadingScreen(
          onComplete: () async {
            await ClassBranch.EndQueueReasonlist(
              context: context,
              branchid: widget.branchId,
              onReasonLoaded: (loadedReason) {
                setState(() {
                  Reason = loadedReason;
                });
              },
            );

            await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => CancelScreen(
                  reason: Reason,
                  T2OK: [widget.item],
                ),
              ),
            );

            // SnackBarHelper.showSaveSnackBar(
            //   context,
            //   [widget.item],
            //   Reason,
            // );

            await Future.delayed(const Duration(seconds: 2));
            await widget.onQueueUpdated(
                widget.branchId, widget.searchQueueNo, '');
          },
        ),
      ),
    );
  }

  Future<void> _callQueue(BuildContext context) async {
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
            Navigator.of(context).pop();
            // await widget.onQueueUpdated(widget.branchId, widget.searchQueueNo);
            widget.tabController.animateTo(0);
          },
        ),
      ),
    );
  }
}
