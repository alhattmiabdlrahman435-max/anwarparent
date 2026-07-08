import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../features/splash/presentation/screens/splash_screen.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/dashboard/presentation/screens/dashboard_screen.dart';
import '../../features/assignments/presentation/screens/assignments_screen.dart';
import '../../features/grades/presentation/screens/grades_screen.dart';
import '../../features/attendance/presentation/screens/attendance_screen.dart';
import '../../features/attendance/presentation/screens/absence_request_screen.dart';
import '../../features/attendance/presentation/screens/absence_history_screen.dart';
import '../../features/fees/presentation/screens/fees_screen.dart';
import '../../features/notifications/presentation/screens/notifications_screen.dart';
import '../../features/notifications/presentation/screens/alerts_screen.dart';
import '../../features/settings/presentation/screens/settings_screen.dart';
import '../../features/exams/presentation/screens/exams_screen.dart';
import '../../features/schedule/presentation/screens/schedule_screen.dart';

import 'package:flutter/material.dart';

import '../../features/auth/presentation/providers/auth_provider.dart';

part 'app_router.g.dart';

final GlobalKey<NavigatorState> rootNavigatorKey = GlobalKey<NavigatorState>();

class RouterTransitionNotifier extends ChangeNotifier {
  final Ref _ref;

  RouterTransitionNotifier(this._ref) {
    _ref.listen(authProvider, (previous, next) {
      notifyListeners();
    });
  }
}

@riverpod
GoRouter appRouter(Ref ref) {
  final notifier = RouterTransitionNotifier(ref);

  return GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: '/splash',
    refreshListenable: notifier,
    redirect: (context, state) {
      final authState = ref.read(authProvider);
      final isLoggedIn = authState.value ?? false;
      final location = state.uri.toString();

      // If not logged in and not on splash or login page, redirect to login
      if (!isLoggedIn && location != '/splash' && location != '/') {
        return '/';
      }

      // If logged in and on splash or login page, redirect to dashboard
      if (isLoggedIn && (location == '/splash' || location == '/')) {
        return '/dashboard';
      }

      return null;
    },
    routes: [
      GoRoute(path: '/splash', builder: (context, state) => const SplashScreen()),
      GoRoute(path: '/', builder: (context, state) => const LoginScreen()),
      GoRoute(
        path: '/dashboard',
        builder: (context, state) => const DashboardScreen(),
      ),
      GoRoute(
        path: '/assignments',
        builder: (context, state) => const AssignmentsScreen(),
      ),
      GoRoute(
        path: '/grades',
        builder: (context, state) => const GradesScreen(),
      ),
      GoRoute(
        path: '/attendance',
        builder: (context, state) => const AttendanceScreen(),
      ),
      GoRoute(
        path: '/absence_request',
        builder: (context, state) => const AbsenceRequestScreen(),
      ),
      GoRoute(
        path: '/absence_history',
        builder: (context, state) => const AbsenceHistoryScreen(),
      ),
      GoRoute(path: '/fees', builder: (context, state) => const FeesScreen()),
      GoRoute(
        path: '/notifications',
        builder: (context, state) => const NotificationsScreen(),
      ),
      GoRoute(
        path: '/alerts',
        builder: (context, state) => const AlertsScreen(),
      ),
      GoRoute(
        path: '/settings',
        builder: (context, state) => const SettingsScreen(),
      ),
      GoRoute(path: '/exams', builder: (context, state) => const ExamsScreen()),
      GoRoute(
        path: '/schedule',
        builder: (context, state) => const ScheduleScreen(),
      ),
    ],
  );
}
