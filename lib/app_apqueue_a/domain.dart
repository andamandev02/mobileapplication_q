import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:http/http.dart' as http;

import 'api/url.dart';
import 'brachlist.dart';
import 'setting/setting.dart';

class DomainScreen extends StatefulWidget {
  const DomainScreen({super.key});

  @override
  State<DomainScreen> createState() => _DomainScreenState();
}

class _DomainScreenState extends State<DomainScreen> {
  final TextEditingController _controller = TextEditingController();
  late Box domainBox;

  @override
  void initState() {
    super.initState();
    _initDomainFromHive();
  }

  void _initDomainFromHive() async {
    domainBox = Hive.box('DomainUrl');
    _controller.text = domainBox.get('Domain') ?? '';
    apiBaseURL = _controller.text;
    setState(() {});
  }

  Future<void> _addToHive(String domain) async {
    if (domainBox.containsKey('Domain')) {
      await domainBox.delete('Domain');
    }
    await domainBox.put('Domain', domain);
    setState(() {});
  }

  void clearInput() {
    _controller.clear();
  }

  void nextAction() async {
    final domainName = _controller.text.trim();
    if (domainName.isEmpty) {
      String ToMsg = "WARNING";
      String queueNumber = "กรุณาป้อนโดเมน";
      SnackBarHelper.showErrorSnackBar(context, ToMsg, queueNumber);
      return;
    }
    final correctedDomainName =
        domainName.startsWith('http://') || domainName.startsWith('https://')
            ? domainName
            : 'http://$domainName';

    await _addToHive(correctedDomainName);

    final url =
        Uri.parse('$correctedDomainName/api/v1/queue-mobile/branch-list');

    try {
      final response = await http.get(url);

      if (response.statusCode == 404) {
        String ToMsg = "WARNING";
        String queueNumber = "ไม่พบ Domain นี้ในระบบ";
        SnackBarHelper.showErrorSnackBar(context, ToMsg, queueNumber);
      } else {
        setState(() {
          apiBaseURL = correctedDomainName;
          print(apiBaseURL);
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const BranchListS(),
            ),
          );
        });
      }
    } catch (e) {
      String ToMsg = "ERROR";
      String queueNumber = "ไม่พบ Domain นี้ในระบบ";
      SnackBarHelper.showErrorSnackBar(context, ToMsg, queueNumber);
    }
  }

  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 0, 67, 122),
      body: Center(
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                'assets/logo/apqueue_logo2.png',
                width: screenWidth * 1.0,
                height: screenHeight * 0.4,
                fit: BoxFit.contain,
              ),
              SizedBox(height: screenSize.height * 0.05),
              // เพิ่ม TextField ที่นี่
              TextField(
                controller: _controller,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  hintText: 'Domain',
                  hintStyle: TextStyle(color: Colors.white),
                  filled: true,
                  fillColor: Color.fromARGB(255, 0, 67, 122),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.white),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.white),
                  ),
                ),
              ),
              SizedBox(height: screenSize.height * 0.03),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: clearInput,
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: Colors.red,
                      side: const BorderSide(color: Colors.white, width: 2),
                      minimumSize: Size(screenWidth * 0.4, screenHeight * 0.08),
                    ),
                    child: const Text('เคลีย | Clear'),
                  ),
                  ElevatedButton(
                    onPressed: nextAction,
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: const Color.fromARGB(255, 0, 67, 122),
                      side: const BorderSide(color: Colors.white, width: 2),
                      minimumSize: Size(screenWidth * 0.4, screenHeight * 0.08),
                    ),
                    child: const Text('ต่อไป | Next'),
                  ),
                ],
              ),
              Align(
                alignment: Alignment.bottomRight,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.settings, color: Colors.white),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const SettingScreen(),
                            ),
                          );
                        },
                      ),
                      const SizedBox(width: 8.0),
                      const Text(
                        'V1.00',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12.0,
                        ),
                      ),
                    ],
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
