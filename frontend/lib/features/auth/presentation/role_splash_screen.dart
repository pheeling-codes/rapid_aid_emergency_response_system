import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../domain/auth_enums.dart';
import '../../../core/widgets/base_splash_page.dart';

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
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeIn,
    );
    _fadeController.forward();

    // Auto-redirect to dashboard after exactly 2 seconds
    Future.delayed(const Duration(seconds: 2), () {
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
    return FadeTransition(
      opacity: _fadeAnimation,
      child: BaseSplashPage(
        centerLabel: widget.role.portalLabel,
        bottomIndicatorText: widget.role.splashMessage,
      ),
    );
  }
}
