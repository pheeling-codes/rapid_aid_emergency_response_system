import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../domain/auth_enums.dart';

/// Stage 3: Role-Specific Loading Splash
/// Shows the Rapid Aid branding with the role-specific portal label
/// and handshake message, then auto-redirects to the dashboard.
///
/// Citizen  → "CITIZEN PORTAL"  / "IDENTITY SECURED"
/// Responder → "RESPONDER PORTAL" / "SECURE HANDSHAKE"
/// Admin    → "ADMIN PORTAL"    / "COMMAND CENTER"
class RoleSplashScreen extends StatefulWidget {
  final UserRole role;

  const RoleSplashScreen({Key? key, required this.role}) : super(key: key);

  @override
  State<RoleSplashScreen> createState() => _RoleSplashScreenState();
}

class _RoleSplashScreenState extends State<RoleSplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeIn,
    );
    _fadeController.forward();

    // Auto-redirect to dashboard after 2.5 seconds
    Future.delayed(const Duration(milliseconds: 2500), () {
      if (mounted) context.go(widget.role.dashboardRoute);
    });
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Scaffold(
      backgroundColor: cs.surface,
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(flex: 3),
              // Logo container
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: cs.surfaceContainerLowest,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: cs.primary.withOpacity(0.06),
                      blurRadius: 40,
                      spreadRadius: 10,
                    ),
                  ],
                ),
                alignment: Alignment.center,
                child: Text(
                  '✳',
                  style: TextStyle(
                    fontSize: 48,
                    color: cs.primary,
                  ),
                ),
              ),
              const SizedBox(height: 32),
              Text(
                'R A P I D   A I D',
                style: theme.textTheme.headlineMedium?.copyWith(
                  letterSpacing: 6,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 16),
              // Progress indicator dots
              _buildProgressDots(cs),
              const Spacer(flex: 3),
              // Subtle divider
              Container(
                width: 32,
                height: 2,
                decoration: BoxDecoration(
                  color: cs.onSurface.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(1),
                ),
              ),
              const SizedBox(height: 16),
              // Portal label
              Text(
                widget.role.portalLabel,
                style: theme.textTheme.labelMedium?.copyWith(
                  letterSpacing: 2.0,
                  fontWeight: FontWeight.w500,
                  color: cs.onSurface.withOpacity(0.6),
                ),
              ),
              const SizedBox(height: 8),
              // Handshake message
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.shield_outlined,
                    size: 14,
                    color: cs.onSurface.withOpacity(0.35),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    widget.role.splashMessage,
                    style: theme.textTheme.labelMedium?.copyWith(
                      letterSpacing: 1.5,
                      color: cs.onSurface.withOpacity(0.35),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 48),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProgressDots(ColorScheme cs) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _dot(cs, cs.primary.withOpacity(0.3), 6),
        const SizedBox(width: 4),
        _dot(cs, cs.primary, 24),
        const SizedBox(width: 4),
        _dot(cs, cs.primary.withOpacity(0.3), 6),
      ],
    );
  }

  Widget _dot(ColorScheme cs, Color color, double width) {
    return Container(
      width: width,
      height: 6,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(3),
      ),
    );
  }
}
