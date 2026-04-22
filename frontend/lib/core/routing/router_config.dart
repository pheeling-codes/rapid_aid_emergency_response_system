import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/domain/auth_enums.dart';
import '../../features/auth/presentation/splash_screen.dart';
import '../../features/auth/presentation/login_screen.dart';
import '../../features/auth/presentation/signup_screen.dart';
import '../../features/auth/presentation/forgot_password_screen.dart';
import '../../features/auth/presentation/role_splash_screen.dart';

class AppRouter {
  static final _rootNavigatorKey = GlobalKey<NavigatorState>();

  static final GoRouter router = GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/splash',
    routes: [
      // ── Stage 1: Universal Splash ──
      GoRoute(
        path: '/splash',
        builder: (context, state) => const SplashScreen(),
      ),

      // ── Stage 2: Universal Login ──
      GoRoute(
        path: '/login',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const LoginScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
        ),
      ),

      // ── Stage 2b: Signup ──
      GoRoute(
        path: '/signup',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const SignupScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
        ),
      ),

      // ── Stage 2c: Forgot Password ──
      GoRoute(
        path: '/forgot-password',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const ForgotPasswordScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
        ),
      ),

      // ── Stage 3: Role-Specific Handshake ──
      GoRoute(
        path: '/role-splash/:role',
        builder: (context, state) {
          final roleName = state.pathParameters['role'] ?? 'citizen';
          final role = UserRole.values.firstWhere(
            (r) => r.name == roleName,
            orElse: () => UserRole.citizen,
          );
          return RoleSplashScreen(role: role);
        },
      ),

      // ── Stage 4: Dashboard Shells (placeholder for now) ──
      GoRoute(
        path: '/citizen',
        builder: (context, state) => _DashboardPlaceholder(
          title: 'Citizen Dashboard',
          role: UserRole.citizen,
        ),
      ),
      GoRoute(
        path: '/responder',
        builder: (context, state) => _DashboardPlaceholder(
          title: 'Responder Dashboard',
          role: UserRole.responder,
        ),
      ),
      GoRoute(
        path: '/admin',
        builder: (context, state) => _DashboardPlaceholder(
          title: 'Admin Command Center',
          role: UserRole.admin,
        ),
      ),

      // Legacy redirect
      GoRoute(
        path: '/auth',
        redirect: (context, state) => '/splash',
      ),
    ],
  );
}

/// Temporary dashboard placeholder until feature screens are built.
class _DashboardPlaceholder extends StatelessWidget {
  final String title;
  final UserRole role;

  const _DashboardPlaceholder({required this.title, required this.role});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Scaffold(
      backgroundColor: cs.surface,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: cs.primary,
                borderRadius: BorderRadius.circular(16),
              ),
              alignment: Alignment.center,
              child: const Text(
                '✳',
                style: TextStyle(color: Colors.white, fontSize: 32),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              title,
              style: theme.textTheme.headlineMedium,
            ),
            const SizedBox(height: 8),
            Text(
              '${role.portalLabel} — Active',
              style: theme.textTheme.labelMedium?.copyWith(
                color: cs.onSurface.withOpacity(0.5),
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 32),
            TextButton.icon(
              onPressed: () => context.go('/login'),
              icon: const Icon(Icons.logout_outlined, size: 18),
              label: const Text('Sign Out'),
            ),
          ],
        ),
      ),
    );
  }
}
