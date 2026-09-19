import 'package:flutter/material.dart';
import 'package:smp_mobile/data/models/auth_user.dart';
import 'package:smp_mobile/data/services/auth_service.dart';
import 'package:smp_mobile/data/services/api_client.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _service;
  AuthProvider(this._service);

  AuthUser? _user;
  String? _error;
  bool _loading = false;

  AuthUser? get user => _user;
  String? get error => _error;
  bool get loading => _loading;
  bool get isAuthenticated => _user != null;

  Future<bool> login(String email, String password, String subdomain) async {
    _loading = true;
    _error = null;
    notifyListeners();

    try {
      _user = await _service.login(email, password, subdomain);
      return true;
    } catch (e) {
      _error = e is ApiException ? e.message : 'Login failed. Check your connection.';
      return false;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  void logout() {
    _service.logout();
    _user = null;
    notifyListeners();
  }
}
