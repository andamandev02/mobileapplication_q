import 'package:flutter/material.dart';
import 'api/brach/brachlist.dart';
import 'counter.dart';

class BranchListS extends StatefulWidget {
  const BranchListS({super.key});

  @override
  State<BranchListS> createState() => _BranchListSState();
}

class _BranchListSState extends State<BranchListS> {
  List<Map<String, dynamic>> _branches = [];

  @override
  void initState() {
    super.initState();
    fetchBranchList();
  }

  Future<void> fetchBranchList() async {
    ClassBranch.branchlist(
      context: context,
      // ignore: non_constant_identifier_names
      onBranchListLoaded: (LoadingBranchList) {
        setState(() {
          _branches = LoadingBranchList;
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // รับขนาดหน้าจอ
    final size = MediaQuery.of(context).size;
    final buttonHeight = size.height * 0.06; // 6% ของความสูงหน้าจอ
    final buttonWidth = size.width * 0.2; // 20% ของความกว้างหน้าจอ
    return Scaffold(
      backgroundColor: const Color.fromRGBO(9, 159, 175, 1.0),
      appBar: AppBar(
        title: const Text(
          'เลือกสาขา',
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
              itemCount: _branches.length,
              itemBuilder: (context, index) {
                final branchName = _branches[index]['branch_name'];

                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: SizedBox(
                    width: buttonWidth,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                CounterListS(branches: _branches[index]),
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
