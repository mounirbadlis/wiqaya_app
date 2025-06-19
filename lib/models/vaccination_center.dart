class VaccinationCenter {
  final String id;
  final String? providerId;
  final String? providerFirstName;
  final String? providerFamilyName;
  final String? name;
  final double? latitude;
  final double? longitude;

  VaccinationCenter({
    required this.id,
    required this.providerId,
    required this.providerFirstName,
    required this.providerFamilyName,
    this.name,
    this.latitude,
    this.longitude,
  });

  factory VaccinationCenter.fromJson(Map<String, dynamic> json) {
    return VaccinationCenter(
      id: json['id'],
      providerId: json['provider_id'],
      providerFirstName: json['providers']?['users']?['first_name'] ?? '',
      providerFamilyName: json['providers']?['users']?['family_name'] ?? '',
      name: json['name'],
      latitude: json['latitude'] != null ? (json['latitude'] as num).toDouble() : null,
      longitude: json['longitude'] != null ? (json['longitude'] as num).toDouble() : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'provider_id': providerId,
      'provider_first_name': providerFirstName,
      'provider_family_name': providerFamilyName,
      'name': name,
      'latitude': latitude,
      'longitude': longitude,
    };
  }

  static List<VaccinationCenter> centersFromJson(List<dynamic> jsonList) {
    return jsonList.map((json) => VaccinationCenter.fromJson(json)).toList();
  }
}
