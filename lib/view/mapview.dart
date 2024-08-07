// import 'package:flutter/material.dart';
// import 'package:google_maps_flutter/google_maps_flutter.dart';
// import 'package:http/http.dart' as http;
// import 'dart:convert';
// import 'details.dart';
// import '../Model/leaddata_model.dart';
//
// class MapView extends StatefulWidget {
//   @override
//   _MapViewState createState() => _MapViewState();
// }
//
// class _MapViewState extends State<MapView> {
//   List<Lead> _leads = [];
//   Set<Marker> _markers = {};
//   Set<Polyline> _polylines = {};
//   GoogleMapController? _mapController;
//   LatLng? _initialPosition;
//
//   @override
//   void initState() {
//     super.initState();
//     _fetchLeads();
//   }
//
//   Future<void> _fetchLeads() async {
//     final response = await http.get(Uri.parse('http://127.0.0.1:8000/api/leads'));
//
//     if (response.statusCode == 200) {
//       final List<dynamic> data = json.decode(response.body);
//       final List<Lead> leads = data.map((json) => Lead.fromJson(json)).toList();
//
//       setState(() {
//         _leads = leads;
//         _markers = leads.map((lead) {
//           return Marker(
//             markerId: MarkerId(lead.id.toString()),
//             position: LatLng(double.parse(lead.latitude), double.parse(lead.longitude)),
//             infoWindow: InfoWindow(
//               title: lead.name,
//               snippet: lead.address,
//               onTap: () => _showLeadDetails(lead),
//             ),
//           );
//         }).toSet();
//
//         if (_leads.isNotEmpty) {
//           _initialPosition = LatLng(double.parse(_leads[0].latitude), double.parse(_leads[0].longitude));
//
//           // if (_leads.length > 1) {
//           //   _getPolyline(
//           //     LatLng(double.parse(_leads[0].latitude), double.parse(_leads[0].longitude)),
//           //     LatLng(double.parse(_leads[1].latitude), double.parse(_leads[1].longitude)),
//           //   ).then((polyline) {
//           //     setState(() {
//           //       _polylines.add(polyline);
//           //       print("Polyline added: ${polyline.points.length} points");
//           //     });
//           //   }).catchError((error) {
//           //     print("Error fetching polyline: $error");
//           //   });
//           // }
//         }
//       });
//     } else {
//       print('Failed to load leads');
//     }
//   }
//
//   // Future<Polyline> _getPolyline(LatLng start, LatLng end) async {
//   //   final apiKey = 'AIzaSyCDOidDJXTQw22amDUV6lRWlx7i3jr2vsI';
//   //   final url =
//   //       'https://maps.googleapis.com/maps/api/directions/json?origin=${start.latitude},${start.longitude}&destination=${end.latitude},${end.longitude}&key=$apiKey';
//   //
//   //   final response = await http.get(Uri.parse(url));
//   //   if (response.statusCode == 200) {
//   //     final data = json.decode(response.body);
//   //     print("Directions API Response: ${data}");
//   //
//   //     final encodedPoints = data['routes'][0]['overview_polyline']['points'];
//   //     final points = _decodePoly(encodedPoints);
//   //
//   //     return Polyline(
//   //       polylineId: PolylineId('route'),
//   //       color: Colors.blue,
//   //       width: 5,
//   //       points: points,
//   //     );
//   //   } else {
//   //     throw Exception('Failed to load route');
//   //   }
//   // }
//
//   // List<LatLng> _decodePoly(String encoded) {
//   //   List<LatLng> poly = [];
//   //   int index = 0, len = encoded.length;
//   //   int lat = 0, lng = 0;
//   //
//   //   while (index < len) {
//   //     int b, shift = 0, result = 0;
//   //     do {
//   //       b = encoded.codeUnitAt(index++) - 63;
//   //       result |= (b & 0x1f) << shift;
//   //       shift += 5;
//   //     } while (b >= 0x20);
//   //     int dlat = (result & 1) != 0 ? ~(result >> 1) : (result >> 1);
//   //     lat += dlat;
//   //
//   //     shift = 0;
//   //     result = 0;
//   //     do {
//   //       b = encoded.codeUnitAt(index++) - 63;
//   //       result |= (b & 0x1f) << shift;
//   //       shift += 5;
//   //     } while (b >= 0x20);
//   //     int dlng = (result & 1) != 0 ? ~(result >> 1) : (result >> 1);
//   //     lng += dlng;
//   //
//   //     poly.add(LatLng(
//   //       (lat / 1E5).toDouble(),
//   //       (lng / 1E5).toDouble(),
//   //     ));
//   //   }
//   //
//   //   return poly;
//   // }
//
//   void _showLeadDetails(Lead lead) {
//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: Row(
//           children: [
//             CircleAvatar(
//               backgroundImage: NetworkImage('http://127.0.0.1:8000/storage/${lead.image_path}'),
//               radius: 20,
//             ),
//             SizedBox(width: 10),
//             Text(lead.name),
//           ],
//         ),
//         content: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             Text('Address: ${lead.address}'),
//             Text('Mobile: ${lead.contactNumber}'),
//           ],
//         ),
//         actions: [
//           TextButton(
//             onPressed: () {
//               Navigator.of(context).pop();
//               Navigator.push(
//                 context,
//                 MaterialPageRoute(
//                   builder: (context) => DetailsPage(lead: lead),
//                 ),
//               );
//             },
//             child: Text(
//               'Details',
//               style: TextStyle(
//                 fontSize: 16,
//                 color: Colors.teal,
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//           ),
//           TextButton(
//             onPressed: () => Navigator.of(context).pop(),
//             child: Text('Close'),
//           ),
//         ],
//       ),
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Leads Location'),
//       ),
//       body: _initialPosition == null
//           ? Center(child: CircularProgressIndicator())
//           : GoogleMap(
//         // cameraTargetBounds: CameraTargetBounds.unbounded,
//         mapType: MapType.terrain,
//         compassEnabled: true,
//         myLocationButtonEnabled: true,
//         myLocationEnabled: true,
//         onMapCreated: (controller) => _mapController = controller,
//         initialCameraPosition: CameraPosition(
//           target: _initialPosition!,
//           zoom: 12.0,
//         ),
//         markers: _markers,
//         // polylines: _polylines,
//       ),
//
//     );
//
//   }
// }
