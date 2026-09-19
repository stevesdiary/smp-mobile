import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'data/services/api_client.dart';
import 'data/services/auth_service.dart';
import 'data/repositories/parent_repository.dart';
import 'ui/features/auth/auth_provider.dart';
import 'ui/features/attendance/attendance_provider.dart';
import 'app.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  final auth = AuthProvider(AuthService(apiClient));

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: auth),
        ChangeNotifierProvider(
          create: (_) => AttendanceProvider(ParentRepository(apiClient)),
        ),
      ],
      child: SmpMobileApp(auth: auth),
    ),
  );
}
