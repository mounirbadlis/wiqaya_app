class Reminder {
  final String id;
  final String receiverId;
  final String? vaccineId;
  final String? vaccineName;
  final String? childId;
  final String? childFirstName;
  final String? childFamilyName;
  final DateTime? bookAfter;
  final DateTime createdAt;
  final String title;
  final String message;
  final int type;
  final bool seen;
  final bool isSolved;

  Reminder({
    required this.id,
    required this.receiverId,
    this.vaccineId,
    this.vaccineName,
    this.childId,
    this.childFirstName,
    this.childFamilyName,
    this.bookAfter,
    required this.createdAt,
    required this.title,
    required this.message,
    required this.type,
    required this.seen,
    required this.isSolved,
  });

  factory Reminder.fromJson(Map<String, dynamic> json) {
    return Reminder(
      id: json['id'],
      receiverId: json['receiver_id'],
      vaccineId: json['vaccine_id'],
      vaccineName: json['vaccine_name'],
      childId: json['child_id'],
      childFirstName: json['child_first_name'],
      childFamilyName: json['child_family_name'],
      bookAfter: json['book_after'] != null ? DateTime.parse(json['book_after']) : null,
      createdAt: DateTime.parse(json['created_at']),
      title: json['title'],
      message: json['message'],
      type: json['type'],
      seen: json['seen'],
      isSolved: json['is_solved'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'receiver_id': receiverId,
      'vaccine_id': vaccineId,
      'vaccine_name': vaccineName,
      'child_id': childId,
      'child_first_name': childFirstName,
      'child_family_name': childFamilyName,
      'book_after': bookAfter?.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'title': title,
      'message': message,
      'type': type,
      'seen': seen,
      'is_solved': isSolved,
    };
  }

  static List<Reminder> notificationsFromJson(List<dynamic> json) {
    return json.map((item) => Reminder.fromJson(item)).toList();
  }
}
