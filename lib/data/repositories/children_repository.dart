import '../models/child_model.dart';
import '../models/attendance_model.dart';
import '../services/api_client.dart';

class ChildrenRepository {
  final ApiClient _client;
  ChildrenRepository(this._client);

  Future<List<Child>> getChildren() async {
    final data = await _client.get('/parent/children') as List<dynamic>;
    return data.map((e) => Child.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<List<AttendanceRecord>> getChildAttendance(String studentId) async {
    final data = await _client.get('/parent/children/$studentId/attendance') as List<dynamic>;
    return data.map((e) => AttendanceRecord.fromJson(e as Map<String, dynamic>)).toList();
  }
}

final childrenRepository = ChildrenRepository(apiClient);
