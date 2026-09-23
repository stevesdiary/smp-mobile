import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'ui/core/theme.dart';
import 'ui/features/splash/splash_screen.dart';
import 'ui/features/auth/login_screen.dart';
import 'ui/features/auth/auth_provider.dart';
import 'ui/core/main_shell.dart';
import 'ui/features/home/home_screen.dart';
import 'ui/features/children/children_screen.dart';
import 'ui/features/notifications/notifications_screen.dart';
import 'ui/features/profile/profile_screen.dart';
import 'ui/features/attendance/attendance_screen.dart';
import 'ui/features/grades/grades_screen.dart';
import 'ui/features/timetable/timetable_screen.dart';
import 'ui/features/fees/fees_screen.dart';

GoRouter _buildRouter(AuthProvider auth) => GoRouter(
      initialLocation: '/',
      refreshListenable: auth,
      redirect: (context, state) {
        final loggedIn = auth.isAuthenticated;
        final onAuth = state.matchedLocation == '/login';
        final onSplash = state.matchedLocation == '/';
        if (!loggedIn && !onAuth && !onSplash) return '/login';
        if (loggedIn && onAuth) return '/home';
        return null;
      },
      routes: [
        GoRoute(path: '/', builder: (context, _) => const SplashScreen()),
        GoRoute(path: '/login', builder: (context, _) => const LoginScreen()),
        StatefulShellRoute.indexedStack(
          builder: (context, state, navigationShell) =>
              MainShell(navigationShell: navigationShell),
          branches: [
            StatefulShellBranch(routes: [
              GoRoute(
                path: '/home',
                builder: (context, _) => const HomeScreen(),
                routes: [
                  GoRoute(path: 'attendance', builder: (context, _) => const AttendanceScreen()),
                  GoRoute(path: 'grades', builder: (context, _) => const GradesScreen()),
                  GoRoute(path: 'timetable', builder: (context, _) => const TimetableScreen()),
                  GoRoute(path: 'fees', builder: (context, _) => const FeesScreen()),
                ],
              ),
            ]),
            StatefulShellBranch(routes: [
              GoRoute(
                path: '/children',
                builder: (context, _) => const ChildrenScreen(),
              ),
            ]),
            StatefulShellBranch(routes: [
              GoRoute(
                path: '/notifications',
                builder: (context, _) => const NotificationsScreen(),
              ),
            ]),
            StatefulShellBranch(routes: [
              GoRoute(
                path: '/profile',
                builder: (context, _) => const ProfileScreen(),
              ),
            ]),
          ],
        ),
      ],
    );

class SmpMobileApp extends StatefulWidget {
  final AuthProvider auth;
  const SmpMobileApp({super.key, required this.auth});

  @override
  State<SmpMobileApp> createState() => _SmpMobileAppState();
}

class _SmpMobileAppState extends State<SmpMobileApp> {
  late final GoRouter _router;

  @override
  void initState() {
    super.initState();
    _router = _buildRouter(widget.auth);
  }

  @override
  void dispose() {
    _router.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'SMP Mobile',
      theme: AcademicContinuityTheme.lightTheme,
      routerConfig: _router,
      debugShowCheckedModeBanner: false,
    );
  }
}
