import 'package:flutter/material.dart';
import 'home_screen.dart';

void main() => runApp(CamFixXRApp());

class CamFixXRApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'CamFix XR',
      theme: ThemeData.dark(),
      home: HomeScreen(),
    );
  }
}
