class HistoricalRecord {
  final String id;
  final String individualId;
  final String vaccineId;
  final String? centerId;
  final String? centerName;
  final String? providerId;
  final String? providerName;
  final String? providerFamily;
  final DateTime takedAt;
  final String vaccines;

  HistoricalRecord({
    required this.id,
    required this.individualId,
    required this.vaccineId,
    this.centerId,
    this.centerName,
    this.providerId,
    this.providerName,
    this.providerFamily,
    required this.takedAt,
    required this.vaccines,
  });

  factory HistoricalRecord.fromJson(Map<String, dynamic> json) {
    final centers = json['centers'];
    final providers = json['providers'];

    return HistoricalRecord(
      id: json['id'],
      individualId: json['individual_id'],
      vaccineId: json['vaccine_id'],
      centerId: json['center_id'],
      centerName: centers != null ? centers['name'] : null,
      providerId: json['provider_id'],
      providerName: providers != null ? providers['first_name'] : null,
      providerFamily: providers != null ? providers['family_name'] : null,
      takedAt: DateTime.parse(json['taked_at']),
      vaccines: json['vaccines'],
    );
  }

  static List<HistoricalRecord> historicalRecordsFromJson(List<dynamic> json) {
    return json.map((json) => HistoricalRecord.fromJson(json)).toList();
  }
}
