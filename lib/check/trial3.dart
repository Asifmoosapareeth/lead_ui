// import 'package:flutter/material.dart';
//
// void main() => runApp(MyApp());
//
// class MyApp extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       home: Scaffold(
//         backgroundColor: Colors.black,
//         body: CallCardList(),
//       ),
//     );
//   }
// }
//
// class CallCardList extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return ListView.builder(
//       itemCount: 2,
//       itemBuilder: (context, index) {
//         return Padding(
//           padding: const EdgeInsets.all(8.0),
//           child: CallCard(),
//         );
//       },
//     );
//   }
// }
//
// class CallCard extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       color: Colors.black,
//       child: Stack(
//         children: [
//           ClipPath(
//             clipper: CallCardClipper(),
//             child: Container(
//               width: 320,
//               padding: EdgeInsets.all(16.0),
//               color: Color(0xFFA6FF4D),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   SizedBox(height: 40),  // Adjust height to place content below the curved corner
//                   Row(
//                     children: [
//                       CircleAvatar(
//                         radius: 25,
//                         backgroundImage: NetworkImage('https://via.placeholder.com/50'),
//                       ),
//                       SizedBox(width: 10),
//                       Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Text(
//                             'Peter Thomas',
//                             style: TextStyle(
//                               fontWeight: FontWeight.bold,
//                               fontSize: 16,
//                             ),
//                           ),
//                           Text(
//                             'CEO at Modtra Ink',
//                             style: TextStyle(
//                               fontSize: 12,
//                               color: Colors.grey[700],
//                             ),
//                           ),
//                         ],
//                       ),
//                       Spacer(),
//                     ],
//                   ),
//                   SizedBox(height: 20),
//                   Row(
//                     children: [
//                       Icon(Icons.video_call, size: 40, color: Colors.black),
//                       SizedBox(width: 10),
//                       Text(
//                         'Google Meet Call',
//                         style: TextStyle(
//                           fontWeight: FontWeight.bold,
//                           fontSize: 18,
//                         ),
//                       ),
//                     ],
//                   ),
//                   SizedBox(height: 10),
//                   Row(
//                     children: [
//                       CircleAvatar(
//                         radius: 15,
//                         backgroundImage: NetworkImage('https://via.placeholder.com/30'),
//                       ),
//                       SizedBox(width: 5),
//                       CircleAvatar(
//                         radius: 15,
//                         backgroundImage: NetworkImage('https://via.placeholder.com/30'),
//                       ),
//                       SizedBox(width: 10),
//                       Text(
//                         '28.03.2023 at 2 pm',
//                         style: TextStyle(
//                           fontSize: 12,
//                           color: Colors.black,
//                         ),
//                       ),
//                     ],
//                   ),
//                   SizedBox(height: 20),
//                   Row(
//                     children: [
//                       Icon(Icons.circle, size: 20, color: Colors.green),
//                       SizedBox(width: 10),
//                       Text(
//                         'Call scheduled',
//                         style: TextStyle(
//                           fontWeight: FontWeight.bold,
//                           fontSize: 14,
//                         ),
//                       ),
//                       Spacer(),
//                       IconButton(
//                         icon: Icon(Icons.email, color: Colors.black),
//                         onPressed: () {},
//                       ),
//                       IconButton(
//                         icon: Icon(Icons.videocam, color: Colors.black),
//                         onPressed: () {},
//                       ),
//                     ],
//                   ),
//                 ],
//               ),
//             ),
//           ),
//           Positioned(
//             right: 0,
//             top: 0,
//             child: CircleAvatar(
//               radius: 25,
//               backgroundColor: Colors.black,
//               child: Icon(Icons.notifications, color: Colors.white),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
//
// class CallCardClipper extends CustomClipper<Path> {
//   @override
//   Path getClip(Size size) {
//     final path = Path();
//     path.lineTo(0, size.height - 50);
//     path.quadraticBezierTo(0, size.height, 50, size.height);
//     path.lineTo(size.width - 10, size.height);
//     path.quadraticBezierTo(size.width, size.height, size.width, size.height - 10);
//     path.lineTo(size.width, 60);
//     path.arcToPoint(Offset(size.width - 60, 0), radius: Radius.circular(60), clockwise: false);
//     path.lineTo(50, 0);
//     path.quadraticBezierTo(0, 0, 0, 50);
//     path.close();
//     return path;
//   }
//
//   @override
//   bool shouldReclip(CustomClipper<Path> oldClipper) => false;
// }
