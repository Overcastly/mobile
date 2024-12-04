class AlertData {
  final String event;
  final String severity;
  final String headline;
  final String description;
  final DateTime effective;
  final DateTime expires;

  AlertData({
    required this.event,
    required this.severity,
    required this.headline,
    required this.description,
    required this.effective,
    required this.expires,
  });

  factory AlertData.fromJson(Map<String, dynamic> json) {
    final properties = json['properties'];
    return AlertData(
      event: properties['event'] ?? 'Unknown Event',
      severity: properties['severity'] ?? 'Unknown',
      headline: properties['headline'] ?? 'No headline available',
      description: properties['description'] ?? 'No description available',
      effective: DateTime.parse(properties['effective'] ?? DateTime.now().toIso8601String()),
      expires: DateTime.parse(properties['expires'] ?? DateTime.now().toIso8601String()),
    );
  }

  bool get isActive => DateTime.now().isBefore(expires);
}