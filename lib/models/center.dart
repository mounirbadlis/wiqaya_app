class Center {
  final String id;
  final String? name;
  final double? latitude;
  final double? longitude;

  Center({
    required this.id,
    this.name,
    this.latitude,
    this.longitude,
  });

  factory Center.fromJson(Map<String, dynamic> json) {
    return Center(
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
}
