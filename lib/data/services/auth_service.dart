import '../models/auth_user.dart';
import 'api_client.dart';

class AuthService {
  final ApiClient _client;
  AuthService(this._client);

  Future<AuthUser> login(String email, String password, String subdomain) async {
    _client.setTenantHint(subdomain);
    final json = await _client.post('/auth/login', {
      'email': email,
      'password': password,
    });
    final user = AuthUser.fromJson(json);
    _client.setToken(user.token);
    return user;
  }

  void logout() => _client.clearToken();
}
