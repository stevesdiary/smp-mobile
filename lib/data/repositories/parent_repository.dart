import '../models/child_model.dart';
import '../models/attendance_model.dart';
import '../models/academic_models.dart';
import '../services/api_client.dart';

class ParentRepository {
  final ApiClient _client;
  ParentRepository(this._client);

  Future<List<Child>> getChildren() async {
    final data = await _client.get('/api/parent/children') as List<dynamic>;
    return data.map((e) => Child.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<List<AttendanceRecord>> getChildAttendance(String studentId) async {
    final data = await _client.get('/api/parent/children/$studentId/attendance') as List<dynamic>;
    return data.map((e) => AttendanceRecord.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<List<GradeModel>> getChildGrades(String studentId) async {
    final data = await _client.get('/api/parent/children/$studentId/grades') as List<dynamic>;
    return data.map((e) => GradeModel.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<List<TimetableEntry>> getChildTimetable(String studentId) async {
    final data = await _client.get('/api/parent/children/$studentId/timetable') as List<dynamic>;
    return data.map((e) => TimetableEntry.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<List<FeeSummary>> getFeeSummaries() async {
    final data = await _client.get('/api/parent/fees') as List<dynamic>;
    return data.map((e) => FeeSummary.fromJson(e as Map<String, dynamic>)).toList();
  }
}

final parentRepository = ParentRepository(apiClient);
