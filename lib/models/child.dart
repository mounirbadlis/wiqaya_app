class Child {
  final String id;
  final String firstName;
  final String familyName;
  final String? parentId;
  final DateTime birthDate;
  final int gender;
  final String bloodType;
  final int type;

  Child({
    required this.id,
    required this.firstName,
    required this.familyName,
    this.parentId,
    required this.birthDate,
    required this.gender,
    required this.bloodType,
    required this.type,
  });

  factory Child.fromJson(Map<String, dynamic> json) {
    return Child(
      id: json['id'],
      firstName: json['first_name'],
      familyName: json['family_name'],
      parentId: json['parent_id'],
      birthDate: DateTime.parse(json['birth_date']),
      gender: json['gender'],
      bloodType: json['blood_type'],
      type: json['type'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'first_name': firstName,
      'family_name': familyName,
      'parent_id': parentId,
      'birth_date': birthDate.toIso8601String(),
      'gender': gender,
      'blood_type': bloodType,
      'type': type,
    };
  }

    static List<Child> childrenFromJson(List<dynamic> jsonList) {
    return jsonList.map((json) => Child.fromJson(json)).toList();
  }
}
