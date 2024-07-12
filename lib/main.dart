import 'package:flutter/material.dart';
import 'package:lead_enquiry/view/homepage.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() {
  runApp(

       MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',

      // home:  HomePage(),
      home: BottomNavBarDemo(),
      debugShowCheckedModeBanner: false,


    );
  }
}


