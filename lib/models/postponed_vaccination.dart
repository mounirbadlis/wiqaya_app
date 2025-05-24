class PostponedVaccination {
  final String id;
  final String individualId;
  final String vaccineId;
  final String vaccineName;
  final String? childFirstName;
  final String? childFamilyName;
  final int? reason;
  final DateTime postponedAt;
  final DateTime? retryDate;
  final bool? resolved;

  PostponedVaccination({
    required this.id,
    required this.individualId,
    required this.vaccineId,
    required this.vaccineName,
    this.childFirstName,
    this.childFamilyName,
    this.reason,
    required this.postponedAt,
    this.retryDate,
    this.resolved,
  });

  factory PostponedVaccination.fromJson(Map<String, dynamic> json) {
    return PostponedVaccination(
      id: json['id'],
      individualId: json['individual_id'],
      vaccineId: json['vaccine_id'],
      vaccineName: json['vaccine_name'],
      childFirstName: json['child_first_name'],
      childFamilyName: json['child_family_name'],
      reason: json['reason'],
      postponedAt: DateTime.parse(json['postponed_at']),
      retryDate: json['retry_date'] != null ? DateTime.parse(json['retry_date']) : null,
      resolved: json['resolved'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'individual_id': individualId,
      'vaccine_id': vaccineId,
      'child_first_name': childFirstName,
      'child_family_name': childFamilyName,
      'reason': reason,
      'postponed_at': postponedAt.toIso8601String(),
      'retry_date': retryDate?.toIso8601String(),
      'resolved': resolved,
    };
  }

  static List<PostponedVaccination> postponedVaccinationsFromJson(List<dynamic> json) {
    return json.map((item) => PostponedVaccination.fromJson(item)).toList();
  }
}
