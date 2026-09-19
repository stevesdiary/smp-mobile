import 'package:flutter/material.dart';
import 'package:smp_mobile/data/models/child_model.dart';
import 'package:smp_mobile/data/repositories/children_repository.dart';

class ChildrenProvider extends ChangeNotifier {
  final ChildrenRepository _repo;
  ChildrenProvider(this._repo);

  List<Child> _children = [];
  bool _loading = false;
  String? _error;

  List<Child> get children => _children;
  bool get loading => _loading;
  String? get error => _error;

  Future<void> load() async {
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      _children = await _repo.getChildren();
    } catch (e) {
      _error = 'Failed to load children.';
    } finally {
      _loading = false;
      notifyListeners();
    }
  }
}
