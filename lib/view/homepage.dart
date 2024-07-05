import 'package:flutter/material.dart';
import 'package:lead_enquiry/view/dropdown.dart';
import 'package:lead_enquiry/view/editpage.dart';
import 'package:persistent_bottom_nav_bar_v2/persistent_bottom_nav_bar_v2.dart';

class PersistenBottomNavBarDemo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
    debugShowCheckedModeBanner: false,
      title: 'Persistent Bottom Navigation Bar Demo',
      home: PersistentTabView(

       screenTransitionAnimation: ScreenTransitionAnimation(
         curve: Curves.linear
       ),
        // floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        // floatingActionButton: SizedBox(
        //   width: 100,height: 40,
        //   child: ElevatedButton(
        //       onPressed: (){},
        //       child: Text('+',style: TextStyle(fontSize: 15),)),
        // ),
        tabs: [

          PersistentTabConfig(
            screen: Dropdown(),
            item: ItemConfig(
              icon: Icon(Icons.list),
              title: "list",
            ),
          ),
          PersistentTabConfig(
            screen: Editpage(),
            item: ItemConfig(
              icon: Icon(Icons.edit),
              title: "edit",
            ),
          ),
        ],
        navBarBuilder: (navBarConfig) => Style1BottomNavBar(
          navBarConfig: navBarConfig,
        ),

      ),

    );
  }
}


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
