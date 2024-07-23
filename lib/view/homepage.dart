import 'package:flutter/material.dart';
import 'package:lead_enquiry/view/firstpage.dart';

import 'package:lead_enquiry/view/add_data.dart';
import 'package:lead_enquiry/view/triall2.dart';



// import 'package:persistent_bottom_nav_bar_v2/persistent_bottom_nav_bar_v2.dart';
// import 'package:flutter/material.dart';
// import 'package:lead_enquiry/view/firstpage.dart';


class BottomNavBarDemo extends StatefulWidget {
  @override
  _BottomNavBarDemoState createState() => _BottomNavBarDemoState();
}

class _BottomNavBarDemoState extends State<BottomNavBarDemo> {
  int _selectedIndex = 0;

  static List<Widget> _widgetOptions = <Widget>[
    FirstPage(),
    Editpage(),
    // LeadForm()
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Bottom Navigation Bar Demo',
      home: Scaffold(
        body: Center(
          child: _widgetOptions.elementAt(_selectedIndex),
        ),
        bottomNavigationBar: BottomNavigationBar(
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Icon(Icons.list),
              label: 'List',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.edit),
              label: 'Create',
            ),
          ],
          currentIndex: _selectedIndex,
          selectedItemColor: Colors.teal.shade800,
          onTap: _onItemTapped,
        ),
      ),
    );
  }
}

void main() {
  runApp(BottomNavBarDemo());
}

// class PersistenBottomNavBarDemo extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//     debugShowCheckedModeBanner: false,
//       title: 'Persistent Bottom Navigation Bar Demo',
//       home: PersistentTabView(
//
//        screenTransitionAnimation: ScreenTransitionAnimation(
//          curve: Curves.linear
//        ),
//         tabs: [
//
//           PersistentTabConfig(
//             screen: FirstPage(),
//             item: ItemConfig(
//               icon: Icon(Icons.list),
//               title: "list",
//             ),
//           ),
//           PersistentTabConfig(
//             screen: Editpage(),
//             item: ItemConfig(
//               icon: Icon(Icons.edit),
//               title: "edit",
//             ),
//           ),
//         ],
//         navBarBuilder: (navBarConfig) => Style1BottomNavBar(
//           navBarConfig: navBarConfig,
//         ),
//
//       ),
//
//     );
//   }
// }


// import 'package:flutter/material.dart';
// import 'package:curved_navigation_bar/curved_navigation_bar.dart';
//
// class HomePage extends StatefulWidget {
//   const HomePage({super.key});
//
//   @override
//   State<HomePage> createState() => _HomePageState();
// }
//
// class _HomePageState extends State<HomePage> {
//   int index = 0;
//   GlobalKey<CurvedNavigationBarState> _bottomNavigationKey = GlobalKey();
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//        bottomNavigationBar: CurvedNavigationBar(
//
//          backgroundColor: Colors.blueAccent,
//          items: <Widget>[
//            Icon(Icons.edit, size: 30),
//            Icon(Icons.list, size: 30),
//          ],
//
//            onTap: (tappedindex) {
//              setState(() {
//                index = tappedindex;
//
//              }
//              );
//            },
//        ),
//       body: Container(
//         color: Colors.greenAccent,
//         child: Center(
//           child: Column(
//             children: [
//               ElevatedButton(
//                   onPressed: (){
//                     final CurvedNavigationBarState? navBarState =
//                         _bottomNavigationKey.currentState;
//                     navBarState?.setPage(0);
//                   },
//                   child: Text('go to next page'))
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
