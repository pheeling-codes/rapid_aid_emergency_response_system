import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AppRouter {
  static final _rootNavigatorKey = GlobalKey<NavigatorState>();

  static final GoRouter router = GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/auth',
    routes: [
      GoRoute(
        path: '/auth',
        builder: (context, state) => const Scaffold(
          body: Center(child: Text("Universal Auth Placeholder")),
        ),
      ),
      GoRoute(
        path: '/citizen',
        builder: (context, state) => const Scaffold(
          body: Center(child: Text("Citizen Dashboard Placeholder")),
        ),
      ),
      GoRoute(
        path: '/responder',
        builder: (context, state) => const Scaffold(
          body: Center(child: Text("Responder Dashboard Placeholder")),
        ),
      ),
      GoRoute(
        path: '/admin',
        builder: (context, state) => const Scaffold(
          body: Center(child: Text("Admin Center Placeholder - Web/Tablet Shell Max 5 destinations min 120px margin")),
        ),
      ),
    ],
  );
}
