import 'package:flutter/material.dart';
import 'rapid_aid_logo.dart';

class BaseSplashPage extends StatelessWidget {
  final String centerLabel;
  final String bottomIndicatorText;

  const BaseSplashPage({
    Key? key,
    required this.centerLabel,
    required this.bottomIndicatorText,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Scaffold(
      backgroundColor:
          Colors.white, // Strictly pure white per Vanguard aesthetic
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Spacer(flex: 3),
            // Central Asset: Primary Blue Logo
            const RapidAidLogo(
              size: 100,
              iconSize: 48,
            ),
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
              '• ${centerLabel.toUpperCase()} •',
              style: theme.textTheme.labelLarge?.copyWith(
                color: cs.onSurface.withOpacity(0.45),
                letterSpacing: 2.0,
                fontWeight: FontWeight.w600,
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
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.shield_outlined,
                  size: 14,
                  color: cs.onSurface.withOpacity(0.35),
                ),
                const SizedBox(width: 8),
                Text(
                  bottomIndicatorText.toUpperCase(),
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: cs.onSurface.withOpacity(0.35),
                    letterSpacing: 1.5,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 48),
          ],
        ),
      ),
    );
  }
}
