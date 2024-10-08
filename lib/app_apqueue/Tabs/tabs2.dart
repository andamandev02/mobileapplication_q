import 'package:flutter/material.dart';
import 'TabData.dart';
import '../api/queue/crud.dart';
import '../api/queue/queuelist.dart';
import '../api/time.dart';
import '../api/url.dart';
import '../cancel_screen.dart';
import '../loadingsreen.dart';
import '../api/brach/brachlist.dart';

class Tab2 extends StatefulWidget {
  const Tab2({
    super.key,
    required this.tabController,
    required this.filteredQueues1Notifier,
    required this.filteredQueues3Notifier,
    required this.filteredQueuesANotifier,
  });

  @override
  _Tab2State createState() => _Tab2State();
  final TabController tabController;
  final ValueNotifier<List<Map<String, dynamic>>> filteredQueues1Notifier;
  final ValueNotifier<List<Map<String, dynamic>>> filteredQueues3Notifier;
  final ValueNotifier<List<Map<String, dynamic>>> filteredQueuesANotifier;
}

class _Tab2State extends State<Tab2> {
  late List<Map<String, dynamic>> queues = [];
  List<Map<String, dynamic>> filteredQueues1 = [];
  List<Map<String, dynamic>> filteredQueues3 = [];
  List<Map<String, dynamic>> filteredQueuesA = [];

  final TextEditingController _searchController = TextEditingController();
  String _searchQueueNo = '';
  String selectedFilter = '';

  int currentPage = 1;
  bool isLoading = false;
  bool hasMoreData = true;
  final int pageSize = 10;
  bool isLoadingMore = false;

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

