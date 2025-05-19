class VaccinationCenter {
  final String id;
  final String? name;
  final double? latitude;
  final double? longitude;

  VaccinationCenter({
    required this.id,
    this.name,
    this.latitude,
    this.longitude,
  });

  factory VaccinationCenter.fromJson(Map<String, dynamic> json) {
    return VaccinationCenter(
      id: json['id'],
      name: json['name'],
      latitude: json['latitude'] != null ? (json['latitude'] as num).toDouble() : null,
      longitude: json['longitude'] != null ? (json['longitude'] as num).toDouble() : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'latitude': latitude,
      'longitude': longitude,
    };
  }

  static List<VaccinationCenter> centersFromJson(List<dynamic> jsonList) {
    return jsonList.map((json) => VaccinationCenter.fromJson(json)).toList();
  }
}
