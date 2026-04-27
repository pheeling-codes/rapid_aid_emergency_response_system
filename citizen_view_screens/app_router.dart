import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../features/home/home_screen.dart';
import '../features//incident/incident_details_screen.dart';
import '../features//incident/dispatch_confirm_screen.dart';
import '../features/incident/active_incident_screen.dart';
import '../features/reports/reports_screen.dart';
import '../features/profile/profile_screen.dart';
import '/widgets/main_scafflod.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _shellNavigatorKey = GlobalKey<NavigatorState>();

final GoRouter appRouter = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: '/home',
  routes: [
    ShellRoute(
      navigatorKey: _shellNavigatorKey,
      builder: (context, state, child) {
        return MainScaffold(child: child);
      },
      routes: [
        GoRoute(
          path: '/home',
          pageBuilder: (context, state) =>
              const NoTransitionPage(child: HomeScreen()),
        ),
        GoRoute(
          path: '/reports',
          pageBuilder: (context, state) =>
              const NoTransitionPage(child: ReportHistoryScreen()),
        ),
        GoRoute(
          path: '/map',
          pageBuilder: (context, state) =>
              const NoTransitionPage(child: IncidentActiveScreen()),
        ),
        GoRoute(
          path: '/profile',
          pageBuilder: (context, state) =>
              const NoTransitionPage(child: ProfileScreen()),
        ),
      ],
    ),
    GoRoute(
      parentNavigatorKey: _rootNavigatorKey,
      path: '/incident-details/:type',
      builder: (context, state) {
        final type = state.pathParameters['type'] ?? 'medical';
        return IncidentDetailsScreen(incidentType: type);
      },
    ),
    GoRoute(
      parentNavigatorKey: _rootNavigatorKey,
      path: '/dispatch-confirm',
      builder: (context, state) {
        final extra = state.extra as Map<String, String>?;
        return DispatchConfirmScreen(
          incidentType: extra?['type'] ?? 'Medical',
          description: extra?['description'] ?? '',
        );
      },
    ),
  ],
);
