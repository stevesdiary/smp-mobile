import '../models/attendance_model.dart';
import '../services/api_client.dart';

class AttendanceRepository {
  final ApiClient _client;
  AttendanceRepository(this._client);

  Future<List<AttendanceRecord>> getStudentAttendance(String studentId) async {
    final data = await _client.get(
      '/attendance',
      query: {'studentId': studentId},
    ) as List<dynamic>;
    return data
        .map((e) => AttendanceRecord.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<AttendanceStats> getStats(
    String studentId,
    DateTime startDate,
    DateTime endDate,
  ) async {
    final data = await _client.get(
      '/attendance/stats/$studentId',
      query: {
        'startDate': startDate.toIso8601String(),
        'endDate': endDate.toIso8601String(),
      },
    ) as Map<String, dynamic>;
    return AttendanceStats.fromJson(data);
  }
}
