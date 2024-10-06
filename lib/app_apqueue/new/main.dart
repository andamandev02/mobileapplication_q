import 'package:flutter/material.dart';
import 'dart:async';

import 'domain.dart'; // For simulating loading process

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'App Apqueue',
      home: LoadingScreen(),
    );
  }
}

class LoadingScreen extends StatefulWidget {
  @override
  _LoadingScreenState createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen> {
  double progress = 0.0;

  @override
  void initState() {
    super.initState();
    Timer.periodic(Duration(milliseconds: 500), (timer) {
      setState(() {
        progress += 0.2;
        if (progress >= 1.0) {
          timer.cancel();
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const HomeScreen()),
          );
        }
      });
    });
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
                'assets/logo/GetImage.jpeg',
                width: screenWidth * 1.0,
                height: screenHeight * 0.4,
                fit: BoxFit.contain,
              ),
              SizedBox(height: screenSize.height * 0.05), // ปรับระยะห่าง
              SizedBox(
                width: screenWidth * 0.9,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(25), // ปรับขนาดให้เหมาะสม
                  child: LinearProgressIndicator(
                    value: progress, // ค่า progress ที่จะปรับ
                    backgroundColor: Colors.black,
                    valueColor:
                        const AlwaysStoppedAnimation<Color>(Colors.white),
                    minHeight: 8, // ปรับความสูงของ progress bar
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
