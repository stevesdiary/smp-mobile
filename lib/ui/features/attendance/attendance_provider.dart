import 'package:flutter/material.dart';
import 'package:smp_mobile/data/models/attendance_model.dart';
import 'package:smp_mobile/data/models/child_model.dart';
import 'package:smp_mobile/data/repositories/parent_repository.dart';

class AttendanceProvider extends ChangeNotifier {
  final ParentRepository _repo;
  AttendanceProvider(this._repo);

  List<Child> _children = [];
  Child? _selectedChild;
  List<AttendanceRecord> _records = [];
  AttendanceStats? _stats;
  bool _loading = false;
  String? _error;

  List<Child> get children => _children;
  Child? get selectedChild => _selectedChild;
  List<AttendanceRecord> get records => _records;
  AttendanceStats? get stats => _stats;
  bool get loading => _loading;
  String? get error => _error;

  Future<void> load() async {
    _loading = true;
    _error = null;
    notifyListeners();

    try {
      _children = await _repo.getChildren();
      if (_children.isEmpty) {
        _loading = false;
        notifyListeners();
        return;
      }
      _selectedChild ??= _children.first;
      await _loadAttendance(_selectedChild!.id);
    } catch (e) {
      _error = 'Failed to load data.';
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> selectChild(Child child) async {
    _selectedChild = child;
    _records = [];
    _stats = null;
    notifyListeners();
    await _loadAttendance(child.id);
  }

  Future<void> _loadAttendance(String studentId) async {
    try {
      _records = await _repo.getChildAttendance(studentId);
      _stats = _computeStats(_records);
    } catch (e) {
      _error = 'Failed to load attendance.';
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  AttendanceStats _computeStats(List<AttendanceRecord> records) {
    final total = records.length;
    final present = records.where((r) => r.status == 'PRESENT').length;
    final absent = records.where((r) => r.status == 'ABSENT').length;
    final late = records.where((r) => r.status == 'LATE').length;
    final excused = records.where((r) => r.status == 'EXCUSED').length;
    return AttendanceStats(
      total: total,
      present: present,
      absent: absent,
      late: late,
      excused: excused,
      attendanceRate: total > 0 ? (present / total) * 100 : 0,
    );
  }
}
