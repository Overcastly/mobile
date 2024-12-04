import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:logging/logging.dart';
import 'package:mobile/views/map/map_main_view.dart';
import 'package:mobile/navigation/map_nav.dart';
import 'package:mobile/views/dashboard/services/alert_data.dart';
import 'package:mobile/views/dashboard/services/alert_service.dart';
import 'package:mobile/views/dashboard/services/weather_data.dart';
import 'package:mobile/views/dashboard/services/weather_service.dart';

final _logger = Logger('DashboardView');

class DashboardView extends StatefulWidget {
  const DashboardView({super.key});

  @override
  State<DashboardView> createState() => _DashboardViewState();
}

class _DashboardViewState extends State<DashboardView> {
  final AlertService _alertService = AlertService();
  final WeatherService _weatherService = WeatherService();
  List<AlertData> advisories = [];
  WeatherData? weatherData;
  SharedPreferences? _prefs;
  bool isMetric = true;

  @override
  void initState() {
    super.initState();
    _initPrefs();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadData();
  }

  Future<void> _initPrefs() async {
    _prefs = await SharedPreferences.getInstance();
    isMetric = _prefs?.getBool('useMetric') ?? true;
    _loadData();
  }

  void _toggleUnits() {
    setState(() {
      isMetric = !isMetric;
      _prefs?.setBool('useMetric', isMetric);
    });
  }

  String _formatTemperature(double temp) {
    return isMetric
        ? '${temp.toStringAsFixed(1)}°C'
        : '${(temp * 9 / 5 + 32).toStringAsFixed(1)}°F';
  }

  String _formatSpeed(double speed) {
    return isMetric
        ? '${speed.toStringAsFixed(1)} km/h'
        : '${(speed * 0.621371).toStringAsFixed(1)} mph';
  }

  String _formatPressure(double pressure) {
    if (isMetric) {
      double hpa = pressure / 100;
      return '${hpa.toStringAsFixed(0)} hPa';
    } else {
      double inHg = pressure / 3386.39;
      return '${inHg.toStringAsFixed(2)} inHg';
    }
  }

  String _formatVisibility(double visibility) {
    if (isMetric) {
      double km = visibility / 1000;
      return '${km.toStringAsFixed(1)} km';
    } else {
      double miles = visibility / 1609.34;
      return '${miles.toStringAsFixed(1)} mi';
    }
  }

  String _formatPrecipitation(double precipitation) {
    if (isMetric) {
      return '${precipitation.toStringAsFixed(1)} mm';
    } else {
      double inches = precipitation / 25.4;
      return '${inches.toStringAsFixed(2)} in';
    }
  }

  Future<void> _loadData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final lat = double.parse(prefs.getString('latitude') ?? '28.567');
      final lon = double.parse(prefs.getString('longitude') ?? '-81.208');

      final gridPoint = await _weatherService.getGridPoint(lat, lon);
      final conditions = await _weatherService
          .getCurrentConditions(gridPoint['properties']['observationStations']);

      if (mounted) {
        setState(() {
          weatherData = WeatherData.fromJson(conditions);
        });
      }

      final alertsResponse = await _alertService.getAlerts(lat, lon);
      if (mounted) {
        setState(() {
          advisories = (alertsResponse['features'] as List)
              .map((feature) => AlertData.fromJson(feature))
              .where((alert) => alert.isActive)
              .toList();
        });
      }
    } catch (e) {
      _logger.warning('Error loading data: $e');
    }
  }

  Widget _buildWeatherStat(String value, String label, String sublabel) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            color: Colors.grey,
          ),
        ),
        if (sublabel.isNotEmpty)
          Text(
            sublabel,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.grey,
            ),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(15),
                child: GestureDetector(
                  onDoubleTap: () {
                    final mapController =
                        (context.findRenderObject() as RenderBox)
                            .localToGlobal(Offset.zero);
                    final position = mapController.dx;

                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const Map(),
                      ),
                    );
                  },
                  child: const SizedBox(
                    height: 200,
                    width: double.infinity,
                    child: MapView(),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              if (weatherData != null)
                Card(
                  child: Column(
                    children: [
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: _toggleUnits,
                          child: Text(isMetric
                              ? 'Switch to Imperial'
                              : 'Switch to Metric'),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Wrap(
                          spacing: 20,
                          runSpacing: 20,
                          alignment: WrapAlignment.spaceAround,
                          children: [
                            _buildWeatherStat(
                              _formatTemperature(weatherData!.temperature),
                              'Temperature',
                              weatherData!.description,
                            ),
                            _buildWeatherStat(
                              _formatSpeed(weatherData!.windSpeed),
                              'Wind Speed',
                              weatherData!.windDirection,
                            ),
                            _buildWeatherStat(
                              '${weatherData!.humidity.toStringAsFixed(0)}%',
                              'Humidity',
                              '',
                            ),
                            _buildWeatherStat(
                              _formatPressure(weatherData!.pressure),
                              'Pressure',
                              '',
                            ),
                            _buildWeatherStat(
                              _formatVisibility(weatherData!.visibility),
                              'Visibility',
                              '',
                            ),
                            _buildWeatherStat(
                              _formatPrecipitation(weatherData!.precipitation),
                              'Precipitation',
                              '',
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: 16),
              if (advisories.isEmpty)
                const Card(
                  child: Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Text(
                      'There are no current advisories for your area.',
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                )
              else
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: advisories.length,
                  itemBuilder: (context, index) {
                    final advisory = advisories[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: Card(
                        margin: const EdgeInsets.symmetric(horizontal: 4.0),
                        color: Colors.orange,
                        child: ListTile(
                          title: Text(
                            advisory.headline,
                            style: const TextStyle(color: Colors.white),
                          ),
                          subtitle: Text(
                            advisory.description,
                            style: const TextStyle(color: Colors.white70),
                          ),
                        ),
                      ),
                    );
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }
}