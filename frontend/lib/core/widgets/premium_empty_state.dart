import 'package:flutter/material.dart';

class PremiumEmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;

  const PremiumEmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
    this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: cs.surfaceContainerLow,
                shape: BoxShape.circle,
                border: Border.all(
                  color: cs.onSurface.withOpacity(0.05),
                  width: 2,
                ),
              ),
              child: Icon(
                icon,
                size: 48,
                color: cs.onSurface.withOpacity(0.2),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              title,
              textAlign: TextAlign.center,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w800,
                color: cs.onSurface,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: cs.onSurface.withOpacity(0.6),
                height: 1.5,
              ),
            ),
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: 32),
              OutlinedButton(
                onPressed: onAction,
                style: OutlinedButton.styleFrom(
                  foregroundColor: cs.primary,
                  side: BorderSide(color: cs.primary.withOpacity(0.5)),
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  actionLabel!,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ]
          ],
        ),
      ),
    );
  }
}
