// import 'package:flutter/material.dart';
// import 'package:flutter_map/flutter_map.dart';
// import 'package:latlong2/latlong.dart';
// import 'package:http/http.dart' as http;
// import 'package:location/location.dart';
// import 'dart:convert';
//
// import '../Model/leaddata_model.dart';
// import '../constants/custom_marker.dart';
// import 'details.dart';
//
// class MapScreen extends StatefulWidget {
//   @override
//   _MapScreenState createState() => _MapScreenState();
// }
//
// class _MapScreenState extends State<MapScreen> {
//   List<Lead> _leads = [];
//   List<LatLng> _routePoints = [];
//   final MapController _mapController = MapController();
//   Location _location = Location();
//   bool _serviceEnabled = false;
//   PermissionStatus _permissionGranted = PermissionStatus.denied;
//   LocationData? _currentLocation;
//
//   @override
//   void initState() {
//     super.initState();
//     _checkPermissions();
//     _fetchLeads();
//   }
//
//   Future<void> _checkPermissions() async {
//     _serviceEnabled = await _location.serviceEnabled();
//     if (!_serviceEnabled) {
//       _serviceEnabled = await _location.requestService();
//       if (!_serviceEnabled) {
//         return;
//       }
//     }
//
//     _permissionGranted = await _location.hasPermission();
//     if (_permissionGranted == PermissionStatus.denied) {
//       _permissionGranted = await _location.requestPermission();
//       if (_permissionGranted != PermissionStatus.granted) {
//         return;
//       }
//     }
//
//     _getCurrentLocation();
//   }
//
//   Future<void> _getCurrentLocation() async {
//     _currentLocation = await _location.getLocation();
//     if (_currentLocation != null) {
//       _mapController.move(
//         LatLng(_currentLocation!.latitude!, _currentLocation!.longitude!),
//         12.0,
//       );
//     }
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
//       });
//
//       if (_leads.length >= 2) {
//         _fetchRoute(
//           LatLng(double.parse(_leads[1].latitude), double.parse(_leads[1].longitude)),
//           LatLng(double.parse(_leads[4].latitude), double.parse(_leads[4].longitude)),
//         );
//       }
//     }
//   }
//
//   Future<void> _fetchRoute(LatLng origin, LatLng destination) async {
//     final baseurl = "https://api.openrouteservice.org/v2/directions/driving-car?";
//     final apiKey = "5b3ce3597851110001cf6248f19c82acc94f48e0b7e54b5f5de7bb0a";
//     final response = await http.get(
//       Uri.parse(
//         '$baseurl&api_key=$apiKey&start=${origin.longitude},${origin.latitude}&end=${destination.longitude},${destination.latitude}',
//       ),
//     );
//
//     if (response.statusCode == 200) {
//       final data = json.decode(response.body);
//       final coordinates = data['features'][0]['geometry']['coordinates'];
//       setState(() {
//         _routePoints = coordinates.map<LatLng>((coord) {
//           return LatLng(coord[1], coord[0]);
//         }).toList();
//       });
//     }
//   }
//
//   void _onMarkerTap(Lead lead) {
//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: Row(
//           children: [
//             CircleAvatar(
//               backgroundImage: NetworkImage('http://127.0.0.1:8000/storage/${lead.image_path}'),
//               radius: 25,
//             ),
//             SizedBox(width: 10),
//             Expanded(
//               child: Text(
//                 'Lead Details',
//                 style: TextStyle(
//                   fontSize: 18,
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//             ),
//           ],
//         ),
//         content: SingleChildScrollView(
//           child: Column(
//             mainAxisSize: MainAxisSize.min, // Prevents the dialog from expanding unnecessarily
//             children: [
//               ListTile(
//                 title: Text('Name'),
//                 subtitle: Text(lead.name),
//               ),
//               ListTile(
//                 title: Text('Address'),
//                 subtitle: Text(lead.address),
//               ),
//               ListTile(
//                 title: Text('Mobile'),
//                 subtitle: Text(lead.contactNumber),
//               ),
//               SizedBox(height: 10), // Adds space before the Details button
//               TextButton(
//                 onPressed: () {
//                   Navigator.of(context).pop(); // Close the dialog
//                   Navigator.push(
//                     context,
//                     MaterialPageRoute(
//                       builder: (context) => DetailsPage(lead: lead),
//                     ),
//                   );
//                 },
//                 child: Text(
//                   'Details',
//                   style: TextStyle(
//                     fontSize: 16,
//                     color: Colors.teal,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.of(context).pop(),
//             child: Text('Close'),
//           ),
//         ],
//       ),
//     );
//   }
//
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Leads Location'),
//       ),
//       body: FlutterMap(
//         mapController: _mapController,
//         options: MapOptions(
//           initialCenter: LatLng(10.0109696, 76.3132269),
//           initialZoom: 12.0,
//         ),
//         children: [
//           TileLayer(
//             urlTemplate: "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
//             subdomains: ['a', 'b', 'c'],
//           ),
//           MarkerLayer(
//             markers: _leads.map((lead) {
//               try {
//                 final lat = double.parse(lead.latitude);
//                 final lon = double.parse(lead.longitude);
//
//                 return Marker(
//                   point: LatLng(lat, lon),
//                   width: 80.0,
//                   height: 80.0,
//                   child: GestureDetector(
//                     onTap: () => _onMarkerTap(lead), // Handle marker tap
//                     child:
//                     Icon(
//                       Icons.location_pin,
//                       size: 40.0,
//                       color: Colors.red,
//                     ),
//                     // CustomMarker(leadName: lead.name, position: LatLng(lat, lon))
//                   ),
//                 );
//               } catch (e) {
//                 print('Error creating marker for lead ${lead.id}: $e');
//                 return null;
//               }
//             }).whereType<Marker>().toList(),
//           ),
//           PolylineLayer(
//             polylines: [
//               if (_routePoints.isNotEmpty)
//                 Polyline(
//                   points: _routePoints,
//                   strokeWidth: 4.0,
//                   color: Colors.blue,
//                 ),
//             ],
//           ),
//         ],
//       ),
//       floatingActionButton: FloatingActionButton(
//         onPressed: _getCurrentLocation,
//         child: Icon(Icons.my_location),
//         tooltip: 'Go to Current Location',
//       ),
//     );
//   }
// }
// // AIzaSyCDOidDJXTQw22amDUV6lRWlx7i3jr2vsI
