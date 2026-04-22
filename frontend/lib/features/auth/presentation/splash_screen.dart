import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Stage 1: Universal Entry
/// Shows the Rapid Aid asterisk logo, "CLINICAL PRECISION • INSTANT SUPPORT"
/// tagline, a loading spinner, and "INITIALIZING SECURED SYSTEMS" footer.
/// Auto-transitions to /login after 3 seconds.
class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

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

    // Auto-transition after 3 seconds
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) context.go('/login');
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
              // Logo container with ambient depth
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
              const SizedBox(height: 12),
              Text(
                'CLINICAL PRECISION • INSTANT SUPPORT',
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
                'INITIALIZING SECURED SYSTEMS',
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
    );
  }
}
