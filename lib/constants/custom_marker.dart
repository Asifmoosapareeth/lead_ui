import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class CustomMarker extends StatelessWidget {
  final String leadName;
  final LatLng position;

  CustomMarker({required this.leadName, required this.position});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: EdgeInsets.all(4.0),
          color: Colors.black.withOpacity(0.7),
          child: Text(
            leadName,
            style: TextStyle(color: Colors.white, fontSize: 12),
          ),
        ),
        Icon(
          Icons.location_pin,
          size: 40.0,
          color: Colors.red,
        ),
      ],
    );
  }
}
