
import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';
import 'package:location/location.dart';

import '../controller/location_controller.dart';

class MapScreen2 extends StatefulWidget {
  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen2> {
  List<LatLng> _routePoints = [];
  final MapController _mapController = MapController();
  Location _location = Location();
  LocationData? _currentLocation;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _loadRoutePoints();
    _startLocationUpdates();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _loadRoutePoints() async {

    final coordinates = await DatabaseHelper2.fetchCoordinates();


    setState(() {
      _routePoints = coordinates.map((coord) {
        return LatLng(coord['latitude'], coord['longitude']);
      }).toList();
    });

    // Optionally move the camera to the last known location
    if (_routePoints.isNotEmpty) {
      _mapController.move(_routePoints.last, 12.0);
    }
  }

  Future<void> _getCurrentLocation() async {
    _currentLocation = await _location.getLocation();
    if (mounted && _currentLocation != null) {
      setState(() {
        _mapController.move(
          LatLng(_currentLocation!.latitude!, _currentLocation!.longitude!),
          12.0,
        );
      });
    }
  }

  Future<void> _startLocationUpdates() async {
    _timer = Timer.periodic(Duration(seconds: 5), (Timer timer) async {
      final location = await _location.getLocation();
      if (mounted && location.latitude != null && location.longitude != null) {
        // Store the new coordinates in the database
        await DatabaseHelper2.insertCoordinate(
          location.latitude!,
          location.longitude!,
        );

        // Update the route points and refresh the map
        setState(() {
          _routePoints.add(LatLng(location.latitude!, location.longitude!));
        });

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
          initialCenter: _routePoints.isNotEmpty
              ? _routePoints.last
              : LatLng(10.0109696, 76.3132269),
          initialZoom: 12.0,
        ),
        children: [
          TileLayer(
            urlTemplate: "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
            subdomains: ['a', 'b', 'c'],
          ),
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
          MarkerLayer(
            markers: [
              if (_routePoints.isNotEmpty)
                Marker(
                  point: _routePoints.last,
                  width: 80.0,
                  height: 80.0,
                  child: Icon(
                    Icons.boy_rounded,
                    size: 30.0,
                    color: Colors.red,
                  ),
                ),
            ],
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _getCurrentLocation,
        child: Icon(Icons.my_location),
        tooltip: 'Go to Current Location',
      ),
    );
  }
}