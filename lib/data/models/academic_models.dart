class GradeModel {
  final String id;
  final String subjectName;
  final double score;
  final double maxScore;
  final String? remarks;
  final DateTime gradedAt;

  GradeModel({
    required this.id,
    required this.subjectName,
    required this.score,
    required this.maxScore,
    this.remarks,
    required this.gradedAt,
  });

  double get percentage => maxScore > 0 ? (score / maxScore) * 100 : 0;

  String get letterGrade {
    if (percentage >= 70) return 'A';
    if (percentage >= 60) return 'B';
    if (percentage >= 50) return 'C';
    if (percentage >= 45) return 'D';
    return 'F';
  }

  factory GradeModel.fromJson(Map<String, dynamic> json) {
    final subject = json['subject'] as Map<String, dynamic>?;
    return GradeModel(
      id: json['id'] as String,
      subjectName: subject?['name'] as String? ?? 'Unknown',
      score: (json['score'] as num).toDouble(),
      maxScore: (json['maxScore'] as num).toDouble(),
      remarks: json['remarks'] as String?,
      gradedAt: DateTime.parse(json['gradedAt'] as String),
    );
  }
}

class TimetableEntry {
  final String id;
  final int dayOfWeek;
  final String startTime;
  final String endTime;
  final String? room;
  final String subjectName;
  final String className;

  TimetableEntry({
    required this.id,
    required this.dayOfWeek,
    required this.startTime,
    required this.endTime,
    this.room,
    required this.subjectName,
    required this.className,
  });

  String get dayName => const ['', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'][dayOfWeek];

  factory TimetableEntry.fromJson(Map<String, dynamic> json) {
    final subject = json['subject'] as Map<String, dynamic>?;
    final cls = json['class'] as Map<String, dynamic>?;
    return TimetableEntry(
      id: json['id'] as String,
      dayOfWeek: json['dayOfWeek'] as int,
      startTime: json['startTime'] as String,
      endTime: json['endTime'] as String,
      room: json['room'] as String?,
      subjectName: subject?['name'] as String? ?? 'Unknown',
      className: cls?['name'] as String? ?? '',
    );
  }
}

class FeeAssignment {
  final String id;
  final String feeName;
  final String category;
  final double totalAmount;
  final double paidAmount;
  final String currency;
  final String status;
  final DateTime? dueDate;

  FeeAssignment({
    required this.id,
    required this.feeName,
    required this.category,
    required this.totalAmount,
    required this.paidAmount,
    required this.currency,
    required this.status,
    this.dueDate,
  });

  double get outstanding => totalAmount - paidAmount;

  factory FeeAssignment.fromJson(Map<String, dynamic> json) {
    final template = json['feeTemplate'] as Map<String, dynamic>?;
    return FeeAssignment(
      id: json['id'] as String,
      feeName: template?['name'] as String? ?? 'Unknown',
      category: template?['category'] as String? ?? '',
      totalAmount: (json['totalAmount'] as num).toDouble(),
      paidAmount: (json['paidAmount'] as num).toDouble(),
      currency: json['currency'] as String? ?? 'NGN',
      status: json['status'] as String? ?? 'UNPAID',
      dueDate: json['dueDate'] != null ? DateTime.parse(json['dueDate'] as String) : null,
    );
  }
}

class FeeSummary {
  final String studentFirstName;
  final String studentLastName;
  final List<FeeAssignment> assignments;
  final double total;
  final double paid;
  final double outstanding;

  FeeSummary({
    required this.studentFirstName,
    required this.studentLastName,
    required this.assignments,
    required this.total,
    required this.paid,
    required this.outstanding,
  });

  String get studentName => '$studentFirstName $studentLastName'.trim();

  factory FeeSummary.fromJson(Map<String, dynamic> json) {
    final student = json['student'] as Map<String, dynamic>?;
    final summary = json['summary'] as Map<String, dynamic>;
    final assignments = (json['assignments'] as List<dynamic>)
        .map((e) => FeeAssignment.fromJson(e as Map<String, dynamic>))
        .toList();
    return FeeSummary(
      studentFirstName: student?['firstName'] as String? ?? '',
      studentLastName: student?['lastName'] as String? ?? '',
      assignments: assignments,
      total: (summary['total'] as num).toDouble(),
      paid: (summary['paid'] as num).toDouble(),
      outstanding: (summary['outstanding'] as num).toDouble(),
    );
  }
}