  Future<void> fetchSearchQueue(String branchId, String queueNo, String filter,
      {int page = 10}) async {
    if (isLoading || !hasMoreData) return; // Prevent multiple calls
    isLoadingMore = true; // Set loading more flag
    isLoading = true;
    await ClassQueue.queuelist(
      context: context,
      branchid: branchId,
      onSearchQueueLoaded: (loadedSearchQueue) {
        if (mounted) {
          setState(() {
            if (loadedSearchQueue.isEmpty) {
              hasMoreData = false; // No more data available
            } else {
              queues.addAll(loadedSearchQueue);
            }

            queues = loadedSearchQueue.where((item) {
              final queueNoMatches = item['queue_no']
                  .toLowerCase()
                  .contains(queueNo.toLowerCase());
              final filterMatches = filter == 'clear' ||
                  item['queue_no'].toLowerCase().contains(filter.toLowerCase());
              return queueNoMatches && filterMatches;
            }).toList();

            // Filter the queues as before
            filteredQueues1 = queues
                .where((queue) => queue['service_status_id'] == '1')
                .toList();
            filteredQueues3 = queues
                .where((queue) => queue['service_status_id'] == '3')
                .toList();
            filteredQueuesA = queues;

            // Notify listeners
            widget.filteredQueues1Notifier.value = filteredQueues1;
            widget.filteredQueues3Notifier.value = filteredQueues3;
            widget.filteredQueuesANotifier.value = filteredQueuesA;

            isLoadingMore = false;
          });
        }
        isLoading = false;
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
                  controller: _searchController,
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
                    fillColor: const Color.fromARGB(255, 255, 255, 255),
                    filled: true,
                    suffixIcon: IconButton(
                      icon: Icon(
                        _searchController.text.isNotEmpty
                            ? Icons.clear
                            : Icons.search,
                        color: _searchController.text.isNotEmpty
                            ? const Color.fromRGBO(255, 0, 0, 1)
                            : const Color.fromARGB(255, 0, 67, 122),
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
                  style: TextStyle(
                    fontSize: fontSize,
                    color: const Color.fromARGB(255, 0, 67, 122),
                  ),
                  onChanged: _onSearchChanged, // เรียกใช้เมื่อพิมพ์
                ),
              ),
              Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10.0),
                  child: PopupMenuButton<String>(
                    onSelected: (String value) {
                      setState(() {
                        selectedFilter = value;
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
                            textAlign: TextAlign.end,
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
                            textAlign: TextAlign.end,
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
                            textAlign: TextAlign.end,
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
                            textAlign: TextAlign.end,
                          ),
                        ),
                        PopupMenuItem<String>(
                          value: 'clear',
                          child: Text(
                            '   clear',
                            style: TextStyle(
                              fontSize: fontSize,
                              color: Colors.white,
                            ),
                            textAlign: TextAlign.end,
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
                ),
              )
            ],
          ),
        ),
        Expanded(
          flex: 1,
          child: queues.isNotEmpty
              ? NotificationListener<ScrollNotification>(
                  onNotification: (ScrollNotification scrollInfo) {
                    if (!isLoading &&
                        hasMoreData &&
                        scrollInfo.metrics.pixels ==
                            scrollInfo.metrics.maxScrollExtent) {
                      currentPage++;
                      fetchSearchQueue(
                        TabData.of(context)!.branches['branch_id'].toString(),
                        _searchQueueNo,
                        selectedFilter,
                        page: currentPage,
                      );
                    }
                    return true;
                  },
                  child: ListView.builder(
                    itemCount: queues.length +
                        (isLoadingMore
                            ? 1
                            : 0), // Add one for loading indicator
                    itemBuilder: (context, index) {
                      if (index < queues.length) {
                        // Render actual queue items
                        final item = queues[index];
                        if (item['service_status_id'] == '1') {
                          final tabData = TabData.of(context);
                          final branchId =
                              tabData?.branches['branch_id'].toString() ?? '0';
                          return QueueItemWidget(
                            item: item,
                            buttonHeight:
                                MediaQuery.of(context).size.height * 0.06,
                            size: MediaQuery.of(context).size,
                            branchId: branchId,
                            onQueueUpdated: fetchSearchQueue,
                            tabController: widget.tabController,
                            searchQueueNo: _searchQueueNo,
                          );
                        }
                        return const SizedBox.shrink();
                      } else {
                        // Show loading indicator when loading more data
                        return const Center(
                          child: CircularProgressIndicator(),
                        );
                      }
                    },
                  ),
                )
              : Center(
                  child: Text(
                    'ไม่มีรายการ | No Data',
                    style: TextStyle(
                      fontSize: fontSize,
                      color: Colors.white,
                    ),
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
    final size = MediaQuery.of(context).size;
    final buttonHeight = size.height * 0.06;
    final buttonWidth = size.width * 0.2;
    final fontSize = size.height * 0.02;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5.0, horizontal: 8.0),
      child: Container(
        padding: const EdgeInsets.all(2.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10.0),
          border: Border.all(color: Colors.white, width: 1.0),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
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
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Expanded(
                  flex: 1,
                  child: _buildText(
                    "Number\n${widget.item['number_pax']} PAX",
                    fontSize,
                    const Color.fromARGB(255, 144, 148, 148),
                  ),
                ),
                const SizedBox(width: 5),
                Expanded(
                  flex: 1,
                  child: _buildText(
                    "Queue\n${formatQueueTime(widget.item['queue_time'])}",
                    fontSize,
                    const Color.fromARGB(255, 144, 148, 148),
                  ),
                ),
                const SizedBox(width: 5),
                Expanded(
                  flex: 1,
                  child: _buildText(
                    "Wait\n${calculateTimeDifference(widget.item['queue_time'])}",
                    fontSize,
                    const Color.fromARGB(255, 144, 148, 148),
                  ),
                ),
                const SizedBox(width: 5),
                Expanded(
                  flex: 1,
                  child: _buildElevatedButton(
                    'End',
                    const Color.fromARGB(255, 255, 0, 0),
                    buttonHeight,
                    _endQueue,
                  ),
                ),
                const SizedBox(width: 5),
                Expanded(
                  flex: 1,
                  child: _buildElevatedButton(
                    'Call',
                    const Color.fromARGB(255, 0, 67, 122),
                    buttonHeight,
                    _callQueue,
                  ),
                ),
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

  // Widget สำหรับ Text
  Widget _buildText(String text, double size, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        text,
        style: TextStyle(
          fontSize: size,
          color: color,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  // Widget สำหรับ ElevatedButton
  Widget _buildElevatedButton(
    String label,
    Color color,
    double height,
    Future<void> Function(BuildContext) onPressed,
  ) {
    final size = MediaQuery.of(context).size;
    final fontSize = size.height * 0.02; // ปรับขนาดฟอนต์ของปุ่ม

    return Expanded(
      child: SizedBox(
        height: height,
        child: ElevatedButton(
          onPressed: () => onPressed(context),
          style: ElevatedButton.styleFrom(
            foregroundColor: Colors.white,
            backgroundColor: color,
            padding: const EdgeInsets.symmetric(vertical: 1.0),
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

            await widget.onQueueUpdated(
                widget.branchId, widget.searchQueueNo, '');
          },
        ),
      ),
    );

    // SnackBarHelper.showSaveSnackBar(
    //   context,
    //   [widget.item],
    //   Reason,
    // );

    // await Future.delayed(const Duration(seconds: 2));
    // await widget.onQueueUpdated(widget.branchId, widget.searchQueueNo, '');
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

            // await widget.onQueueUpdated(widget.branchId, widget.searchQueueNo);
            widget.tabController.animateTo(0);
          },
        ),
      ),
    );
  }
}
