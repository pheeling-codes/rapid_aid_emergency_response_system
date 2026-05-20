import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../widgets/rapid_aid_logo.dart';

import '../../features/auth/domain/auth_enums.dart';
import '../../features/auth/logic/auth_bloc.dart';
import '../../features/auth/logic/auth_event.dart';
import '../../features/auth/logic/auth_state.dart';
import '../../features/auth/presentation/splash_screen.dart';
import '../../features/auth/presentation/login_screen.dart';
import '../../features/auth/presentation/signup_screen.dart';
import '../../features/auth/presentation/forgot_password_screen.dart';
import '../../features/auth/presentation/role_splash_screen.dart';
import '../../features/auth/presentation/verification_screen.dart';
import '../../features/auth/presentation/reset_password_screen.dart';
import '../../features/auth/presentation/security_updated_splash.dart';
import '../../features/citizen/presentation/citizen_shell.dart';
import '../../features/citizen/presentation/citizen_splash_screen.dart';
import '../../features/citizen/presentation/citizen_dashboard.dart';
import '../../features/citizen/presentation/input_emergency_details.dart';
import '../../features/citizen/presentation/confirm_dispatch.dart';
import '../../features/citizen/presentation/citizen_map_screen.dart';
import '../../features/citizen/presentation/citizen_history_screen.dart';
import '../../features/citizen/presentation/citizen_profile_screen.dart';

/// GoRouter configuration with RBAC navigation guards.
///
/// Guards enforce:
/// - Unauthenticated users are blocked from dashboard routes
/// - CITIZEN cannot access /responder or /admin
/// - RESPONDER cannot access /admin or /citizen
/// - DISPATCHER/ADMIN cannot access /citizen or /responder
class AppRouter {
  final AuthBloc authBloc;

  AppRouter({required this.authBloc});

  late final GoRouter router = GoRouter(
    initialLocation: '/splash',
    refreshListenable: GoRouterRefreshStream(authBloc.stream),
    redirect: _guardRedirect,
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

      // ── Stage 2d: Verify Code ──
      GoRoute(
        path: '/verify-code',
        builder: (context, state) {
          final email = state.extra as String? ?? '';
          return VerificationScreen(email: email);
        },
      ),

      // ── Stage 2e: Reset Password ──
      GoRoute(
        path: '/reset-password',
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>? ?? {};
          final email = extra['email'] as String? ?? '';
          final code = extra['code'] as String? ?? '';
          return ResetPasswordScreen(email: email, code: code);
        },
      ),

      // ── Stage 2f: Security Updated Splash ──
      GoRoute(
        path: '/security-splash',
        builder: (context, state) => const SecurityUpdatedSplash(),
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

      // ── Stage 4: Citizen Shell with Bottom Navigation ──
      ShellRoute(
        builder: (context, state, child) => CitizenShell(child: child),
        routes: [
          GoRoute(
            path: '/citizen',
            redirect: (context, state) => '/citizen/dashboard',
          ),
          GoRoute(
            path: '/citizen/dashboard',
            builder: (context, state) => const CitizenDashboard(),
          ),
          GoRoute(
            path: '/citizen/map',
            builder: (context, state) => CitizenMapScreen(),
          ),
          GoRoute(
            path: '/citizen/history',
            builder: (context, state) => CitizenHistoryScreen(),
          ),
          GoRoute(
            path: '/citizen/profile',
            builder: (context, state) => CitizenProfileScreen(),
          ),
        ],
      ),

      // ── Citizen Splash Screen ──
      GoRoute(
        path: '/citizen/splash',
        builder: (context, state) => CitizenSplashScreen(),
      ),

      // ── Citizen Full-Screen Routes (outside shell) ──
      GoRoute(
        path: '/citizen/incident-details',
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>? ?? {};
          final type = extra['type'] as String? ?? 'Medical';
          return InputEmergencyDetails(emergencyType: type);
        },
      ),
      GoRoute(
        path: '/citizen/dispatch-confirm',
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>? ?? {};
          final type = extra['type'] as String? ?? 'Medical';
          final desc = extra['description'] as String? ?? '';
          return ConfirmDispatch(emergencyType: type, description: desc);
        },
      ),

      // ── Stage 4b: Responder & Admin Placeholders ──
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

  /// RBAC navigation guard.
  /// Blocks unauthenticated access to dashboards.
  /// Blocks cross-role access (e.g., CITIZEN trying to reach /admin).
  String? _guardRedirect(BuildContext context, GoRouterState state) {
    final authState = authBloc.state;
    final location = state.matchedLocation;
    final isAuthenticated = authState.status == AuthStatus.authenticated;

    // Public routes that don't require auth
    const publicPaths = [
      '/splash',
      '/login',
      '/signup',
      '/forgot-password',
      '/verify-code',
      '/reset-password',
      '/security-splash',
    ];
    final isPublicRoute = publicPaths.contains(location);
    final isRoleSplash = location.startsWith('/role-splash');

    // Don't redirect during initial/loading states
    if (authState.status == AuthStatus.initial ||
        authState.status == AuthStatus.loading) {
      return null;
    }

    // Unauthenticated trying to access protected route
    if (!isAuthenticated && !isPublicRoute && !isRoleSplash) {
      return '/login';
    }

    // Authenticated trying to access auth routes (already logged in)
    if (isAuthenticated && isPublicRoute && location != '/splash') {
      return '/role-splash/${authState.selectedRole.name}';
    }

    // RBAC: Check role-specific route access
    if (isAuthenticated && !isPublicRoute && !isRoleSplash) {
      final role = authState.selectedRole;
      final allowedRoute = role.dashboardRoute;

      final isCitizenRoute =
          location.startsWith('/citizen/') || location == '/citizen';
      final isResponderRoute = location.startsWith('/responder');
      final isAdminRoute = location.startsWith('/admin');

      if (isCitizenRoute && allowedRoute != '/citizen') {
        return allowedRoute;
      }
      if (isResponderRoute && allowedRoute != '/responder') {
        return allowedRoute;
      }
      if (isAdminRoute && allowedRoute != '/admin') {
        return allowedRoute;
      }
    }

    return null; // No redirect needed
  }
}

/// Adapts a Stream to a Listenable for GoRouter's refreshListenable.
class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream stream) {
    notifyListeners();
    _subscription = stream.asBroadcastStream().listen((_) => notifyListeners());
  }

  late final dynamic _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
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
            const RapidAidLogo(size: 64, iconSize: 32),
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
              onPressed: () {
                context.read<AuthBloc>().add(const AuthLogoutRequested());
                context.go('/login');
              },
              icon: const Icon(Icons.logout_outlined, size: 18),
              label: const Text('Sign Out'),
            ),
          ],
        ),
      ),
    );
  }
}
