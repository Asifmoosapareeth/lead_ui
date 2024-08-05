import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lead_enquiry/view/homepage.dart';
import 'package:lead_enquiry/view/loginpage.dart';
import 'package:shared_preferences/shared_preferences.dart';


void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? token = prefs.getString('token');
  runApp(MyApp(
      initialRoute: token != null ? '/home' : '/login'));

}

class MyApp extends StatelessWidget {
  final String initialRoute;
  const MyApp({super.key,required this.initialRoute});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      initialRoute: initialRoute ?? '/login',
      routes: {
        '/login': (context) => LoginPage(),
        '/home': (context) => BottomNavBarDemo(),
      },
      // home:  HomePage(),
      debugShowCheckedModeBanner: false,


    );
  }
}


