import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class SecurityUpdatedSplash extends StatefulWidget {
  const SecurityUpdatedSplash({Key? key}) : super(key: key);

  @override
  State<SecurityUpdatedSplash> createState() => _SecurityUpdatedSplashState();
}

class _SecurityUpdatedSplashState extends State<SecurityUpdatedSplash> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        context.go('/login');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      backgroundColor: cs.surface,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.check_circle_outline, color: cs.primary, size: 48),
            const SizedBox(height: 24),
            Text(
              'SECURITY UPDATED',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: cs.onSurface.withOpacity(0.8),
                letterSpacing: 2.0,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
