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
      onBranchListLoaded: (LoadingBranchList) {
        setState(() {
          _branches = LoadingBranchList;
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final buttonHeight = size.height * 0.06;
    final buttonWidth = size.width * 0.2;
    final fontSize = size.height * 0.02;

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 0, 67, 122),
      appBar: AppBar(
        title: Text(
          'เลือกสาขา | Select Branch',
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
                          const SizedBox(width: 10),
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
