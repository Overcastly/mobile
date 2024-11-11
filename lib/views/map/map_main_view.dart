import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class MapView extends StatelessWidget {
  const MapView({super.key});

  @override
  Widget build(BuildContext context) {
    return FlutterMap(
      options: MapOptions(
        initialCenter: const LatLng(38.7946, -98.5),
        cameraConstraint: CameraConstraint.contain(
            bounds: LatLngBounds(
              const LatLng(-90, -180.0), const LatLng(90.0, 180.0),
            ),
        ),
        initialZoom: 4,
        minZoom: 2,
        interactionOptions: const InteractionOptions(flags: ~InteractiveFlag.doubleTapZoom),
      ),
      children: [
        openStreetMapTileLayer,
        //arcGISTileLayer,
      ],
    );
  }
}

TileLayer get openStreetMapTileLayer => TileLayer (
  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
  userAgentPackageName: 'com.overcastly.app',
);

/*
TileLayer get arcGISTileLayer => TileLayer(
  urlTemplate: 'https://mapservices.weather.noaa.gov/eventdriven/rest/services/radar/radar_base_reflectivity/MapServer',
);
 */