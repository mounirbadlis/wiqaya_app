class Vaccine {
  final String id;
  final String name;
  final String description;
  final String? pictureUrl;
  final List<int>? requiredAges;

  Vaccine({
    required this.id,
    required this.name,
    required this.description,      
    this.pictureUrl,
    this.requiredAges,
  });

  factory Vaccine.fromJson(Map<String, dynamic> json) {
    return Vaccine(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      pictureUrl: json['image_url'] ?? '',
      requiredAges: json['required_ages'] != null ? List<int>.from(json['required_ages']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'image_url': pictureUrl,
      'required_ages': requiredAges,
    };
  }

  static List<Vaccine> vaccinesFromJson(List<dynamic> jsonList) {
    return jsonList.map((json) => Vaccine.fromJson(json)).toList();
  }
}