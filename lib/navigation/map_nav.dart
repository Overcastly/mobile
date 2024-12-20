import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import '../views/map/map_main_view.dart';

class Map extends StatefulWidget {
  final LatLng? initialPosition;
  
  const Map({super.key, this.initialPosition});

  @override
  State<Map> createState() => _MapState();
}

class _MapState extends State<Map> {
  @override
  Widget build(BuildContext context) {
    return MapView(initialPosition: widget.initialPosition);
  }
}