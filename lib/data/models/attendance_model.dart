class AttendanceRecord {
  final String id;
  final String studentId;
  final DateTime date;
  final String status; // PRESENT | ABSENT | LATE | EXCUSED
  final String? remarks;

  AttendanceRecord({
    required this.id,
    required this.studentId,
    required this.date,
    required this.status,
    this.remarks,
  });

  factory AttendanceRecord.fromJson(Map<String, dynamic> json) {
    return AttendanceRecord(
      id: json['id'] as String,
      studentId: json['studentId'] as String,
      date: DateTime.parse(json['date'] as String),
      status: json['status'] as String,
      remarks: json['remarks'] as String?,
    );
  }
}

class AttendanceStats {
  final int total;
  final int present;
  final int absent;
  final int late;
  final int excused;
  final double attendanceRate;

  AttendanceStats({
    required this.total,
    required this.present,
    required this.absent,
    required this.late,
    required this.excused,
    required this.attendanceRate,
  });

  factory AttendanceStats.fromJson(Map<String, dynamic> json) {
    return AttendanceStats(
      total: json['total'] as int,
      present: json['present'] as int,
      absent: json['absent'] as int,
      late: json['late'] as int,
      excused: json['excused'] as int,
      attendanceRate: (json['attendanceRate'] as num).toDouble(),
    );
  }
}
