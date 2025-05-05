class User {
  final String id;
  final String email;
  final String firstName;
  final String familyName;
  final String phone;
  final int role;
  final String? parentId;
  final DateTime birthDate;
  final int gender;
  final String bloodType;
  final int type;

  User({
    required this.id,
    required this.email,
    required this.firstName,
    required this.familyName,
    required this.phone,
    required this.role,
    this.parentId,
    required this.birthDate,
    required this.gender,
    required this.bloodType,
    required this.type,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      email: json['email'],
      firstName: json['first_name'],
      familyName: json['family_name'],
      phone: json['phone'],
      role: json['role'],
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
      'email': email,
      'first_name': firstName,
      'family_name': familyName,
      'phone': phone,
      'role': role,
      'parent_id': parentId,
      'birth_date': birthDate.toIso8601String(),
      'gender': gender,
      'blood_type': bloodType,
      'type': type,
    };
  }
}
