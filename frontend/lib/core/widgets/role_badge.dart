import 'package:flutter/material.dart';
import '../../features/auth/domain/auth_enums.dart';

/// Subtle status tokens for role identification during signup.
/// Uses the tonal hierarchy for differentiation without hard borders.
class RoleBadge extends StatelessWidget {
  final UserRole role;
  final bool isSelected;

  const RoleBadge({
    Key? key,
    required this.role,
    this.isSelected = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    Color badgeColor;
    Color textColor;
    switch (role) {
      case UserRole.citizen:
        badgeColor = isSelected ? cs.primary : cs.surfaceContainerLow;
        textColor = isSelected ? Colors.white : cs.onSurface;
        break;
      case UserRole.responder:
        badgeColor = isSelected ? cs.secondary : cs.surfaceContainerLow;
        textColor = isSelected ? Colors.white : cs.onSurface;
        break;
      case UserRole.admin:
        badgeColor = isSelected ? cs.tertiary : cs.surfaceContainerLow;
        textColor = isSelected ? Colors.white : cs.onSurface;
        break;
    }

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: badgeColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        role.label,
        style: theme.textTheme.labelMedium?.copyWith(
          color: textColor,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
