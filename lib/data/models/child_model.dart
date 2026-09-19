class Child {
  final String id;
  final String firstName;
  final String lastName;
  final String studentId;
  final DateTime? dob;

  Child({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.studentId,
    this.dob,
  });

  String get displayName => '$firstName $lastName';
  String get initials => '${firstName[0]}${lastName[0]}'.toUpperCase();
  String get status => 'ACTIVE';

  factory Child.fromJson(Map<String, dynamic> json) => Child(
        id: json['id'] as String,
        firstName: json['firstName'] as String,
        lastName: json['lastName'] as String,
        studentId: json['studentId'] as String,
        dob: json['dob'] != null ? DateTime.parse(json['dob'] as String) : null,
      );
}
