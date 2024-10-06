import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'api/url.dart';
import 'brachlist.dart';
import 'setting/setting.dart';
import 'package:http/http.dart' as http;

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
    final size = MediaQuery.of(context).size;
    final buttonHeight = size.height * 0.06;
    final buttonWidth = size.width * 0.2;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: const Color.fromRGBO(9, 159, 175, 1.0),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Column(
                children: <Widget>[
                  // const SizedBox(height: 50),
                  Image.asset(
                    'assets/logo/logo.png',
                    width: screenSize.width,
                    height: screenSize.width,
                    fit: BoxFit.none,
                  ),
                  // const SizedBox(height: 20),
                  const Text(
                    "กำหนดชื่อโดเมนของร้าน",
                    style: TextStyle(
                      fontSize: 25.0,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    height: 80.0,
                    child: TextField(
                      controller: _controller,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 25.0,
                      ),
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'DOMAIN',
                        labelStyle: TextStyle(
                          color: Colors.white,
                          fontSize: 25.0,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.white),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.white),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Expanded(
                        flex: 2,
                        child: ElevatedButton(
                          onPressed: _clearInput,
                          style: ElevatedButton.styleFrom(
                            foregroundColor: Colors.white,
                            backgroundColor:
                                const Color.fromARGB(255, 255, 0, 0),
                            padding: EdgeInsets.symmetric(
                                vertical: size.height * 0.02),
                            minimumSize: Size(double.infinity, buttonHeight),
                            // side: const BorderSide(
                            //   color: Colors.black,
                            //   width: 2,
                            // ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text(
                            'เคลีย | CLEAR',
                            style: TextStyle(
                              fontSize: 25.0,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(
                        width: 10,
                      ),
                      Expanded(
                        flex: 2,
                        child: ElevatedButton(
                          onPressed: _nextAction,
                          style: ElevatedButton.styleFrom(
                            foregroundColor: Colors.white,
                            backgroundColor:
                                const Color.fromARGB(255, 83, 181, 214),
                            padding: EdgeInsets.symmetric(
                                vertical: size.height * 0.02),
                            minimumSize: Size(double.infinity, buttonHeight),
                            // side: const BorderSide(
                            //   color: Colors.black,
                            //   width: 2,
                            // ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text(
                            'ต่อไป | NEXT',
                            style: TextStyle(
                              fontSize: 25.0,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
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
              // มาจาก NB80
              // IconButton(
              //   icon: const Icon(Icons.settings,
              //       color: Color.fromARGB(255, 255, 0, 0)),
              //   onPressed: () {
              //     Navigator.push(
              //       context,
              //       MaterialPageRoute(
              //         builder: (context) => SettingScreen(),
              //       ),
              //     );
              //   },
              // ),
              // IconButton(
              //   icon: const Icon(Icons.settings, color: Colors.white),
              //   onPressed: () {
              //     Navigator.push(
              //       context,
              //       MaterialPageRoute(
              //         builder: (context) => SettingScreen1(),
              //       ),
              //     );
              //   },
              // ),
            ],
          ),
        ),
      ),
    );
  }
}
