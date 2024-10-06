import 'package:flutter/material.dart';
import '../domain.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animationOpacity;
  late Animation<Offset> _animationSlide;
  late List<String> _messages;
  int _currentMessageIndex = 0;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    );

    _animationOpacity = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    _animationSlide =
        Tween<Offset>(begin: Offset(0, 0), end: Offset(0, -1)).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    _messages = [
      'กำลังโหลด กรุณารอสักครู่...',
      'กำลังตรวจสอบความเสถียร...',
      'กำลังเปลี่ยนหน้า...',
    ];

    _startMessages();

    Future.delayed(const Duration(seconds: 6), () {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => MyHomePage()),
      );
    });
  }

  void _startMessages() async {
    for (int i = 0; i < _messages.length; i++) {
      setState(() {
        _currentMessageIndex = i;
      });

      _controller.forward();
      await Future.delayed(const Duration(seconds: 1));
      _controller.reverse();
      await Future.delayed(const Duration(seconds: 1));
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromRGBO(9, 159, 175, 1.0),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // แสดงรูปภาพด้านบน
            Image.asset('assets/logo/logo.png', width: 200, height: 200),
            const SizedBox(height: 20),
            // ใช้ Container เพื่อกำหนดขนาดของ LinearProgressIndicator
            Container(
              width: 200, // กำหนดความกว้างของ LinearProgressIndicator
              height: 10, // กำหนดความสูงของ LinearProgressIndicator
              child: const LinearProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(
                    Colors.white), // เปลี่ยนสีเป็นสีขาว
                backgroundColor:
                    Colors.transparent, // เปลี่ยนสีพื้นหลังให้โปร่งใส
              ),
            ),
            const SizedBox(height: 20),
            // การแสดงข้อความที่ค่อยๆ เลื่อนขึ้นและเปลี่ยนข้อความ
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: SlideTransition(
                position: _animationSlide,
                child: FadeTransition(
                  opacity: _animationOpacity,
                  child: Text(
                    _messages[_currentMessageIndex],
                    key: ValueKey<String>(_messages[_currentMessageIndex]),
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white, // เปลี่ยนสีข้อความเป็นสีขาว
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
