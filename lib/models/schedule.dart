class Schedule {
  final String id;
  final String centerId;
  final DateTime? date;
  final DateTime? beginAt;
  final DateTime? endAt;

  Schedule({
    required this.id,
    required this.centerId,
    this.date,
    this.beginAt,
    this.endAt,
  });

  factory Schedule.fromJson(Map<String, dynamic> json) {
    return Schedule(
      id: json['id'],
      centerId: json['center_id'],
      date: json['date'] != null ? DateTime.parse(json['date']) : null,
      beginAt: json['begin_at'] != null ? DateTime.parse(json['begin_at']) : null,
      endAt: json['end_at'] != null ? DateTime.parse(json['end_at']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'center_id': centerId,
      'date': date?.toIso8601String(),
      'begin_at': beginAt?.toIso8601String(),
      'end_at': endAt?.toIso8601String(),
    };
  }
}
