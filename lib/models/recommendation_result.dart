class RecommendationResult {
  final String centerId;
  final String centerName;
  final double latitude;
  final double longitude;
  final String scheduleVaccinesId;
  final String scheduleId;
  final DateTime date;
  final int availableSlots;

  RecommendationResult({
    required this.centerId,
    required this.centerName,
    required this.latitude,
    required this.longitude,
    required this.scheduleVaccinesId,
    required this.scheduleId,
    required this.date,
    required this.availableSlots,
  });

  factory RecommendationResult.fromJson(Map<String, dynamic> json) {
    return RecommendationResult(
      centerId: json['center_id'] as String,
      centerName: json['center_name'] as String,
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      scheduleVaccinesId: json['schedule_vaccines_id'] as String,
      scheduleId: json['schedule_id'] as String,
      date: DateTime.parse(json['date'] as String),
      availableSlots: json['available_slots'] as int,
    );
  }

  Map<String, dynamic> toJson() => {
    'center_id': centerId,
    'center_name': centerName,
    'latitude': latitude,
    'longitude': longitude,
    'schedule_vaccines_id': scheduleVaccinesId,
    'schedule_id': scheduleId,
    'date': date.toIso8601String(),
    'available_slots': availableSlots,
    };

  static List<RecommendationResult> fromJsonList(List<dynamic> jsonList) {
    return jsonList.map((json) => RecommendationResult.fromJson(json)).toList();
  }
}
