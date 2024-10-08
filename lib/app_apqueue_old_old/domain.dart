import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'api/url.dart';
import 'brachlist.dart';
import 'setting/setting.dart';
import 'package:http/http.dart' as http;
// import 'package:somboon_v2/setting/setthing.dart';

// ignore: use_key_in_widget_constructors
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: MyHomePage(),
    );
  }
}

// ignore: library_private_types_in_public_api, use_key_in_widget_constructors
class MyHomePage extends StatefulWidget {
  @override
  // ignore: library_private_types_in_public_api
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final TextEditingController _controller = TextEditingController();
  late Box _domainBox;

  @override
  void initState() {
    super.initState();
    _initDomainFromHive();
  }

  void _initDomainFromHive() async {
    _domainBox = Hive.box('DomainUrl');
    _controller.text = _domainBox.get('Domain') ?? '';
    apiBaseURL = _controller.text;
    setState(() {});
  }

  void _clearInput() {
    _controller.clear();
  }

  void _nextAction() async {
    final domainName = _controller.text.trim();

    if (domainName.isEmpty) {
      String ToMsg = "WARNING";
      String queueNumber = "กรุณาป้อนโดเมน";
      SnackBarHelper.showErrorSnackBar(context, ToMsg, queueNumber);
      return;
    }

    // Ensure domainName starts with a valid protocol
    final correctedDomainName =
        domainName.startsWith('http://') || domainName.startsWith('https://')
            ? domainName
            : 'http://$domainName';

    await _addToHive(correctedDomainName);

    // Build the URL
    final url =
        Uri.parse('$correctedDomainName/api/v1/queue-mobile/branch-list');

    try {
      // Check the URL status
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

  Future<void> _addToHive(String domain) async {
    if (_domainBox.containsKey('Domain')) {
      await _domainBox.delete('Domain');
    }
    await _domainBox.put('Domain', domain);
    setState(() {});
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
                'assets/logo/GetImage-removebg-preview.png',
                width: screenWidth * 1.4,
                height: screenHeight * 0.4,
                fit: BoxFit.contain,
              ),
              SizedBox(height: screenSize.height * 0.01),
              // เพิ่ม TextField ที่นี่
              TextField(
                controller: _controller,
                decoration: const InputDecoration(
                  hintText: 'Enter Domain',
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: screenSize.height * 0.03),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: _clearInput,
                    style: ElevatedButton.styleFrom(
                      minimumSize: Size(screenWidth * 0.4, screenHeight * 0.08),
                      foregroundColor: Colors.white,
                      backgroundColor: const Color.fromARGB(255, 255, 0, 0),
                    ),
                    child: const Text('CLEAR'),
                  ),
                  ElevatedButton(
                    onPressed: _nextAction,
                    style: ElevatedButton.styleFrom(
                      minimumSize: Size(screenWidth * 0.4, screenHeight * 0.08),
                      foregroundColor: Colors.white,
                      backgroundColor: const Color.fromARGB(255, 83, 181, 214),
                    ),
                    child: const Text('NEXT'),
                  ),
                ],
              ),
              Align(
                alignment: Alignment.bottomRight, // Align to bottom right
                child: Padding(
                  padding: const EdgeInsets.all(
                      8.0), // เพิ่ม padding รอบๆ ให้พอเหมาะ
                  child: Row(
                    mainAxisAlignment:
                        MainAxisAlignment.end, // จัดตำแหน่งให้ไปทางขวา
                    children: [
                      IconButton(
                        icon: const Icon(Icons.settings, color: Colors.white),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => SettingScreen(),
                            ),
                          );
                        },
                      ),
                      const SizedBox(
                          width:
                              8.0), // เพิ่มระยะห่างเล็กน้อยระหว่างไอคอนกับข้อความ
                      const Text(
                        'V1.02',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12.0, // Set font size for the version
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
