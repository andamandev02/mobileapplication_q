import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'App Apqueue',
      home: Scaffold(
        appBar: AppBar(title: Text('Welcome to App Apqueue')),
        body: Center(child: Text('Hello from Apqueue!')),
      ),
    );
  }
}
