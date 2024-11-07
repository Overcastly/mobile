import 'dart:collection';
import 'package:flutter/material.dart';
import '../views/map/map_main_view.dart';


class Map extends StatefulWidget {
  const Map({super.key});

  @override
  State<Map> createState() => _MapState();
}

class _MapState extends State<Map> {
  @override
  Widget build(BuildContext context) {
    return const MapView();
  }
}
