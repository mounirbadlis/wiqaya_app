class Vaccine {
  final String id;
  final String name;
  final String description;
  final String? pictureUrl;
  final List<int>? requiredAges;
  final List<String>? sideEffects;

  Vaccine({
    required this.id,
    required this.name,
    required this.description,      
    this.pictureUrl,
    this.requiredAges,
    this.sideEffects,
  });

  factory Vaccine.fromJson(Map<String, dynamic> json) {
    return Vaccine(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      pictureUrl: json['image_url'] ?? '',
      requiredAges: json['required_ages'] != null ? List<int>.from(json['required_ages']) : null,
      sideEffects: json['side_effects'] != null ? List<String>.from(json['side_effects']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'image_url': pictureUrl,
      'required_ages': requiredAges,
      'side_effects': sideEffects,
    };
  }

  static List<Vaccine> vaccinesFromJson(List<dynamic> jsonList) {
    return jsonList.map((json) => Vaccine.fromJson(json)).toList();
  }
}