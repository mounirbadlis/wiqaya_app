class User {
  String id;
  String email;
  String password;
  String firstName;
  String familyName;
  String phone;
  int role;
  DateTime? birthDate;
  int? type;
  String? parentId;

  User({
    this.id = '',
    this.email = '',
    this.password = '',
    this.firstName = '',
    this.familyName = '',
    this.phone = '',
    this.role = 3,
    this.birthDate,
    this.type,
    this.parentId,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] ?? '',
      email: json['email'] ?? '',
      password: json['password'] ?? '',
      firstName: json['first_name'] ?? '',
      familyName: json['family_name'] ?? '',
      phone: json['phone'] ?? '',
      role: json['role'] ?? 3,
      birthDate: json['birth_date'] != null ? DateTime.parse(json['birth_date']) : null,
      type: json['type'],
      parentId: json['parent_id'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'password': password,
      'first_name': firstName,
      'family_name': familyName,
      'phone': phone,
      'role': role,
      'birth_date': birthDate?.toIso8601String(),
      'type': type,
      'parent_id': parentId,
    };
  }
}
