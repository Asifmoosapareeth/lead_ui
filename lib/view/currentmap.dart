import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:http/http.dart' as http;
import 'package:location/location.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../Model/leaddata_model.dart';
import '../constants/custom_marker.dart';
import '../controller/sqflite_controller.dart';
import 'details.dart';

class MapScreen2 extends StatefulWidget {
  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen2> {
  // List<Lead> _leads = [];
  List<LatLng> _routePoints = [];
  final MapController _mapController = MapController();
  Location _location = Location();
  // bool _serviceEnabled = false;
  // PermissionStatus _permissionGranted = PermissionStatus.denied;
  LocationData? _currentLocation;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    // _checkPermissions();
    // _fetchLeads();
    _startLocationUpdates();

  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _getCurrentLocation() async {
    _currentLocation = await _location.getLocation();
    if (mounted && _currentLocation != null) {
      setState(() {
        _mapController.move(
          LatLng(_currentLocation!.latitude!, _currentLocation!.longitude!),
          10.0,
        );
      });
    }
  }

  Future<void> _startLocationUpdates() async {
    _timer = Timer.periodic(Duration(seconds: 5), (Timer timer) async {
      final LocationData location = await _location.getLocation();
      if (mounted && location.latitude != null && location.longitude != null) {
        setState(() {
          _routePoints.add(LatLng(location.latitude!, location.longitude!));
        });


        // _mapController.move(LatLng(location.latitude!, location.longitude!), 12.0);


        if (_routePoints.length > 1) {
          _fetchRoute(_routePoints);
        }
      }
    });
  }

  Future<void> _fetchRoute(List<LatLng> points) async {
    final baseurl = "https://api.openrouteservice.org/v2/directions/driving-car?";
    final apiKey = "5b3ce3597851110001cf6248f19c82acc94f48e0b7e54b5f5de7bb0a";
    final coordinates = points.map((point) => [point.longitude, point.latitude]).toList();

    final body = json.encode({
      "coordinates": coordinates,
    });

    final response = await http.post(
      Uri.parse(baseurl),
      headers: {
        'Authorization': apiKey,
        'Content-Type': 'application/json',
      },
      body: body,
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final coordinates = data['features'][0]['geometry']['coordinates'];
      if (mounted) {
        setState(() {
          _routePoints = coordinates.map<LatLng>((coord) {
            return LatLng(coord[1], coord[0]);
          }).toList();
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Leads Location'),
      ),
      body: FlutterMap(
        mapController: _mapController,
        options: MapOptions(
          initialCenter: _currentLocation != null
              ? LatLng(_currentLocation!.latitude!, _currentLocation!.longitude!)
              : LatLng(10.0109696, 76.3132269),
          initialZoom: 12.0,
        ),
        children: [
          TileLayer(
            urlTemplate: "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
            subdomains: ['a', 'b', 'c'],
          ),
          // MarkerLayer(
          //   markers: [
          //     if (_currentLocation != null)
          //       Marker(
          //         point: LatLng(_currentLocation!.latitude!, _currentLocation!.longitude!),
          //         width: 80.0,
          //         height: 80.0,
          //         child: Icon(
          //           Icons.location_pin,
          //           size: 40.0,
          //           color: Colors.blue,
          //         ),
          //       ),
          //     ..._leads.map((lead) {
          //       try {
          //         final lat = double.parse(lead.latitude);
          //         final lon = double.parse(lead.longitude);
          //         return Marker(
          //           point: LatLng(lat, lon),
          //           width: 80.0,
          //           height: 80.0,
          //           child: GestureDetector(
          //             onTap: () {}, // Handle marker tap
          //             child: Icon(
          //               Icons.location_pin,
          //               size: 40.0,
          //               color: Colors.red,
          //             ),
          //           ),
          //         );
          //       } catch (e) {
          //         print('Error creating marker for lead ${lead.id}: $e');
          //         return null;
          //       }
          //     }).whereType<Marker>().toList(),
          //   ],
          // ),
          PolylineLayer(
            polylines: [
              if (_routePoints.isNotEmpty)
                Polyline(
                  points: _routePoints,
                  strokeWidth: 4.0,
                  strokeJoin: StrokeJoin.bevel,
                  color: Colors.blue,
                ),
            ],
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: ()=> _getCurrentLocation,
        child: Icon(Icons.my_location),
        tooltip: 'Go to Current Location',
      ),
    );
  }
}
