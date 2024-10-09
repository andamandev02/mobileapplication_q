import 'dart:async';
import 'dart:developer' as developer;
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';

import '../domain/domainscreen.dart';
import '../provider/provider.dart';

class LoadingStart extends StatefulWidget {
  @override
  _LoadingStartState createState() => _LoadingStartState();
}

class _LoadingStartState extends State<LoadingStart> {
  double progress = 0.0;

  @override
  void initState() {
    super.initState();
    Timer.periodic(const Duration(milliseconds: 500), (timer) {
      setState(() {
        progress += 0.2;
        if (progress >= 1.0) {
          timer.cancel();
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const DomainScreen()),
          );
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final hiveData = Provider.of<DataProvider>(context);

    final Size screenSize = MediaQuery.of(context).size;
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: hiveData.colorValue,
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
