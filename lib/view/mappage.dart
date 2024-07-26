import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:http/http.dart' as http; // For HTTP requests
import 'dart:convert'; // For JSON decoding

import '../Model/leaddata_model.dart';

class MapScreen extends StatefulWidget {
  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  List<Lead> _leads = [];

  @override
  void initState() {
    super.initState();
    _fetchLeads();
    _leads;
  }

  Future<void> _fetchLeads() async {

      final response = await http.get(Uri.parse('http://127.0.0.1:8000/api/leads'));

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        final List<Lead> leads = data.map((json) => Lead.fromJson(json))
            .toList();

        setState(() {
          _leads = leads;
        });
      }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Leads Location'),
      ),
      body: FlutterMap(
        options: MapOptions(
          initialCenter: LatLng(10.0109696, 76.3132269),
          initialZoom: 12.0,
        ),
        children: [
          TileLayer(
            urlTemplate: "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
            subdomains: ['a', 'b', 'c'],
          ),
          MarkerLayer(
            markers: _leads.map((lead) {
              try {
                final lat = double.parse(lead.latitude);
                final lon = double.parse(lead.longitude);

                return Marker(
                  point: LatLng(lat, lon),
                  width: 80.0,
                  height: 80.0,
                  child: Icon(
                    Icons.location_pin,
                    size: 40.0,
                    color: Colors.red,
                  ),
                );
              } catch (e) {
                print('Error creating marker for lead ${lead.id}: $e');
                return null;
              }
            }).whereType<Marker>().toList(), // Filter out any null markers
          ),
        ],
      ),
    );
  }
}
