import 'package:beatrushhour/main_page.dart';
import 'package:flutter/material.dart';

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
          brightness: Brightness.dark,
          primarySwatch: Colors.green
      ),
      home: MyHomePage(),
    );
  }
}

void main() async {
  runApp(MyApp());
}
