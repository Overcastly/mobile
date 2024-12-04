import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MapView extends StatefulWidget {
  final LatLng? initialPosition;
  const MapView({super.key, this.initialPosition});

  @override
  State<MapView> createState() => _MapViewState();
}

class _MapViewState extends State<MapView> {
  late Future<MapController> _mapControllerFuture;
  late Future<void> _locationSetupFuture;
  MapController? mapController;

  bool _showRadarLayer = true;
  double _radarLayerOpacity = 0.5;
  bool _mapReady = false;

  @override
  void initState() {
    super.initState();
    _mapControllerFuture = _initializeMapController();
    _locationSetupFuture = _initializeLocation();
  }

  Future<MapController> _initializeMapController() async {
    final controller = MapController();
    await Future.delayed(const Duration(seconds: 1));
    return controller;
  }

  Future<void> _initializeLocation() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final lat = prefs.getString('latitude');
      final lon = prefs.getString('longitude');

      if (lat != null && lon != null) {
        print('Latitude from SharedPreferences: $lat');
        print('Longitude from SharedPreferences: $lon');

        if (mapController != null) {
          mapController!
              .move(LatLng(double.parse(lat), double.parse(lon)), 10.0);
        }
      } else {
        print('Using default location');
        if (mapController != null) {
          mapController!.move(const LatLng(28.567, -81.208), 10.0);
        }
      }

      setState(() {
        _mapReady = true;
      });
    } catch (e) {
      print('Error initializing location: $e');
      setState(() {
        _mapReady = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<MapController>(
      future: _mapControllerFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return const Center(child: Text('Error initializing map controller'));
        }

        mapController = snapshot.data!;

        return FutureBuilder<void>(
          future: _locationSetupFuture,
          builder: (context, locationSnapshot) {
            if (locationSnapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (locationSnapshot.hasError) {
              return const Center(child: Text('Error initializing location'));
            }

            if (!_mapReady) {
              return const Center(child: CircularProgressIndicator());
            }

            return Stack(
              children: [
                FlutterMap(
                  mapController: mapController!,
                  options: MapOptions(
                    initialCenter:
                        widget.initialPosition ?? const LatLng(28.567, -81.208),
                    initialZoom: 5,
                    minZoom: 2,
                    maxZoom: 18,
                  ),
                  children: [
                    TileLayer(
                      urlTemplate:
                          'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName: 'com.overcastly.app',
                    ),
                    if (_showRadarLayer)
                      TileLayer(
                        urlTemplate:
                            'https://mesonet.agron.iastate.edu/cache/tile.py/1.0.0/nexrad-n0q-900913/{z}/{x}/{y}.png',
                        tileBuilder: (context, child, tile) {
                          return Opacity(
                            opacity: _radarLayerOpacity,
                            child: child,
                          );
                        },
                      ),
                  ],
                ),
                Positioned(
                  top: 16,
                  right: 20,
                  child: Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    elevation: 0,
                    child: SizedBox(
                      width: 180,
                      height: 50,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: OverflowBox(
                          maxWidth: 180,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                onPressed: () {
                                  setState(() {
                                    _showRadarLayer = !_showRadarLayer;
                                  });
                                },
                                icon: Icon(
                                  Icons.radar,
                                  color: _showRadarLayer
                                      ? Colors.blue
                                      : Colors.grey,
                                  size: 24,
                                ),
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints.tightFor(
                                    width: 36, height: 36),
                              ),
                              Expanded(
                                child: Slider(
                                  value: _radarLayerOpacity,
                                  onChanged: (value) {
                                    setState(() {
                                      _radarLayerOpacity = value;
                                    });
                                  },
                                  min: 0.0,
                                  max: 1.0,
                                  divisions: 10,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                )
              ],
            );
          },
        );
      },
    );
  }
}
