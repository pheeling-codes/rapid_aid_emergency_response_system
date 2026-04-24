import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../logic/auth_bloc.dart';
import '../logic/auth_event.dart';
import '../logic/auth_state.dart';
import '../../../core/widgets/rapid_aid_logo.dart';

/// Stage 1: Universal Entry
/// Shows the Rapid Aid asterisk logo, tagline, loading spinner, and footer.
/// Fires AuthCheckRequested to verify stored token against the backend.
/// Routes to dashboard (if session valid) or login (if not) after min 3 seconds.
class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  bool _authCheckComplete = false;
  bool _minDelayComplete = false;
  AuthState? _resolvedState;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeIn,
    );
    _fadeController.forward();

    // Fire the session check
    context.read<AuthBloc>().add(const AuthCheckRequested());

    // Minimum 3-second branding delay
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        _minDelayComplete = true;
        _tryNavigate();
      }
    });
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  /// Navigate only when BOTH the min branding delay and auth check are complete.
  void _tryNavigate() {
    if (!mounted || !_minDelayComplete || !_authCheckComplete) return;

    final authState = _resolvedState;
    if (authState == null) return;

    if (authState.status == AuthStatus.authenticated) {
      context.go('/role-splash/${authState.selectedRole.name}');
    } else {
      context.go('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state.status == AuthStatus.authenticated ||
            state.status == AuthStatus.unauthenticated) {
          _authCheckComplete = true;
          _resolvedState = state;
          _tryNavigate();
        }
      },
      child: Scaffold(
      backgroundColor: cs.surface,
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(flex: 3),
              // Logo container with ambient depth
              const RapidAidLogo(size: 100, iconSize: 48),
              const SizedBox(height: 32),
              Text(
                'R A P I D   A I D',
                style: theme.textTheme.headlineMedium?.copyWith(
                  letterSpacing: 6,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 18),
              Text(
                '• AI AIDED EMERGENCY RESPONSE SYSTEM •',
                style: theme.textTheme.labelMedium?.copyWith(
                  color: cs.onSurface.withOpacity(0.45),
                  letterSpacing: 1.5,
                ),
              ),
              const Spacer(flex: 3),
              SizedBox(
                width: 28,
                height: 28,
                child: CircularProgressIndicator(
                  color: cs.primary,
                  strokeWidth: 2.5,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'RAPID AID EMERGENCY RESPONSE SYSTEM',
                style: theme.textTheme.labelMedium?.copyWith(
                  color: cs.onSurface.withOpacity(0.35),
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 48),
            ],
          ),
        ),
      ),
      ),
    );
  }
}
