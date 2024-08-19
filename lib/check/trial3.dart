// import 'package:flutter/material.dart';
// import 'package:geolocator/geolocator.dart';
// import 'dart:async';
// import '../controller/sqflite_controller.dart';
// import 'helper_sqflite.dart';
//
// class LocationFetcher extends StatefulWidget {
//   @override
//   _LocationFetcherState createState() => _LocationFetcherState();
// }
//
// class _LocationFetcherState extends State<LocationFetcher> {
//   List<Map<String, dynamic>> _positions = [];
//   Timer? _timer;
//   final DatabaseHelper _dbHelper = DatabaseHelper();
//
//   @override
//   void initState() {
//     super.initState();
//     _checkPermissionAndFetchLocation();
//     _startLocationTimer();
//     _loadLocationsFromDatabase();
//   }
//
//   @override
//   void dispose() {
//     _timer?.cancel();
//     super.dispose();
//   }
//
//   Future<void> _checkPermissionAndFetchLocation() async {
//     bool serviceEnabled;
//     LocationPermission permission;
//
//     serviceEnabled = await Geolocator.isLocationServiceEnabled();
//     if (!serviceEnabled) {
//       print('Location services are disabled.');
//       return Future.error('Location services are disabled.');
//     }
//
//     permission = await Geolocator.checkPermission();
//     if (permission == LocationPermission.denied) {
//       permission = await Geolocator.requestPermission();
//       if (permission == LocationPermission.denied) {
//         print('Location permissions are denied');
//         return Future.error('Location permissions are denied');
//       }
//     }
//
//     if (permission == LocationPermission.deniedForever) {
//       print('Location permissions are permanently denied.');
//       return Future.error(
//           'Location permissions are permanently denied, we cannot request permissions.');
//     }
//
//     print('Location permission granted.');
//     _fetchLocation();
//   }
//
//   void _startLocationTimer() {
//     _timer = Timer.periodic(Duration(seconds: 10), (timer) {
//       _fetchLocation();
//     });
//   }
//
//   Future<void> _fetchLocation() async {
//     try {
//       Position position = await Geolocator.getCurrentPosition(
//           desiredAccuracy: LocationAccuracy.high);
//       String timestamp = DateTime.now().toIso8601String();
//
//
//       await _dbHelper.insertLocation(position.latitude, position.longitude, timestamp);
//
//       await _loadLocationsFromDatabase();
//
//
//     } catch (e) {
//       print('Error fetching location: $e');
//     }
//   }
//
//   Future<void> _loadLocationsFromDatabase() async {
//
//     List<Map<String, dynamic>> locations = await _dbHelper.getLocations();
//     print('Loaded locations: $locations');
//     setState(() {
//       _positions = locations;
//     });
//   }
//
//   Future<void> _retrieveAndPrintLocations() async {
//     List<Map<String, dynamic>> locations = await _dbHelper.getLocations();
//     for (var location in locations) {
//       print('Latitude: ${location['latitude']}, Longitude: ${location['longitude']}, Timestamp: ${location['timestamp']}');
//     }
//   }
//
//   Future<void> _deleteLocation(int id) async {
//     await _dbHelper.deleteLocation(id);
//     await _loadLocationsFromDatabase();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Location Fetcher'),
//       ),
//       body: _positions.isEmpty
//           ? Center(child: CircularProgressIndicator())
//           : ListView.builder(
//         itemCount: _positions.length,
//         itemBuilder: (context, index) {
//           final position = _positions[index];
//           return ListTile(
//             title: Text(
//               'Latitude: ${position['latitude']}, Longitude: ${position['longitude']}',
//             ),
//             subtitle: Text('Timestamp: ${position['timestamp']}'),
//             trailing: IconButton(
//               icon: Icon(Icons.delete),
//               onPressed: () => _deleteLocation(position['id']),
//             ),
//           );
//         },
//       ),
//       floatingActionButton: FloatingActionButton(
//         onPressed: _retrieveAndPrintLocations,
//         child: Icon(Icons.print),
//       ),
//     );
//   }
// }
